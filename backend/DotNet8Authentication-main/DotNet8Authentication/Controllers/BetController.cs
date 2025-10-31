﻿using DotNet8Authentication.Data;
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
    public class BetController : ControllerBase
    {
        private readonly DataContext _db;
        private readonly UserManager<User> _userManager;
        private readonly IBettingManager _bettingManager;
        private readonly IBetStatsService _betStatsService;

        public BetController(DataContext db, UserManager<User> userManager, IBettingManager bettingManager, IBetStatsService betStatsService)
        {
            _db = db;
            _userManager = userManager;
            _bettingManager = bettingManager;
            _betStatsService = betStatsService;

        }

        [HttpPost("create")]
        [Authorize]
        public async Task<IActionResult> CreateBet([FromBody] CreateBetDto dto)
        {
            var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (userId == null)
            {
                return Unauthorized();
            }

            var bet = new Bet
            {
                BetId = Guid.NewGuid(),
                UserId = Guid.Parse(userId),
                Subject = dto.Subject,
                Deadline = dto.Deadline
            };
            _db.Bets.Add(bet);
            await _db.SaveChangesAsync();
            return Ok(bet);

        }

        [HttpGet("{betId}/totals")]
        public async Task<IActionResult> GetBetTotals(Guid betId)
        {
            var bet = await _db.Bets.FirstOrDefaultAsync(b => b.BetId == betId);
            if (bet == null)
            {
                return NotFound();
            }

            var (totalYes, totalNo) = await _betStatsService.GetBetTotalsAsync(betId);
            return Ok(new
            {
                bet.BetId,
                bet.Subject,
                totalYes,
                totalNo
            });
        }

        [HttpPut("set-result"), Authorize]
        public async Task<IActionResult> SetBetResult([FromBody] UpdateBetResultDto dto)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized();

            var bet = await _db.Bets.FirstOrDefaultAsync(b => b.BetId == dto.BetId);
            if (bet == null)
            {
                return NotFound();
            }

            if (bet.UserId != Guid.Parse(user.Id))
            {
                return Forbid("Only the creator of the bet can set the result.");
            }

            if (DateTime.UtcNow < bet.Deadline)
            {
                return BadRequest("Cannot set result before the deadline.");
            }

            bet.CorrectAnswer = dto.CorrectAnswer;

            await _db.SaveChangesAsync();
            var payoutSuccess = await _bettingManager.EvaluateAndPayoutBetAsync(bet.BetId, bet.CorrectAnswer);

            if (payoutSuccess)
            {
                return StatusCode(500, "Error during payout processing.");
            }
            return Ok(new
            {
                message = "Bet result updated",
                betId = bet.BetId,
                correctAnswer = bet.CorrectAnswer
            });
        }

        [HttpGet]
        public async Task<IActionResult> GetBets()
        {
            var bets = await _db.Bets.ToListAsync();
            return Ok(bets);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetBet(Guid id)
        {
            var bet = await _db.Bets.FindAsync(id);
            if (bet == null)
            {
                return NotFound();
            }
            return Ok(bet);
        }
    }
}
