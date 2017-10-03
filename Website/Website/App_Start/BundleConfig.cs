using System.Web;
using System.Web.Optimization;

namespace Website
{
    public class BundleConfig
    {
        // For more information on bundling, visit http://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/jquery")
                .Include("~/scripts/libraries/jquery-{version}.js"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryajax")
                .Include("~/scripts/libraries/jquery.unobtrusive*"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryval")
                .Include("~/scripts/libraries/jquery.validate*"));

            bundles.Add(new ScriptBundle("~/bundles/slimmage")
                .Include("~/scripts/libraries/slimmage*"));

            bundles.Add(new ScriptBundle("~/bundles/sitejs")
                .Include("~/scripts/listing.js"));

            bundles.Add(new StyleBundle("~/bundles/sitecss")
                .Include("~/css/*.css"));
        }
    }
}
