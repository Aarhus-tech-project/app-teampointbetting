using DotNet8Authentication.Data;
using DotNet8Authentication.DTO;
using DotNet8Authentication.Interfaces;
using DotNet8Authentication.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DotNet8Authentication.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BetAnswerController : ControllerBase
    {
        private readonly UserManager<User> _userManager;
        private readonly DataContext _context;
        private readonly IBetStatsService _betStatsService;

        public BetAnswerController(UserManager<User> userManager, DataContext context, IBetStatsService betStatsService)
        {
            _userManager = userManager;
            _context = context;
            _betStatsService = betStatsService;
        }

        [HttpPost, Authorize]
        public async Task<IActionResult> SubmitAnswer([FromBody] CreateBetAnswerDto dto)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
            {
                return Unauthorized();
            }

            var userId = Guid.Parse(user.Id);

            var bet = await _context.Bets
                .SingleOrDefaultAsync(b => b.BetId == dto.BetId);
            if (bet == null)
            {
                return NotFound("Bet not found.");
            }


            if (bet.UserId == userId)
            {
                return Forbid("You cannot bet on your own bet.");
            }

            if (DateTime.UtcNow >= bet.Deadline)
            {
                return Forbid("Deadline already reached. Cannot bet on this bet anymore.");
            }
            var existingBet = await _context.BetAnswers
                .AnyAsync(ba => ba.BetId == dto.BetId && ba.UserId == userId);

            if (existingBet)
            {
                return Forbid("You have already betted.");
            }

            var betAnswer = new BetAnswer
            {
                BetAnswerId = Guid.NewGuid(),
                BetId = dto.BetId,
                UserId = Guid.Parse(user.Id),
                Answer = dto.Answer.ToLower(),
                BettedPoints = dto.BettedPoints,
                SubmittedAt = DateTime.UtcNow
            };

            _context.BetAnswers.Add(betAnswer);
            await _context.SaveChangesAsync();
            await _betStatsService.GetBetTotalsAsync(dto.BetId);
            return Ok(betAnswer);
        }
    }
}
