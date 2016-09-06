using Umbraco.Core.Models;

namespace Website.Extensions
{
    public static class UmbracoExtensions
    {
        public static T GetProperty<T>(this IPublishedContent content, string propertyName)
        {
            var value = content.GetProperty(propertyName).Value;
            return value != null ? (T)value : default(T);
        }
    }
}