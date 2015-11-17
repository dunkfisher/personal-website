<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="../MasterPages/CourierPage.Master" CodeBehind="editLocalRevision.aspx.cs" Inherits="Umbraco.Courier.UI.Pages.EditRevisions" %>

<%@ Register Namespace="umbraco.uicontrols" Assembly="controls" TagPrefix="umb" %>
<%@ Register Src="../usercontrols/RevisionContentsOverview.ascx" TagName="RevisionContents" TagPrefix="courier" %>

<asp:Content ContentPlaceHolderID="head" runat="server">

    <style type="text/css">
        #simplemodal-container {
            width: 420px;
            height: 470px;
        }

        .simplemodal-data {
            width: 420px;
            height: 470px;
        }
    </style>

    <script type="text/javascript">
        var currentManifest = <%= ManifestJson %>;
        jQuery(document).ready(function () {
            
            AppendHelp("h2.propertypaneTitel", "/umbraco-pro/courier/working-with-revisions/", "Watch video on how to work with revisions");

            BuildExistingContents();

            CheckMenuButtons();
            jQuery('.items input[type=checkbox]').change(
                function () {
                    CheckMenuButtons();
                }
            );

            jQuery(".itemCount").live('click',function(){
                
                jQuery(".hiddenItems", jQuery(this).parents(".providerContentsDetails")).toggle(100);
            });

            jQuery("a.toggleCB").click(function(){
                
                var div = jQuery(this).parents(".propertyItem").get(0);


                if (jQuery('input[type=checkbox]', div).filter(':checked').length > 0) {
                    jQuery('input[type=checkbox]', div).attr("checked", "");
                } else {
                    jQuery('input[type=checkbox]', div).attr("checked", "checked");
                }

            });


            jQuery(".deleteItem").live("click", function() {

                jQuery(this).closest('.providerContentsDetails').removeAttr("includeall");
                jQuery(this).closest('.selectedItem').remove();
                SetSelectedContentIDS();

                return false;
            });

            jQuery(".addItems").click(function(){
                var src = "../dialogs/addItemsToLocalRevision.aspx?providerId=" + jQuery(this).attr("rel");
                jQuery.modal('<iframe src="' + src + '" height="470" width="410" style="border:0">');

            });
        });


        function BuildExistingContents()
        {
            if(currentManifest.Providers.length > 0)
            {
                for (var p = 0; p < currentManifest.Providers.length; p++) { 

                    if(currentManifest.Providers[p].Items.length > 0)
                    {
                        var provId = currentManifest.Providers[p].Id;

                        jQuery(".WhatToPackage",jQuery("#"+provId)).val(currentManifest.Providers[p].DependecyLevel);

                        for (var i = 0; i < currentManifest.Providers[p].Items.length; i++) { 
                       
                            var item =  currentManifest.Providers[p].Items[i];
                            var name = item.Name;
                            var id = item.Id;
                            
                            var cur = jQuery('<tr/>').attr("id",item.Id).attr("class", "selectedItem").attr("includeChildren",item.IncludeChildren).appendTo(jQuery("#"+provId +'providerItems'));
                            

                            jQuery('<td/>').attr("class", "name").text(item.Name).appendTo(cur);
                            var td = jQuery("<td/>").appendTo(cur);
                            td.width(70);
                            jQuery('<a/>').attr("class", "deleteItem").attr("href", "#").text("remove").appendTo(td);
                        }

                        if(jQuery("#"+provId + " .selectedItem").size() > 0)
                        {
                            jQuery(".itemCount","#"+provId).text("(" + jQuery("#"+provId + " .selectedItem").size() + " items added)");
                        }
                    }
                }
            
                SetSelectedContentIDS();

            }



        }

        //only enable 'package selected' button once there is something selected
        function CheckMenuButtons() {
            if ('<%= Revision.RevisionCollection.Count()  %>' == 0) {
                jQuery(".classPackageSelected").hide();
                jQuery("#noContents").show();
            }


            if (jQuery('.selectedItem').length > 0) {
                jQuery(".classPackageSelected").show();
            } else {
                jQuery(".classPackageSelected").hide();
            }
        }


        function GotoExtractPage() {
            window.location = 'extractRevision.aspx?revision=<%= Request["revision"] %>';
        }

        function ShowTransferModal() {
            var nodeId = UmbClientMgr.mainTree().getActionNode().nodeId;
            UmbClientMgr.openModalWindow('plugins/courier/dialogs/transferRevision.aspx?revision= <%= Request["revision"] %>', 'Transfer Revision', true, 400, 200);
        }

        function CloseModal()
        {
            jQuery.modal.close();
        }

        function ShowAddItemsModal()
        {
            var src = "../dialogs/addItemsToLocalRevision.aspx";
            jQuery.modal('<iframe src="' + src + '" height="440" width="410" style="border:0">');

        }

        function AddItemsToPackage(providerId,selectAll,items) {
            
            for (var i = 0; i < items.length; i++) { 
               
                var elem = jQuery("div [itemId = '" + items[i].Id + "']"); 

                if(elem == null || jQuery(elem,"#"+providerId).size() == 0)
                {
                    
                    var parentElem = jQuery("#" + providerId + "providerItems");
                   
                    var cur = jQuery('<tr/>').attr("class", "selectedItem").attr("itemId",items[i].Id).attr("includeChildren",items[i].IncludeChildren).appendTo(parentElem);
                    jQuery('<td/>').attr("class", "name").text(items[i].Name).appendTo(cur);
                    var td = jQuery("<td/>").appendTo(cur);
                    td.width(70);
                    jQuery('<a/>').attr("class", "deleteItem").attr("href", "#").text("remove").appendTo(td);                    
                }
                else
                {
                    jQuery(elem ,"#"+providerId).removeAttr("includeChildren");
                    jQuery(elem ,"#"+providerId).attr("includeChildren",items[i].IncludeChildren);
                }
            }            

            if(jQuery("#"+providerId + " .selectedItem").size() > 0)
            {
                jQuery(".itemCount","#"+providerId).text("(" + jQuery("#"+providerId + " .selectedItem").size() + " items added)");
            }
           
            if(selectAll)
            {
                jQuery("#"+providerId).attr("includeAll",selectAll);
                jQuery("input","#"+providerId).attr('checked', true);
            }

            SetSelectedContentIDS();

            CloseModal();
        }

        function SetSelectedContentIDS()
        {
            var ids = "";


            jQuery(".selectedItem").each(function () {

                ids += jQuery(this).attr("itemId") + ";";

            });

            jQuery("#<%= txtSelectedContentIDs.ClientID %>").val(ids);

            UpdateItemCount();
            CheckMenuButtons();
        }

        function UpdateItemCount()
        {
            jQuery(".providerItems").each(function () {

                if(jQuery(".selectedItem",this).size() > 0)
                {
                    jQuery(".itemCount",jQuery(this).parent()).text("(" + jQuery(".selectedItem",this).size() + " items added)");
                }
                else
                {
                    jQuery(".itemCount",jQuery(this).parent()).text("");
                }
            });
        }
        
        function displayStatusModal(title,message)
        {
            //build manifest json
            buildManifestJson();


            var id = $('#statusId').val();

            if (message == undefined)
                message = "Please wait while Courier loads";
            

            UmbClientMgr.openModalWindow('plugins/courier/pages/status.aspx?statusId='+id +"&message="+message, title, true, 500, 450);
        }

        function buildManifestJson()
        {
            var Manifest = {};
            Manifest.Providers = [];

            var providers = new Array();
            var c = 0;
            
            jQuery(".providerContentsDetails").each(function () {
                
                var provId = jQuery(this).attr("id");
                var provIncludeAll = jQuery(this).attr("includeall") ? jQuery(this).attr("includeall") :  false;
                var provDependencyLevel = jQuery(".WhatToPackage",this).val();

                var Items = [];

                jQuery(".selectedItem",this).each(function () {
                    var itemID = jQuery(this).attr("itemId");

                    if(itemID !== ""){
                        var itemName = jQuery(".name",this).html();
                        var itemIncludeChildren = jQuery(this).attr("includechildren") ? jQuery(this).attr("includechildren") :  false;

                        Items.push({
                            "Name": itemName,
                            "Id": itemID,
                            "ProviderId": provId,
                            "IncludeChildren": itemIncludeChildren,
                        }); 
                    }
                });

                if(Items.length > 0)
                {  
                    Manifest.Providers.push({
                        "Id": provId,
                        "IncludeAll": provIncludeAll,
                        "DependecyLevel":provDependencyLevel,
                        "Items": Items,                    
                    });                
                }
            });

            
            jQuery("#manifestJson").val(JSON.stringify(Manifest));
        }

        function packageAll()
        {
            if (!confirm('Are you sure you want to package everything?\r\n\r\nYou can click the Add texts on the right of each row below to add specific items to package.\r\nAnd use the dropdowns to refine even further what is packaged. '))
                return false; 

            //  displayStatusModal('Package all status', 'Please wait while Courier collects all available items and their dependencies'); 
            return true;
        }

        function packageSelected()
        {
            buildManifestJson();

            //  displayStatusModal('Package all status', 'Please wait while Courier collects all available items and their dependencies'); 
            return true;
        }

    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="server">
    <input type="hidden" name="statusId" id="statusId" value="<%= Guid.NewGuid() %>" />
    <input type="hidden" name="manifestJson" id="manifestJson" value="" />


    <umb:umbracopanel id="panel" text="Revision" runat="server" hasmenu="false">

<umb:Pane runat="server" ID="addPane" Text="Select revision content">

    <div class="classPackageSelected" style="float: right; margin-left: 30px; padding: 20px; border-left: #999 1px dotted; text-align: center;">
        <asp:button id="packageSelectedButton" runat="server"  text="Package selected" /><br />
        <small>Only add selected items</small>
    </div>

    <div style="float: right; margin-left: 30px; padding: 20px; border-left: #999 1px dotted; text-align: center;">
        <asp:button id="packageAllButton" runat="server"  text="Package all"  /><br />
        <small>Add everything available</small>
    </div>

    <p>
        Choose from the different types of content below, to select the items you want to include in the this revision.
    </p>

    <p>
        You can choose to automatically add all detected dependecies automaticly, or you can for each individual type of content
        decide the level of inclusion. This gives you great control over what actually gets included and deployed.
    </p>

    

</umb:Pane>

<umb:Pane Text="Current contents" runat="server" ID="paneContents" Visible="false">
    <courier:RevisionContents runat="server" ID="RevisionContents">
    </courier:RevisionContents>

    <p id="noContents" style="display:none;">Currently this revision doesn't contain any contents, please move to the package tab to select and package the desired contents.</p>
</umb:Pane>


<asp:panel runat="server" ID="pnlProviderContents" CssClass="umb-pane">


<div id="prodiderContents">
<asp:Repeater ID="rp_providers" runat="server" >
    <HeaderTemplate>        
        <table class="table">
            <tr>
                <td style="border-top: none;"></td>
                <td style="border-top: none;"></td>
                <td style="border-top: none;width: 250px;">
                    <div id="addProviderContents">
                        <select style="background-color:#DDD;border:1px solid #999" onchange="$('.WhatToPackage').val($(this).val())"><option value="-1">Added + Dependencies</option><option value="0">Selected items only</option><option value="1">Selected + 1 Dependency level</option><option value="2">Selected + 2 Dependency levels</option><option value="3">Selected + 3 Dependency levels</option></select>
                    </div>
                </td>
            </tr>
    </HeaderTemplate>
    <ItemTemplate>
         <tr class="providerContentsDetails" id="<%#((Umbraco.Courier.Core.ItemProvider)Container.DataItem).Id %>">
            <td class="providerName">
                <%#"<img style='position:relative;top:2px;left:-2px;' src='" + umbraco.IO.IOHelper.ResolveUrl(((Umbraco.Courier.Core.ItemProvider)Container.DataItem).ProviderIcon) + "' /> " + ((Umbraco.Courier.Core.ItemProvider)Container.DataItem).Name %>
                <span class="itemCount"></span>
                
                <table 
                    style="margin: 20px;"
                    class="table table-hover table-bordered table-condensed providerItems hiddenItems" 
                    id="<%# ((Umbraco.Courier.Core.ItemProvider)Container.DataItem).Id %>providerItems">
                    
                </table>

            </td>
             <td style="width: 100px;">
                 <button class="addItems" rel="<%# ((Umbraco.Courier.Core.ItemProvider)Container.DataItem).Id %>" onclick="return false;">Add</button>
             </td>
             <td style="width: 250px;">
                 <select name="whatToPackage<%# ((Umbraco.Courier.Core.ItemProvider)Container.DataItem).Id %>" style="background-color:#EEE;border:1px solid #AAA" class="WhatToPackage"><option value="-1">Added + Dependencies</option><option value="0">Selected items only</option><option value="1">Selected + 1 Dependency level</option><option value="2">Selected + 2 Dependency levels</option><option value="3">Selected + 3 Dependency levels</option></select>
             </td>            
         </tr>
            
    </ItemTemplate>
    <FooterTemplate>
        </table>
    </FooterTemplate>
</asp:Repeater>

<div style="display:none;">
<asp:TextBox runat="server" ID="txtSelectedContentIDs"></asp:TextBox>
</div>
</div>

</asp:panel>
</umb:umbracopanel>

</asp:Content>
