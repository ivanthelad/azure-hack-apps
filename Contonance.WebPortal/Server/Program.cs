using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.Extensions.Azure;
using Azure;
using Contonance.Extensions;
using Contonance.WebPortal.Server.Clients;
using Contonance.WebPortal.Client;
using Microsoft.ApplicationInsights.AspNetCore.Extensions;

var builder = WebApplication.CreateBuilder(args);

if (builder.Environment.IsDevelopment())
{
    // Workaround because blazorwasm debugger does not support envFile
    var root = Directory.GetCurrentDirectory();
    var dotenv = Path.Combine(root, "../../../local.env");
    DotEnv.Load(dotenv);
}


builder.Configuration
    .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
    .AddJsonFile($"appsettings.{builder.Environment.EnvironmentName}.json", true, true)
    .AddEnvironmentVariables();
    var connectionString = builder.Configuration.GetValue<string>("AppConfiguration:ConnectionString");
if (!string.IsNullOrEmpty(connectionString))
{
    builder.Configuration.AddAzureAppConfiguration(options =>
    {
        options.Connect(connectionString)
            .UseFeatureFlags(options =>
            {
                options.CacheExpirationInterval = TimeSpan.FromSeconds(2);
            });
    });
}

builder.Services.AddLogging(config =>
{
    config.AddDebug();
    config.AddConsole();
});
builder.Services.AddApplicationInsightsTelemetry(options =>
{
    options.DeveloperMode = true; // Only for demo purposes, do not use in production!
});
builder.Services.AddSingleton<ITelemetryInitializer>(_ => new CloudRoleNameTelemetryInitializer("Contonance.WebPortal.Server"));
if (!string.IsNullOrEmpty(connectionString))
{
    builder.Services.AddAzureAppConfiguration();
}

//builder.Services.AddAzureAppConfiguration();
builder.Services.AddAzureClients(b =>
{
    b.AddEventHubProducerClient(builder.Configuration.GetValue<string>("EventHub:EventHubConnectionString"), builder.Configuration.GetValue<string>("EventHub:EventHubName"));
    //Added config to enable/disable Azure OpenAI Service DI for demo purposes
    if (builder.Configuration.GetValue<bool>("AzureOpenAiServiceEnabled")) {
        b.AddOpenAIClient(new Uri(builder.Configuration.GetNoEmptyStringOrThrow("AzureOpenAiServiceEndpoint")), new AzureKeyCredential(builder.Configuration.GetNoEmptyStringOrThrow("AzureOpenAiKey")));
    }
});

builder.Services
    .AddHttpClient<ContonanceBackendClient>()
    .AddPolicyConfiguration(ContonanceBackendClient.SelectPolicy, builder.Configuration);

builder.Services.AddControllersWithViews();
builder.Services.AddRazorPages();

builder.WebHost.UseStaticWebAssets();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseWebAssemblyDebugging();
}
else
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}
if (!string.IsNullOrEmpty(connectionString))
{
app.UseAzureAppConfiguration();
}
app.UseHttpsRedirection();

app.UseBlazorFrameworkFiles();
app.UseStaticFiles();

app.UseRouting();

app.MapRazorPages();
app.MapControllers();
app.MapFallbackToFile("index.html", new StaticFileOptions()
{
    OnPrepareResponse = ctx =>
    {
        ctx.Context.Response.Cookies.Append("ai_connString", app.Configuration["ApplicationInsights:ConnectionString"]!);
    }
});

app.Run();