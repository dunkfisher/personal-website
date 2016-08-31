using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Umbraco.Web.Mvc;
using Website.UI.BL.DocumentTypes;

namespace Website.Controllers
{
    public class ListingController : SurfaceController
    {
        [ChildActionOnly]
        public ActionResult Filter()
        {
            return View("_Filter");
        }

        [ChildActionOnly]
        public ActionResult ListItems(string country)
        {
            var currentPage = CurrentPage as Listing;
            if (!string.IsNullOrEmpty(country))
            {
                currentPage.ApplyFilter(country);
            }
            return View("_ListItems", CurrentPage as Listing);
        }
    }
}