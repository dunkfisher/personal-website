using Umbraco.Core.Models;

namespace Website.Extensions
{
    public static class UmbracoExtensions
    {
        public static T GetProperty<T>(this IPublishedContent content, string propertyName)
        {
            return (T)content.GetProperty(propertyName).Value;
        }
    }
}