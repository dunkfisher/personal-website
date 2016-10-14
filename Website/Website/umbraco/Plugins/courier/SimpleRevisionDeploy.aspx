<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="../MasterPages/CourierPage.Master" CodeBehind="SimpleRevisionDeploy.aspx.cs" Inherits="Umbraco.Courier.UI.Pages.SimpleRevisionDeploy" %>
<%@ Register Src="../usercontrols/SystemItemSelector.ascx" TagName="SystemItemSelector" TagPrefix="courier" %>
<%@ Register Namespace="umbraco.uicontrols" Assembly="controls" TagPrefix="umb" %>

<asp:Content ContentPlaceHolderID="head" runat="server">
<style type="text/css">
    .item .item{margin-left: 25px; padding-bottom: 4px;}
    .item a{color: #000; padding: 3px; text-decoration: none;}
    .item a:hover{text-decoration: underline;}
    
    select{width: 370px;}
    #systemItemSelector{height: 350px; width: 348px; overflow: auto; padding: 10px 10px 10px 10px; border: 1px solid #efefef; background: #fff}
</style>

<script type="text/javascript">

    function processSelectedNode(nodeId) {

        var split = nodeId.lastIndexOf("_");
        var id = nodeId.substring(0,split);

        var providerId = jQuery("#<%= ddl_types.ClientID %>").val();
        var url = 'plugins/courier/dialogs/transferItem.aspx?providerguid=' + providerId + '&itemid=' + id;

        UmbClientMgr.openModalWindow(url, 'Transfer Item', true, 600, 500);
    }


    jQuery(document).ready(function () {

        AppendHelp("h2.propertypaneTitel", "/umbraco-pro/courier/courier-25-express-deploy", "Watch video on how to deploy");

        jQuery("#systemItemSelector a").click(function () {
            var providerId = jQuery("#<%= ddl_types.ClientID %>").val();
            var nodeId = jQuery(this).attr("rel");

            var url = 'plugins/courier/dialogs/transferItem.aspx?providerguid=' + providerId + '&itemid=' + nodeId;
           
            UmbClientMgr.openModalWindow(url, 'Transfer Item', true, 600, 500);
        });

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
        Courier 2 Express, enables you to pick any kind of umbraco content, and deploy it to antoher umbraco website,
        without you worrying about files, links or missing components
        </p>
        <p>
            <strong>To start a new deployment, choose the type of content you would like to move in the dropdownlist below, and then 
            the item you wish to move</strong>
        </p>
    </umb:PropertyPanel>

    <umb:PropertyPanel runat="server" Text="Select the item type">
    <asp:DropDownList runat="server" id="ddl_types" AutoPostBack="true"  onselectedindexchanged="ddProviders_SelectedIndexChanged" />
    
    <asp:placeholder id="ph_items" runat="server" visible="false">
        <div id="systemItemSelector"> 
            <courier:SystemItemSelector ID="systemItemSelector" LinkList="true" runat="server" />
        </div>
    </asp:placeholder>
    </umb:PropertyPanel>

    </umb:Pane>


    <umb:Pane ID="p_info" runat="server" Text="You are using Courier 2 Express">
    <p>
        With Courier 2 Express, you simply right-click any piece of content or data in the Umbraco tree
        and click "courier" to deploy it. Watch the videos below on deployment with Courier 2 Express, or
        dive into the many additional options the full version of Courier 2 gives you.
    </p>
    
    <div id="latestCourierVideos">Loading...</div> 

    </umb:Pane>


    </umb:UmbracoPanel>

</asp:Content>
