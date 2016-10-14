<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="../MasterPages/CourierPage.Master"  CodeBehind="ViewRepositories.aspx.cs" Inherits="Umbraco.Courier.UI.Pages.ViewRepositories" %>
<%@ Import Namespace="Umbraco.Courier.UI" %>
<%@ Register Namespace="umbraco.uicontrols" Assembly="controls" TagPrefix="umb" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
       
</asp:Content>


<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="server">

<umb:UmbracoPanel Text="Location" runat="server" hasMenu="false" ID="panel">

<umb:Pane Text="Result" runat="server" ID="paneResult" Visible="false">
    <asp:Literal runat="server" Id="txtResult"/>
</umb:Pane>

<umb:Pane Text="Available locations" runat="server" ID="paneRepoRevisions">
    <asp:repeater runat="server" id="rp_revisions">
        <headerTemplate>
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Type</th>
                    </tr>
                </thead>    
                <tbody>
        </headerTemplate>

        <itemtemplate>                        
            <tr>
                <td>
                    <span class="folderItem">
                        <ins class="<%=UIConfiguration.RepositoryTreeIcon %>"></ins>
                        <a href="<%= UIConfiguration.RepositoryEditPage%>?repo=<%# Eval("Alias") %>"><%# Eval("Name")%></a>
                    </span>
                </td>
                <td>
                    <small><%# Eval("Provider.Name")%></small>
                </td>
            </tr>
        </itemtemplate>

        <footerTemplate>
            </tbody>            
            </table>
        </footerTemplate>
    </asp:repeater>
</umb:Pane>

</umb:UmbracoPanel>

</asp:Content>
