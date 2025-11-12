using DotNet8Authentication.Data;
using Microsoft.EntityFrameworkCore;

namespace DotNet8Authentication.Services
{
    public class BetDeadlineChecker : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;

        public BetDeadlineChecker(IServiceScopeFactory scopeFactory)
        {
            _scopeFactory = scopeFactory;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            try
            {

                while (!stoppingToken.IsCancellationRequested)
                {
                    using var scope = _scopeFactory.CreateScope();
                    var db = scope.ServiceProvider.GetRequiredService<DataContext>();
                    var emailService = scope.ServiceProvider.GetRequiredService<EmailService>();

                    var now = DateTime.UtcNow;

                    var expiredBets = await db.Bets
                        .Where(b => b.Deadline <= now && b.CorrectAnswer == null)
                        .ToListAsync(stoppingToken);

                    foreach (var bet in expiredBets)
                    {
                        var userIds = await db.BetAnswers
                            .Where(betAnswer => betAnswer.BetId == bet.BetId)
                            .Join(db.Users,
                                betAnswer => betAnswer.UserId,
                                user => Guid.Parse(user.Id),
                                (betAnswer, user) => user.Email)
                            .Distinct()
                            .ToListAsync(stoppingToken);

                        foreach (var email in userIds)
                        {
                            // Send notification email to user
                            await emailService.SendEmailAsync(
                                email.ToString(),
                                $"Subject: {bet.Subject}",
                                "You can now check the results in the app"
                            );
                        }

                        bet.IsDeadlineNotified = true;

                    }
                    await db.SaveChangesAsync(stoppingToken);
                    await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken);
                }
            }
            catch (TaskCanceledException)
            {
                // Service is stopping, no action needed
            }
            catch (Exception ex)
            {
                // Log exception (implementation depends on your logging setup)
                Console.WriteLine($"Error in BetDeadlineChecker: {ex.Message}");
            }
        }
    }
}
