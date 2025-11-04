using DotNet8Authentication.Classes;
using DotNet8Authentication.Data;
using DotNet8Authentication.Hubs;
using DotNet8Authentication.Interfaces;
using DotNet8Authentication.Models;
using DotNet8Authentication.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.Filters;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.AddSecurityDefinition("oauth2", new OpenApiSecurityScheme
    {
        In = ParameterLocation.Header,
        Name = "Authorization",
        Type = SecuritySchemeType.ApiKey
    });

    options.OperationFilter<SecurityRequirementsOperationFilter>();
});

builder.Services.AddDbContext<DataContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("Database")));

builder.Services.AddAuthorization();

builder.Services.AddScoped<IBettingManager, BettingManager>();
builder.Services.AddScoped<IBetStatsService, BetStatsService>();
builder.Services.AddSignalR();

builder.Services.AddIdentityApiEndpoints<User>()
    .AddEntityFrameworkStores<DataContext>();
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterApp",
        policy =>
        {
            policy
            .SetIsOriginAllowed(origin => true) // For dev only!
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
        });
});
var app = builder.Build();
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<DataContext>();
        context.Database.Migrate();
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred while migrating the database.");
    }
}
// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
else
{
    //app.UseHttpsRedirection();
}

app.UseCors("AllowFlutterApp");

app.MapIdentityApi<User>();
app.MapControllers();
app.MapHub<BetHub>("/bethub");

app.UseAuthentication();
app.UseAuthorization();

app.Run();
