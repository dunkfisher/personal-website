<%@ Page Language="C#" MasterPageFile="../MasterPages/CourierPage.Master" AutoEventWireup="true" CodeBehind="LicenseError.aspx.cs" Inherits="Umbraco.Courier.UI.Pages.LicenseError" %>

<%@ Register Namespace="umbraco.uicontrols" Assembly="controls" TagPrefix="umb" %>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="server">

    <script type="text/javascript">

        jQuery(document).ready(function () {

            jQuery("#errSubmit").click(function () {
                var err = jQuery("#errorText").html();
                $.post("http://umbraco.com/base/issueTracker/Courier2.aspx", { error: err });

                jQuery(this).after("<strong>Thanks!</strong>").hide();

                return false;
            });
        });
    </script>

    <umb:umbracopanel id="panel1" text="Courier, License Error" runat="server" hasmenu="false">

        <umb:Pane runat="server" Text="License error" ID="pane1">

            <asp:literal runat="server" id="errorHeader" />

            <asp:placeholder runat="server" id="licenseIntro">
                <p>
                   <strong>Hello, you are currently trying to run a part of Courier which is not included in your current Courier license.</strong>
                </p>

                <p>
                    There can be multiple reasons for this, but the most common one, is that you are using a Courier Expres license instead of the full version.
                    Using an express license, means that you cannot:
                </p>
                <ul>
                    <li>If using a <strong>trial</strong>, you can only transfer content to locations on your local machine</li>
                    <li>Use the dedication Courier section</li>
                    <li>Call the Courier API from your own code</li>
                    <li>Add your own providers or data resolvers</li>
                </ul>

                <p>
                    You can resolve this, by puchasing a full license on <a href="http://umbraco.com">umbraco.com</a>
                </p>
            </asp:placeholder>

            <asp:placeholder id="licenseInfo" runat="server" visible="false">
        
            <h3>
                License Information
            </h3>
                <strong>Owner:</strong>
                <ul>
                    <li>Company: <asp:literal id="company" runat="server" /> </li>
                    <li>Product name and version: <asp:literal id="product" runat="server" /></li>
                    <li>Serial: <asp:literal id="serial" runat="server" /></li>
                </ul>

                <strong>Restrictions:</strong>
                <ul>
                    <asp:literal id="rest" runat="server" />
                </ul>
            </asp:placeholder>

            <asp:placeholder id="errorInfo" runat="server" visible="false">
                
                <p>Error details</p>
                <div id="errorText" style="background: #fff; border: 1px solid #efefef; height: 200px; overflow: auto; padding: 10px;">
                    <code style="border: none; background-color: inherit;">    
                        <asp:literal runat="server" id="errorMsg" />
                    </code>        
                </div>

                <br/>
                <button id="errSubmit">Submit error to umbraco.com</button>

            </asp:placeholder>
    </umb:Pane>

</umb:umbracopanel>

</asp:Content>
