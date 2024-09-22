module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.11.3"

  create                                 = true
  cluster_name                           = "example-ecs-cluster-001"
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 7

  ### Fargate capacity provider definitions
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
        base   = 20
      }
    }
  }

  ### Execute command configurations
  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
    }
  }

  services = {
    ### OpenTelemetry Collector
    otel-collector = {
      # Role definitions
      create_iam_role           = false # Role is not required if network_mode=awsvpc or if load_balancer is not used
      create_tasks_iam_role     = false
      create_task_exec_iam_role = false
      create_task_exec_policy   = false
      create_task_definition    = true
      tasks_iam_role_arn        = "${aws_iam_role.ecs_task_execution_role.arn}"
      task_exec_iam_role_arn    = "${aws_iam_role.ecs_task_execution_role.arn}"

      # Autoscaling configs
      enable_autoscaling       = false
      desired_count            = 1
      autoscaling_min_capacity = 1
      autoscaling_max_capacity = 2

      # Network & Infrastructure configs
      launch_type                        = "FARGATE"
      network_mode                       = "awsvpc"
      create_security_group              = false
      security_group_ids                 = ["some-security-groups"]
      subnet_ids                         = ["some-subnets"]
      assign_public_ip                   = true # Public accessible
      cpu                                = 512
      memory                             = 1024
      enable_execute_command             = true
      propagate_tags                     = "SERVICE"
      deployment_minimum_healthy_percent = 100
      volume                             = {}
      runtime_platform = {
        operating_system_family = "LINUX"
        cpu_architecture        = "X86_64"
      }
      load_balancer                 = {}
      service_connect_configuration = {}

      # Container definition(s)
      container_definitions = {
        collector = {
          essential                = true
          image                    = "otel/opentelemetry-collector-contrib:0.103.0"
          cpu                      = 256
          memory_reservation       = 512 # Soft limit
          memory                   = 768 # Hard limit
          readonly_root_filesystem = false
          port_mappings = [
            {
              name          = "otlp-http"
              containerPort = 4318
              hostPort      = 4318
              protocol      = "tcp"
            }
          ]
          command = ["--config=env:COLLECTOR_CONFIGS"]
          secrets = [
            { name = "COLLECTOR_CONFIGS", valueFrom = module.collector_ssm_parameter["/config/collector.yaml"].ssm_parameter_arn }
          ]
          environment = [
            { name = "GOMEMLIMIT", value = "102MiB" }
          ]

          # Container logging
          enable_cloudwatch_logging              = true
          create_cloudwatch_log_group            = true
          cloudwatch_log_group_retention_in_days = 7
          log_configuration = {
            log_driver = "awslogs"
            options = {
              awslogs-group             = "/aws/ecs/otel-collector/collector"
              awslogs-region            = "ap-southeast-1"
              awslogs-stream-prefix     = "ecs"
              awslogs-datetime-format   = "%Y-%m-%dT%H:%M:%S"
              awslogs-multiline-pattern = "^{"
            }
          }
        }
      }
    }
  }

  tags = merge(
    var.tags,
    {
      resource_type = "ecs",
      created_date  = ""
    }
  )
}

############################
### Supporting resources ###
############################

# IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-cluster-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "ecs-cluster-task-execution-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid      = "accessECR"
          Effect   = "Allow"
          Resource = ["*"]
          Action = [
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetAuthorizationToken",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability"
          ]
        },
        {
          Sid      = "getSSMParams"
          Effect   = "Allow"
          Resource = ["arn:aws:ssm:*:*:parameter/*"]
          Action   = ["ssm:GetParameters"]
        },
        {
          Sid      = "readSecrets"
          Effect   = "Allow"
          Resource = ["*"]
          Action = [
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:DescribeSecret",
            "secretsmanager:GetRandomPassword",
            "secretsmanager:GetSecretValue",
            "secretsmanager:ListSecretVersionIds",
            "secretsmanager:ListSecrets"
          ]
        },
        {
          Sid      = "decryptKMS"
          Effect   = "Allow"
          Resource = "*"
          Action   = ["kms:Decrypt"]
        },
        {
          Sid      = "accessCloudWatch"
          Effect   = "Allow"
          Resource = ["*"]
          Action = [
            "cloudwatch:DeleteAlarms",
            "cloudwatch:DescribeAlarms",
            "cloudwatch:PutMetricAlarm",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutRetentionPolicy",
            "logs:PutLogEvents"
          ]
        }
      ]
    })
  }

  tags = merge(
    var.tags,
    {
      resource_type = "iam"
      created_date  = ""
    }
  )
}

# Config file for collector
module "collector_ssm_parameter" {
  source  = "terraform-aws-modules/ssm-parameter/aws"
  version = "1.1.1"

  create               = true
  for_each             = local.parameters
  name                 = try(each.value.name, each.key)
  description          = try(each.value.description, null)
  type                 = try(each.value.type, null)
  secure_type          = try(each.value.secure_type, null)
  value                = try(each.value.value, null)
  values               = try(each.value.values, [])
  tier                 = try(each.value.tier, null)
  key_id               = try(each.value.key_id, null)
  allowed_pattern      = try(each.value.allowed_pattern, null)
  data_type            = try(each.value.data_type, null)
  ignore_value_changes = try(each.value.ignore_value_changes, false)
  tags                 = var.tags
}

### Use this command to retrieve data:
# aws ssm get-parameter --name /config/collector.yaml --region ap-southeast-1 --with-decryption --query "Parameter.Value" --output text

# output "ssm-value" {
#   value = module.collector_ssm_parameter["/config/collector.yaml"].value
# }
#
output "ssm-param-arn" {
  value = module.collector_ssm_parameter["/config/collector.yaml"].ssm_parameter_arn
}
