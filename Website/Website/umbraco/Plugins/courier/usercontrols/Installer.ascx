<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Installer.ascx.cs" Inherits="Umbraco.Courier.UI.Usercontrols.Installer" %>
<%@ Register Namespace="umbraco.uicontrols" Assembly="controls" TagPrefix="umb" %>
<style type="text/css">
.tvList .tvitem
    {
        font-size: 11px;
        text-align: center;
        display: block;
        width: 130px;
        height: 158px;
        margin: 10px 20px 20px 0px;
        float: left;
        overflow: hidden;
    }
    .tvList a
    {
        overflow: hidden;
        display: block;
    }
    .tvList .tvimage
    {
        display: block;
        height: 120px;
        width: 120px;
        overflow: hidden;
        border: 1px solid #999;
        margin: auto;
        margin-bottom: 10px;
    }
</style>

<script type="text/javascript">
    jQuery(function () {
        jQuery.ajax({
            type: 'GET',
            url: '../../plugins/courier/pages/feedproxy.aspx?url=http://umbraco.com/feeds/videos/courier-installer',
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


<umb:Feedback ID="fb1" runat="server" />

<div style="padding: 10px;">

<asp:PlaceHolder ID="ph" runat="server">
<h3><asp:Literal ID="header" runat="server" /></h3>
<asp:Literal ID="status" runat="server" />
<h3>Add a location</h3>
<p>
	To move changes from one location to another, please enter the domain of another umbraco installation, running Courier 2
</p>
<p>
	<asp:TextBox runat="server" ID="tb_domain" />
</p>
<p>
	<asp:Button runat="server" OnClick="addLocation" Text="Create location" /> 
	<em> or </em> 
    <asp:LinkButton runat="server" OnClick="skipLocation" Text="do it later..." />
</p>
</asp:PlaceHolder>

<asp:PlaceHolder ID="done" runat="server" Visible="false">
<h3>Installation Complete</h3>
<p>
    Courier 2 is now configured on your website. To get the most out of it, we recommend that you
    watch our videos on how to work with Courier 2, available for free on <a href="http://umbraco.tv">umbraco.tv</a>.
</p>

<p>
    <a href="#" onclick="window.parent.location.href = '/umbraco#/courier'; return false;">Open Umbraco Courier</a>
</p>


<h3>Learn how to use Courier 2</h3>
<div id="latestCourierVideos">Loading...</div>
</asp:PlaceHolder>

</div>