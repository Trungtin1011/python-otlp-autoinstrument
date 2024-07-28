// Example usage:
//     dotnet run http://localhost:5200

using System.Net.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

if (args.Length != 1)
{
    Console.WriteLine(@"URL missing");
    return 2;
}

var url = args[0];

// Set up the dependency injection container and logging
var serviceCollection = new ServiceCollection();
ConfigureServices(serviceCollection);
var serviceProvider = serviceCollection.BuildServiceProvider();
var logger = serviceProvider.GetRequiredService<ILogger<Program>>();

using var httpClient = new HttpClient();
while (true)
{
    try
    {
        logger.LogInformation("Attempting to fetch content from {Url}", url);
        var content = await httpClient.GetStringAsync(url);
        Console.WriteLine(content);
        logger.LogInformation("Successfully fetched content from {Url}", url);
    }
    catch (HttpRequestException ex)
    {
        logger.LogError(ex, "Error fetching content from {Url}", url);
    }

    Thread.Sleep(5000);
}

void ConfigureServices(IServiceCollection services)
{
    services.AddLogging(config =>
    {
        config.ClearProviders();
        config.AddConsole();
        config.SetMinimumLevel(LogLevel.Information);
    });
}