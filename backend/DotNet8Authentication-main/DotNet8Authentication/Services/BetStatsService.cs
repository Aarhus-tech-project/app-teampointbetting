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

        public async Task<(int totalYes, int totalNo, int totalAll)> GetBetTotalsAsync(Guid betId)
        {
            var allAnswers = await _db.BetAnswers
                .Where(a => a.BetId == betId)
                .ToListAsync();

            int totalYes = allAnswers
                .Where(a => a.Answer.Equals("yes", StringComparison.OrdinalIgnoreCase))
                .Sum(a => a.BettedPoints);

            int totalNo = allAnswers
                .Where(a => a.Answer.Equals("no", StringComparison.OrdinalIgnoreCase))
                .Sum(a => a.BettedPoints);

            int totalAll = totalYes + totalNo;

            await _hubContext.Clients.Group(betId.ToString())
                .SendAsync("UpdateBetTotals", new
                {
                    betId,
                    totalAll,
                    totalYes,
                    totalNo
                });

            return (totalYes, totalNo, totalAll);
        }
    }
}
