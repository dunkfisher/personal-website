<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="../MasterPages/CourierPage.Master" CodeBehind="SimpleLocations.aspx.cs" Inherits="Umbraco.Courier.UI.Pages.SimpleLocations" %>
<%@ Register Namespace="umbraco.uicontrols" Assembly="controls" TagPrefix="umb" %>


<asp:Content ContentPlaceHolderID="head" runat="server">
<script type="text/javascript">
    jQuery(function () {

        AppendHelp("h2.propertypaneTitel", "/umbraco-pro/courier/courier-25-express-locations", "Watch video on how locations are used");

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

<umb:Pane ID="p_deploy" runat="server" Text="Available locations">

<umb:propertypanel runat="server">
   <p> Your Courier installation has access to the following locations</p>
   <p>Use the deploy option in the tree to left or right the items you wish to deploy to one of the below locations.</p>
</umb:propertypanel>

<umb:propertypanel runat="server">
    
    <asp:repeater runat="server" id="rp_revisions">
        <headerTemplate>
            <table>
                <tr>
                    <th>Name</th>
                    <th>Settings</th>
                    <th>Description</th>
                </tr>
        </headerTemplate>

        <itemtemplate>            
            <tr class="row">
                <th style="width: 200px !Important">
                    <span class="folderItem">
                       <asp:literal id="lt_name" runat="server" />
                    </span>
                </th>

                <td>
                    <asp:literal id="lt_config" runat="server" />
                </td>

                <td>
                    <asp:literal id="lt_desc" runat="server" />
                <td>
                
                
            </tr>
        </itemtemplate>

        <footerTemplate>
            </table>

            <p>
                You can add additional locations in the <strong>/config/courier.config</strong> file.
            </p>

        </footerTemplate>
    </asp:repeater>

</umb:propertypanel>
</umb:Pane>


<umb:Pane ID="p_info" runat="server" Text="You are using Courier Express version">
    <p>
        Courier Express, allows you to connect to any other umbraco website, with Courier installed, and deploy
        any content (as well as macros, templates, stylesheets and so on) to it. Watch the videos below for 
        more insight into how you configure and use Courier locations, as well as how the full version of Courier 
        can connect to other locations such as SVN repositories or network directories.
    </p>
    
    <div id="latestCourierVideos">Loading...</div> 
</umb:Pane>


</umb:UmbracoPanel>

</asp:Content>