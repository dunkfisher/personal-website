<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CourierDashboard.ascx.cs" Inherits="Umbraco.Courier.UI.Dashboard.CourierDashboard" %>
<%@ Register Namespace="umbraco.uicontrols" Assembly="controls" TagPrefix="umb" %>

<style type="text/css">
    
    .cour-dash h2 {
        font-size: 26px;
        margin-bottom: 15px;
        font-weight: bold;
    }

    .cour-dash h3 {
        font-size: 16px;
        font-weight: bold;
        margin: 0 0 8px 0;
    }

    .cour-dash h2, .cour-dash h3 {
        line-height: 1.3;
    }

    .cour-dash p {
        font-size: 14px;
        line-height: 1.5;
        max-width: 960px;
    }

    .cour-dash a, .cour-dash a:visited {
        color: #2e8aea;
    }

    .cour-dash a:hover {
        color: #2078C4;
        text-decoration: none;
    }

    .cour-dash-info {
        margin-bottom: 20px;
    }

    .cour-dash label {
        font-size: 12px;
    }

    .cour-dash input[type="text"], .cour-dash input[type="password"] {
        padding: 8px;
    }

    .cour-dash input[type="submit"] {
        margin-top: 20px;
        display: block;
        padding: 15px 50px;
        font-size: 14px;
        color: white;
        background: #2e8aea;
        border: 0;
        outline: none;
    }

    .cour-dash input[type="submit"]:hover {
        background: #2078C4;
    }

    .cour-dash-res {
        margin-top: 20px;
        padding-top: 20px;
        border-top: 1px solid #f8f8f8;
    }

    .cour-dash-res h2 {
        font-size: 20px;
        margin-bottom: 10px;
        line-height: 1;
    }

    .cour-dash-res h4 {
        font-size: 14px;
        font-weight: bold;
    }

    .cour-dash-res ul {
        margin: 0 0 0 10px;
        display: table;
    }

    .cour-dash-res li {
        font-size: 14px;
        list-style: none;
        display: table-row;
    }

    .cour-dash-res li:before {
        content: "-";
        position: relative;
        left: -10px;
        display: inline-block;
        height: 100%;
        display: table-cell;
        text-align: right;
    }

    .cour-dash-res li a, .cour-dash-res li a:visited {
        color: #2e99f4;
        display: block;
        margin-bottom: 4px;
    }

    .cour-dash-res li a:hover {
        color: #2078C4;
        text-decoration: none;
    }

    .cour-dash-chap .umb-pane {
        margin: auto 0;
    }

    .cour-dash-chap p {
        font-size: 14px;
        line-height: 1.5;
        max-width: 960px;
        margin-bottom: 20px;
    }

    .cour-dash-chap .umb-abstract {
         font-size: 20px;
         color: #000;
    }




    .tvList .tvitem {
        font-size: 11px;
        text-align: center;
        display: block;
        width: 130px;
        height: 170px;
        margin: 0px 20px 20px 0px;
        float: left;
        overflow: hidden;
    }

    .tvList a {
        overflow: hidden;
        display: block;
        color: #2e99f4;
        font-size: 12px;
        line-height: 1.3;
        text-align: left;
    }

    .tvList a:hover {
        color: #2078C4;
        text-decoration: none;
    }

    .tvList .tvimage {
        display: block;
        height: 120px;
        width: 120px;
        overflow: hidden;
        border: 1px solid #cecece;
        margin: auto;
        margin-bottom: 10px;
    }

</style>

<script type="text/javascript">

    jQuery(document).ready(function () {

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

<asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

<umb:Feedback ID="expressNotice" runat="server" />   

<umb:Pane ID="register" runat="server" Visible="false">  
    <div class="cour-dash">
    <h2>Thank you for trying out Umbraco Courier 2</h2>
        
    <!-- <h3>To purchase a license</h3> -->
        <p class="cour-dash-info"> To purchase this product, simply go to the <a target="_blank" href="http://umbraco.org/redir/<%= Umbraco.Courier.Core.Licensing.InfralutionLicensing.LICENSE_PRODUCTNAME %>">
            Umbraco.com site</a> and you're up and running in minutes!
            
        If you've already purchased a license, you can install it 
            automatically by using your <strong>Umbraco.com profile credentials</strong> below.</p>
            
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
            <umb:Feedback ID="licenseFeedback" runat="server" />
            <asp:Panel ID="licensingLogin" runat="server">
                        <label>E-mail</label>
                        <asp:TextBox ID="login" CssClass="guiInputText guiInputStandardSize" runat="server"></asp:TextBox>
                        <label>Password</label>
                        <asp:TextBox ID="password" TextMode="Password" CssClass="guiInputText guiInputStandardSize" runat="server"></asp:TextBox>

                    <p>
                        <asp:Button ID="getLicensesButton" runat="server" Text="Get my licenses" OnClick="getLicensesButton_Click" />  
                    </p>
            </asp:Panel>
                
            <asp:Panel ID="listLicenses" runat="server" Visible="false">
                    <umb:PropertyPanel runat="server">
                        <h4>
                            Following licenses was found via your profile on umbraco.org:
                        </h4>
                        <p>    
                        <asp:RadioButtonList ID="licensesList" runat="server" />
                        </p>                        
                        <p>
                        <asp:Button ID="chooseLicense" runat="server" Text="Use or configure this license" OnClick="chooseLicense_Click" />
                        </p>
                    </umb:PropertyPanel>
            </asp:Panel>
                
            <asp:Panel ID="configureLicense" runat="server" Visible="false">
                   
                    <umb:PropertyPanel ID="PropertyPanel7" runat="server">
                    <p><strong>Please choose the domain that should be used for this license (without www - for instance 'mysite.com')</strong></p>
                    <p>Any subdomain will work with this license, ie. 'www.mysite.com', 'dev.mysite.com', 'staging.mysite.com'. In addition 'localhost' will always work.</p>
                    </umb:PropertyPanel>
                    
                    <umb:PropertyPanel runat="server" text="Domain">
                        <asp:TextBox ID="domainOrIp" CssClass="guiInputText guiInputStandardSize" runat="server"></asp:TextBox><br />
                   
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ControlToValidate="domainOrIp" runat="server" ErrorMessage="Please enter a domain"></asp:RequiredFieldValidator>
                    </umb:PropertyPanel>
                    
                    <umb:PropertyPanel runat="server" Text=" ">
                        <p>
                            <asp:Button ID="generateLicenseButton" runat="server" Text="Generate and save license" OnClick="generateLicense_Click" />
                        </p>
                    </umb:PropertyPanel>
            </asp:Panel>                
               
            </ContentTemplate>
        </asp:UpdatePanel>        
    </div>
</umb:Pane>

<umb:Pane ID="welcome" runat="server" Visible="true">

    <div class="cour-dash-res">
    <h2>Courier 2 Resources</h2>

    <div class="row">
    <div class="span4">        
        <h4>
            Installation resources
        </h4>
        <div>
                <ul>
                    <li><a href="http://nightly.umbraco.org/UmbracoCourier/Installation%20and%20Configuration.pdf" target="_blank">Initial setup and configuration</a></li>
                    
                    <li><a href="http://umbraco.com/help-and-support/video-tutorials/umbraco-pro/courier" target="_blank">Introduction videos</a></li>

                    <li><a href="http://umbraco.com/help-and-support/customer-area/courier-2-support-and-download" target="_blank">Support area on Umbraco.com</a></li>
                                        
                    <li><a href="<%= Umbraco.Courier.UI.UIConfiguration.BugSubmissionURL %>" target="_blank">Report issues</a></li>
                </ul>
        </div>
    </div>

    <div class="span4">
            <h4>Developer resources</h4>
        <div>
                <ul>
                    <li><a href="http://nightly.umbraco.org/UmbracoCourier/Developer%20Docs.pdf" target="_blank">Developer documentation</a></li>

                    <li><a href="http://umbraco.com/pro-downloads/courier2//Sample%20Itemprovider.pdf" target="_blank">Sample ItemProvider API documentation</a></li>

                    <li><a href="http://umbraco.com/help-and-support/customer-area/courier-2-support-and-download/developer-documentation" target="_blank">Sample Sourcecode</a></li>

                    <li><a href="http://nightly.umbraco.org/umbracoCourier" target="_blank">Courier 2, nightly builds</a></li>
                                        
                    <li><a href="http://nightly.umbraco.org/umbracoCourier/changes.txt" target="_blank">List of recent changes</a></li>
                </ul>
        </div>        
    </div>

            <div class="span4">
            <h4>Licensing and product info</h4>
        <div>
                <ul>
                    <li><a href="http://umbraco.com/products/more-add-ons/courier-2" target="_blank">Courier 2 on umbraco.com</a></li>

                    <li><a href="http://umbraco.com/profile/options/manage-licenses" target="_blank">Your product licenses</a></li>

                    <li><a href="http://umbraco.com/profile/options/manage-licenses/license-support" target="_blank">License helpdesk</a></li>
                </ul>
        </div>        
    </div>
</div>
    
</umb:Pane>

    <div class="cour-dash-chap">
    
    <umb:Pane ID="p_info" runat="server" Text="More Courier 2 TV Chapters">
        <p>
            With Courier 2, you simply right-click any piece of content or data in the Umbraco tree
            and click "courier" to deploy it. Watch the videos below on deployment with Courier 2 Express, or
            dive into the many additional options the full version of Courier 2 gives you.
        </p>
    
    <div id="latestCourierVideos">Loading...</div> 

    </umb:Pane>
    
    </div>









