using Microsoft.AspNetCore.Mvc;

namespace DotNet8Authentication.Controllers
{
    public class BetController : Controller
    {
        // GET: BetController
        public ActionResult Index()
        {
            return View();
        }

        // GET: BetController/Details/5
        public ActionResult Details(int id)
        {
            return View();
        }

        // GET: BetController/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: BetController/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(IFormCollection collection)
        {
            try
            {
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }

        // GET: BetController/Edit/5
        public ActionResult Edit(int id)
        {
            return View();
        }

        // POST: BetController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(int id, IFormCollection collection)
        {
            try
            {
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }

        // GET: BetController/Delete/5
        public ActionResult Delete(int id)
        {
            return View();
        }

        // POST: BetController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id, IFormCollection collection)
        {
            try
            {
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View();
            }
        }
    }
}
