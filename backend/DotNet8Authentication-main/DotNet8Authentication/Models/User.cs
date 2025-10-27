using Microsoft.AspNetCore.Identity;

namespace DotNet8Authentication.Models
{
    public class User : IdentityUser
    {
        public int Points { get; set; } = 500;
    }
}
