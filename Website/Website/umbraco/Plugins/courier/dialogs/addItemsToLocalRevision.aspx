<%@ Page MasterPageFile="../MasterPages/CourierDialog.Master"  Language="C#" AutoEventWireup="true" CodeBehind="addItemsToLocalRevision.aspx.cs" Inherits="Umbraco.Courier.UI.Dialogs.addItemsToLocalRevision" %>
<%@ Register Namespace="umbraco.uicontrols" Assembly="controls" TagPrefix="umb" %>
<%@ Register Src="../usercontrols/SystemItemSelector.ascx" TagName="SystemItemSelector" TagPrefix="courier" %>


<asp:Content ID="Content2" ContentPlaceHolderID="head" runat="server">

    <script type="text/javascript">

        jQuery(document).ready(function () {

            SetSelectedProvider();
            ToggleSelectionTools();

            jQuery("#selectAll").change(function () {
                jQuery("#systemItemSelectorDiv").dynatree("getRoot").visit(function (node) {
                    node.toggleSelect();
                });
                return false;
            });
        });

        function ToggleSelectionTools() {
            if ($(".item").lenght == 0) {
                $("#selectionOptions").hide();
            } else {
                $("#selectionOptions").show();
            }
         }
         
         function SetSelectedProvider() {
                $("#selectedProvider").val($("#<%= ddProviders.ClientID  %>").val());
         }

         var SelectedItems = [];
         function processCheckedNodes(nodes) {
             SelectedItems = [];
             $.each(nodes, function (index, node) {

                 var split = node.data.key.lastIndexOf("_");
                 var id = node.data.key.substring(0, split);

                 split = node.data.parent.lastIndexOf("_");
                 var parent_id = node.data.parent.substring(0, split);
                 var includeChildren = false;

                 if (node.hasChildren() == undefined) {
                     includeChildren = true;
                 }

                 SelectedItems.push({
                     "Name": node.data.title,
                     "Id": id,
                     "ParentId": parent_id,
                     "IncludeChildren": includeChildren
                 });
             });
         }

         function SubmitSelection() {
             var providerId = $("#selectedProvider").val();
             //var selectedItems = jQuery("#selectedItems").val();
             var selectAll = $('#selectAll').is(':checked');

             //submit to parent
             window.parent.AddItemsToPackage(providerId, selectAll, SelectedItems);
         }

    </script>


</asp:Content>


<asp:Content ID="Content1" ContentPlaceHolderID="body" runat="server">

    <umb:Pane runat="server" Text="Select a provider and then which item(s) to include">

    <div id="providerSelection">
    <umb:PropertyPanel runat="server" Text="Provider">
    <asp:DropDownList ID="ddProviders" runat="server" AutoPostBack="true"
            onselectedindexchanged="ddProviders_SelectedIndexChanged">
    </asp:DropDownList>
    </umb:PropertyPanel>
    </div>

    <br style="clear:both" />

    <div id="providerItemsSelector">
        
        <div id="itemList">
            <courier:SystemItemSelector ID="SystemItemSelector" runat="server" />
        </div>

        <div id="selectionOptions">
            <div id="selectAllOption">
                 <input type="checkbox" id="selectAll" value=""/> Select all
            </div>
        </div>
            
    </div>
    </umb:Pane>

    <div id="selectionActions">
        <input type="button" value="Add" id="addItems" onclick="SubmitSelection();return false" />
        or 
        <a href="#" onclick="parent.CloseModal(); return false;">cancel</a>
    </div>

    <input type="hidden" id="selectedProvider" />
    <input type="hidden" id="selectedItems" class="systemItemSelectorTextBox" />
    
</asp:Content>