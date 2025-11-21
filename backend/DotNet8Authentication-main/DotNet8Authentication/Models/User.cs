using Microsoft.AspNetCore.Identity;

namespace DotNet8Authentication.Models
{
    public class User : IdentityUser
    {
        public string? DisplayName { get; set; }
        public string? ProfilePicturePath { get; set; }
        public int Points { get; set; } = 500;
    }
}
