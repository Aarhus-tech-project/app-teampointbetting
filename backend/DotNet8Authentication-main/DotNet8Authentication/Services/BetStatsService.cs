using DotNet8Authentication.Data;
using DotNet8Authentication.Hubs;
using DotNet8Authentication.Interfaces;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace DotNet8Authentication.Services
{
    public class BetStatsService : IBetStatsService
    {
        private readonly DataContext _db;
        private readonly IHubContext<BetHub> _hubContext;

        public BetStatsService(DataContext db, IHubContext<BetHub> hubContext)
        {
            _db = db;
            _hubContext = hubContext;
        }

        public async Task<(int totalYesPoints, int totalNoPoints)> GetBetTotalsAsync(Guid betId)
        {
            var allAnswers = await _db.BetAnswers
                .Where(a => a.BetId == betId)
                .ToListAsync();

            int totalYesPoints = allAnswers
                .Where(a => a.Answer.Equals("yes", StringComparison.OrdinalIgnoreCase))
                .Sum(a => a.BettedPoints);

            int totalNoPoints = allAnswers
                .Where(a => a.Answer.Equals("no", StringComparison.OrdinalIgnoreCase))
                .Sum(a => a.BettedPoints);

            await _hubContext.Clients.Group(betId.ToString())
                .SendAsync("UpdateBetTotals", new
                {
                    betId,
                    totalYesPoints,
                    totalNoPoints
                });

            return (totalYesPoints, totalNoPoints);
        }
    }
}
