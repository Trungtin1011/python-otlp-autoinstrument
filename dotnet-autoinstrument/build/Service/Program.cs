using System.Diagnostics;
using System.Diagnostics.Metrics;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

var builder = WebApplication.CreateBuilder(args);
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
var app = builder.Build();
var connectionString = Environment.GetEnvironmentVariable("DB_CONNECTION");

// .NET Diagnostics: create the span factory
using var activitySource = new ActivitySource("Examples.Service");

// .NET Diagnostics: create a metric
using var meter = new Meter("Examples.Service", "1.0");
var successCounter = meter.CreateCounter<long>("srv.successes.count", description: "Number of successful responses");

app.MapGet("/", async (ILogger<Program> logger) =>
{
    await ExecuteSql("SELECT 1", logger);

    using (var activity = activitySource.StartActivity("SayHello"))
    {
        activity?.SetTag("foo", 1);
        activity?.SetTag("bar", "Hello, World!");
        activity?.SetTag("baz", new int[] { 1, 2, 3 });

        var waitTime = Random.Shared.NextDouble(); // max 1 second
        await Task.Delay(TimeSpan.FromSeconds(waitTime));

        activity?.SetStatus(ActivityStatusCode.Ok);

        // .NET Diagnostics: update the metric
        successCounter.Add(1);
    }

    // .NET ILogger: create a log
    logger.LogInformation("Success! Today is: {Date:MMMM dd, yyyy}", DateTimeOffset.UtcNow);

    return Results.Text("Hello there");
});

app.Run();

async Task ExecuteSql(string sql, ILogger<Program> logger)
{
    try
    {
        using var connection = new SqlConnection(connectionString);
        logger.LogInformation("Attempting to open SQL connection.");
        await connection.OpenAsync();
        logger.LogInformation("SQL connection opened successfully.");

        using var command = new SqlCommand(sql, connection);
        using var reader = await command.ExecuteReaderAsync();
        logger.LogInformation("SQL command executed successfully.");
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "An error occurred while executing the SQL command.");
        throw;
    }
}