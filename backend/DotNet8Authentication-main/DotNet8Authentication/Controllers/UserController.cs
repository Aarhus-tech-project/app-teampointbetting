using Microsoft.AspNetCore.Mvc;

namespace DotNet8Authentication.Controllers
{
    public class UserController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}
