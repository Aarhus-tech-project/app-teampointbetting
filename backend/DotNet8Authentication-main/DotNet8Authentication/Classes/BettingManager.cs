using DotNet8Authentication.Data;
using DotNet8Authentication.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace DotNet8Authentication.Classes
{
    public class BettingManager : IBettingManager
    {
        private readonly DataContext _db;
        public BettingManager(DataContext db)
        {
            _db = db;
        }

        public async Task<bool> EvaluateAndPayoutBetAsync(Guid betId, string winningAnswer)
        {
            var getAllBetAnswers = await _db.BetAnswers
                .Where(a => a.BetId == betId)
                .ToListAsync();

            if (!getAllBetAnswers.Any())
                return false;

            var userIds = getAllBetAnswers.Select(a => a.UserId.ToString()).Distinct().ToList();

            var users = await _db.Users
                .Where(u => userIds.Contains(u.Id))
                .ToDictionaryAsync(u => u.Id);

            var winners = getAllBetAnswers.Where(a => a.Answer.Equals(winningAnswer, StringComparison.OrdinalIgnoreCase))
                .ToList();
            var losers = getAllBetAnswers.Except(winners).ToList();

            if (!winners.Any())
                return false;

            var totalLoserPoints = losers.Sum(l => l.BettedPoints);
            var rewardPerWinner = totalLoserPoints / winners.Count;

            //winners reward
            foreach (var answer in winners)
            {
                if (users.TryGetValue(answer.UserId.ToString(), out var user))
                {
                    user.Points += answer.BettedPoints * 2 + rewardPerWinner;
                }
            }

            //losers fine
            foreach (var answer in losers)
            {
                if (users.TryGetValue(answer.UserId.ToString(), out var user))
                {
                    user.Points -= answer.BettedPoints;
                }
            }

            await _db.SaveChangesAsync();

            return true;
        }
    }
}
