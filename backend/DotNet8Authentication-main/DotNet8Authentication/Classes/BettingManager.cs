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
            var answers = await _db.BetAnswers
                .Where(a => a.BetId == betId)
                .ToListAsync();

            var userIds = answers.Select(a => a.UserId.ToString()).Distinct().ToList();

            var users = await _db.Users
                .Where(u => userIds.Contains(u.Id))
                .ToDictionaryAsync(u => u.Id);

            bool hadWinners = false;

            foreach (var answer in answers)
            {
                if (users.TryGetValue(answer.UserId.ToString(), out var user))
                {
                    if (answer.Answer.Equals(winningAnswer, StringComparison.OrdinalIgnoreCase))
                    {
                        Console.WriteLine("You won!");
                        hadWinners = true;
                    }
                }
            }

            if (hadWinners)
            {
                await _db.SaveChangesAsync();
            }

            return hadWinners;
        }
    }
}
