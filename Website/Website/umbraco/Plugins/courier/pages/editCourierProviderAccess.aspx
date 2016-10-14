<%@ Page Language="C#" MasterPageFile="../MasterPages/CourierPage.Master" AutoEventWireup="true" CodeBehind="editCourierProviderAccess.aspx.cs" Inherits="Umbraco.Courier.UI.Pages.editCourierProviderAccess" %>
<%@ Register Namespace="umbraco.uicontrols" Assembly="controls" TagPrefix="umb" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style type="text/css">
        .propertypane div.propertyItem .propertyItemheader{width: 200px !Important;}
    </style>
</asp:Content>


<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="server">

<umb:UmbracoPanel Text="Courier provider Access" runat="server" hasMenu="true" ID="panel">
    <umb:Pane Text="Provider access" runat="server" ID="phProviderSettings">
        <asp:checkboxlist runat="server" id="cbl_providers" >
        </asp:checkboxlist>
    </umb:Pane>
</umb:UmbracoPanel>

</asp:Content>