using DotNet8Authentication.Data;
using DotNet8Authentication.DTO;
using DotNet8Authentication.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DotNet8Authentication.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly UserManager<User> _userManager;
        private readonly DataContext _db;

        public UserController(DataContext db, UserManager<User> userManager)
        {
            _userManager = userManager;
            _db = db;
        }

        [HttpGet("get-info")]
        public async Task<IActionResult> GetUser()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized();

            return Ok(new
            {
                user.Id,
                user.UserName,
                user.Email,
                user.PhoneNumber,
                user.Points
            });
        }

        [HttpPost("add-info")]
        public async Task<IActionResult> PostUserInfo(CreateUserInfoDto dto)
        {
            var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (userId == null)
            {
                return Unauthorized();
            }

            var user = await _userManager.FindByIdAsync(userId);
            if (user == null)
                return NotFound();

            user.PhoneNumber = dto.PhoneNumber;
            user.UserName = dto.UserName;

            var result = await _userManager.UpdateAsync(user);
            if (!result.Succeeded)
            {
                return BadRequest(result.Errors);
            }

            return Ok(new
            {
                user.Id,
                user.UserName,
                user.Email,
                user.PhoneNumber,
                user.Points
            });
        }

        [HttpGet("leaderboard")]
        public async Task<IActionResult> GetLeaderboard()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized();

            var leaderboard = await _db.Users
                .OrderByDescending(user => user.Points)
                .Take(10)
                .Select(user => new
                {
                    user.Id,
                    user.UserName,
                    user.Points
                })
                .ToListAsync();
            return Ok(leaderboard);
        }
    }
}
