using DotNet8Authentication.Data;
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
        public async Task<IActionResult> SubmitAnswer([FromBody] BetAnswer betAnswer)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
            {
                return Unauthorized();
            }
            // Example logic: Deduct points for placing a bet answer
            user.Points = 500;
            const int costToPlaceBetAnswer = 50;
            if (user.Points < costToPlaceBetAnswer)
            {
                return BadRequest("Insufficient points to place a bet answer.");
            }
            user.Points -= costToPlaceBetAnswer;
            _context.BetAnswers.Add(betAnswer);
            await _userManager.UpdateAsync(user);
            await _context.SaveChangesAsync();
            return Ok(betAnswer);
        }
    }
}
