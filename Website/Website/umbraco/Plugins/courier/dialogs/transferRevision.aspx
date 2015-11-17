<%@ Page Language="C#" AutoEventWireup="true"  MasterPageFile="../MasterPages/CourierDialog.Master" CodeBehind="transferRevision.aspx.cs" Inherits="Umbraco.Courier.UI.Dialogs.transferRevision" %>
<%@ Register Namespace="umbraco.uicontrols" Assembly="controls" TagPrefix="umb" %>


<asp:Content ID="Content2" ContentPlaceHolderID="head" runat="server">

   <script type="text/javascript">

       function completeTransfer() {
        
        parent.right.document.location.href = "<%= Umbraco.Courier.UI.UIConfiguration.RevisionViewPage %>?revision=<%= Revision %> from <%=Repo %>";

        <% if (Umbraco.Courier.UI.CompatibilityHelper.IsVersion4dot5OrNewer){%>
            UmbClientMgr.closeModalWindow();
        <%}else{%>
            top.closeModal();
       <%}%> 
       
       return false;
       }

       jQuery(document).ready(function () {

       AppendHelp("h2.propertypaneTitel", "/umbraco-pro/courier/courier-25-transfers/", "Watch video on how to transfer a revision");
        
        jQuery("#buttons input").click(function () {
                jQuery("#buttons").hide();
                jQuery(".bar").show();
            }); 
            
           if ('<%= Request["repo"] %>' == '') {
               jQuery("#<%= transfer.ClientID%>").attr("disabled", "true");
           }

           jQuery("#<%= ddRepo.ClientID%>").change(function () {

               jQuery("option:selected", jQuery(this)).each(function () {
                   if (jQuery(this).val() == "") {
                       jQuery("#<%= transfer.ClientID%>").attr("disabled", "true");
                   }
                   else {
                       jQuery("#<%= transfer.ClientID%>").removeAttr("disabled");
                   }
               });

           });

       });

   </script>

</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="body" runat="server">

<asp:Placeholder runat="server" ID="settings">
<umb:Pane Text="Transfer revision" runat="server" ID="paneTransfer">
     
    <p><asp:Literal runat="server" ID="litTransferHelp"></asp:Literal></p>

    <umb:PropertyPanel ID="ppRepo" runat="server" Text="Source" Visible="false"> <%= Request.QueryString["repo"] %></umb:PropertyPanel>
    <umb:PropertyPanel ID="ppFolder" runat="server" Text="Folder"><%= Request.QueryString["folder"]%></umb:PropertyPanel>
    <umb:PropertyPanel ID="ppRevision" runat="server" Text="Revision">"<%= Revision %>"</umb:PropertyPanel>
    
    <umb:PropertyPanel ID="ppReposelection" runat="server" Text="Target">
             <asp:DropDownList ID="ddRepo" runat="server">
             </asp:DropDownList>
    </umb:PropertyPanel>
</umb:Pane>



<div id="buttons">
<p>
<asp:Button ID="transfer" runat="server" Text="Transfer" onclick="inittransfer"></asp:Button>
<em><%= umbraco.ui.Text("or") %></em> <a href="#" onclick="<% if (Umbraco.Courier.UI.CompatibilityHelper.IsVersion4dot5OrNewer){%>UmbClientMgr.closeModalWindow()<%}else{%>top.closeModal()<%}%>; return false;"><%= umbraco.ui.Text("cancel") %></a>
 </p>
</div>

<div class="bar" style="display: none" align="center">
        <img src="/umbraco_client/images/progressbar.gif" alt="loading" /><br />
        <small>Transfering revision items...</small>
</div>


</asp:Placeholder>


<asp:Placeholder runat="server" ID="success" visible="false">

<div class="success">
<p>The transfer has been completed.</p>
</div>

<p>
<button onclick="completeTransfer(); return false;">Close</button>
</p>
</asp:Placeholder>
</asp:Content>