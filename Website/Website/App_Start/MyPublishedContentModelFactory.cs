using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Umbraco.Core.Models;
using Umbraco.Core.Models.PublishedContent;
using Website.UI.BL.DocumentTypes;

namespace Website.App_Start
{
    public class MyPublishedContentModelFactory : IPublishedContentModelFactory
    {
        private IEnumerable<Type> _documentTypes;

        public MyPublishedContentModelFactory(IEnumerable<Type> types)
        {
            _documentTypes = types;
        }

        public IPublishedContent CreateModel(IPublishedContent content)
        {
            var currentDocumentType = _documentTypes.Where(x => x.Name == content.DocumentTypeAlias).SingleOrDefault();
            if (currentDocumentType != null)
            {
                var constructorInfo = currentDocumentType.GetConstructor(new[] { typeof(IPublishedContent) });
                return (IPublishedContent)constructorInfo.Invoke(new[] { content });
            }
            return new Base(content);
        }
    }
}