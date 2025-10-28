using DotNet8Authentication.Data;
using DotNet8Authentication.DTO;
using DotNet8Authentication.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace DotNet8Authentication.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BetAnswerController : ControllerBase
    {
        private readonly UserManager<User> _userManager;
        private readonly DataContext _context;

        public BetAnswerController(UserManager<User> userManager, DataContext context)
        {
            _userManager = userManager;
            _context = context;
        }

        [HttpPost, Authorize]
        public async Task<IActionResult> SubmitAnswer([FromBody] CreateBetAnswerDto dto)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
            {
                return Unauthorized();
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
            return Ok(betAnswer);
        }
    }
}
