<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="../MasterPages/CourierPage.Master" CodeBehind="simpleRevisionDeploy_broken.aspx.cs" Inherits="Umbraco.Courier.UI.Pages.simpleRevisionDeploy" %>
<%@ Register Namespace="umbraco.uicontrols" Assembly="controls" TagPrefix="umb" %>
<asp:Content ContentPlaceHolderID="head" runat="server">
<script type="text/javascript">
    jQuery(function () {
        jQuery.ajax({
            type: 'GET',
            url: 'feedproxy.aspx?url=http://umbraco.com/feeds/videos/courier',
            dataType: 'xml',
            success: function (xml) {
                var html = "<div class='tvList'>";

                jQuery('item', xml).each(function () {

                    html += '<div class="tvitem">'
                    + '<a target="_blank" href="'
                    + jQuery(this).find('link').eq(0).text()
                    + '">'
                    + '<div class="tvimage" style="background: url(' + jQuery(this).find('thumbnail').attr('url') + ') no-repeat center center;">'
                    + '</div>'
                    + jQuery(this).find('title').eq(0).text()
                    + '</a>'
                    + '</div>';
                });
                html += "</div>";

                jQuery('#latestCourierVideos').html(html);
            }

        });
    });
</script>
</asp:Content>

<asp:Content ContentPlaceHolderID="body" runat="server">

<umb:UmbracoPanel ID="panel" Text="Simple deployment" hasMenu="false" runat="server">

<umb:Pane ID="p_deploy" runat="server" Text="What do you want to deploy?">

<umb:PropertyPanel runat="server">

    <p>
    Courier Express, enables you to pick any kind of umbraco content, and deploy it to antoher umbraco website,
    without you worrying about files, links or missing components
    </p>
    <p>
        <strong>To start a new deployment, choose the type of content you would like to move in the dropdownlist below</strong>
    </p>
    
</umb:PropertyPanel>


<umb:PropertyPanel runat="server" Text="Provider">
   
    <asp:dropdownlist runat="server" id="ddl_types"  onselectedindexchanged="ddProviders_SelectedIndexChanged" />

    <br/><small>Select the type of content you would like to move</small>
    
    <div id="providerItemsSelector">
        <div id="itemList">
        </div>
    </div>
</umb:PropertyPanel>


</umb:Pane>


<umb:Pane ID="p_info" runat="server" Text="You are using Courier Express version">
    <p>
        With Courier Express, you simply right-click any piece of content or data in the Umbraco tree
        and click "courier" to deploy it. Watch the videos below on deployment with Courier Express, or
        dive into the many additional options the full version of Courier gives you.
    </p>
    
    <div id="latestCourierVideos">Loading...</div> 

</umb:Pane>


</umb:UmbracoPanel>

</asp:Content>

