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
        private readonly DataContext _db;
        private readonly IBetStatsService _betStatsService;

        public BetAnswerController(UserManager<User> userManager, DataContext context, IBetStatsService betStatsService)
        {
            _userManager = userManager;
            _db = context;
            _betStatsService = betStatsService;
        }

        [HttpGet("userId")]
        [Authorize]
        public async Task<IActionResult> GetAllUserAnswers(Guid userId)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            if (Guid.Parse(currentUser.Id) != userId)
            {
                return Forbid();
            }

            var userAnswers = await _db.BetAnswers
                .Where(ba => ba.UserId == userId)
                .ToListAsync();

            return Ok(userAnswers);
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> SubmitAnswer([FromBody] CreateBetAnswerDto dto)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
            {
                return Unauthorized();
            }

            var userId = Guid.Parse(user.Id);

            var bet = await _db.Bets
                .SingleOrDefaultAsync(b => b.BetId == dto.BetId);
            if (bet == null)
            {
                return NotFound("Bet not found.");
            }

            if (DateTime.UtcNow >= bet.Deadline)
            {
                return Forbid();
            }
            var existingBet = await _db.BetAnswers
                .AnyAsync(ba => ba.BetId == dto.BetId && ba.UserId == userId);

            if (existingBet)
            {
                return Forbid();
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
            if (user.Points != 0 && dto.BettedPoints <= user.Points)
            {
                user.Points -= dto.BettedPoints;
            }
            else
            {
                return Forbid();
            }
            _db.BetAnswers.Add(betAnswer);
            await _db.SaveChangesAsync();
            await _betStatsService.GetBetTotalsAsync(dto.BetId);
            return Ok(betAnswer);
        }
    }
}
