using DotNet8Authentication.Data;
using DotNet8Authentication.DTO;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DotNet8Authentication.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BetController : ControllerBase
    {
        private readonly DataContext _db;

        public BetController(DataContext db)
        {
            _db = db;
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

            var bet = new Models.Bet
            {
                BetId = Guid.NewGuid(),
                UserId = Guid.Parse(userId),
                Subject = dto.Subject,
                Points = dto.Points,
                Deadline = dto.Deadline,
                CorrectAnswer = null
            };
            _db.Bets.Add(bet);
            await _db.SaveChangesAsync();
            return Ok(bet);

        }

        [HttpPut("set-result")]
        public async Task<IActionResult> SetBetResult([FromBody] UpdateBetResultDto dto)
        {
            var bet = await _db.Bets.FirstOrDefaultAsync(b => b.BetId == dto.BetId);
            if (bet == null)
            {
                return NotFound();
            }
            bet.CorrectAnswer = dto.CorrectAnswer;
            await _db.SaveChangesAsync();
            return Ok(bet);
        }

        [HttpGet]
        public async Task<IActionResult> GetBets()
        {
            var bets = await _db.Bets.ToListAsync();
            return Ok(bets);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetBet(int id)
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
