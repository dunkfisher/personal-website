<%@ page language="C#" autoeventwireup="true" masterpagefile="../MasterPages/CourierPage.Master" codebehind="CompareRevision.aspx.cs" inherits="Umbraco.Courier.UI.Pages.CompareRevision" %>

<%@ register namespace="umbraco.uicontrols" assembly="controls" tagprefix="umb" %>

<asp:content contentplaceholderid="head" runat="server">
    
    <script type="text/javascript">

        var target = "<asp:literal id="lt_target" runat="server"/>";
        var revision = "<asp:literal id="lt_name" runat="server"/>";

        $(document).ready(function () {
            
            AppendHelp("h2.propertypaneTitel", "/umbraco-pro/courier/courier-25-compare-and-deploy", "Watch video on how to work with revisions");

            jQuery('.openProvider').click(function () {
                $(this).closest('.revisionItemGroup').find('.revisionItems').show(100);
                $(this).closest('h3').find('.openProvider').hide();
                $(this).closest('h3').find('.allDependencies').show();
                $(this).closest('h3').find('.closeProvider').show();
            });

            jQuery('.closeProvider').hide().click(function () {
                $(this).closest('.revisionItemGroup').find('.revisionItems').hide(100);
                $(this).closest('h3').find('.openProvider').show();
                $(this).closest('h3').find('.allDependencies').hide();
                $(this).closest('h3').find('.closeProvider').hide();
            });


            jQuery('.showHideAll').click(function () {
                $(".revisionItemGroup").show();
                $(".revisionItemGroup li").show();

                $(this).hide();
            });
            
            jQuery("button").click(function(event){
                jQuery(this).text("Please wait..").attr("disabled",true);

                event.preventDefault();
                startDeploy();
            });


            var items = jQuery("ul.revisionItems li");
            getHashFromElement(items, 0);

            var header = "Comparing: " + revision;

            if(target != '')
                header += " with <strong>" + target + "</strong>";
            
            jQuery("#header_h2").html(header);
        });
        
        var warningItemCount = 0;
        var warningItems = "";

        
        

        function startDeploy() {

            var ignoreList = "";
            var items = jQuery('input[type=checkbox]').not(':checked');

            items.each(function (index, value) {
                ignoreList += jQuery(value).attr("id") + "|";
            });
            
            jQuery.ajax({
                type: "POST",
                url: "compareRevision.aspx/Deploy",
                contentType: "application/json; charset=utf-8",
                data: '{"revision":"' + revision + '","ignoreIds":"' + ignoreList + '","destination":"' + target + '"}',
                dataType: "json",

                success: function (meh) {
                    var taskId = meh.d;
                    window.location = "viewtaskmanager.aspx?taskId=" + taskId;
                },
                error: function (meh) {
                    alert(meh.d);
                }
            });
        }

        function getHashFromElement(items, index) {

            if (index < items.length) {

                var item = jQuery(items[index]);
                var provider = item.attr("data-providerId");
                var itemId = item.attr("data-itemId") + "_" + item.attr("data-providerId");

                var providerElement = jQuery("#" + provider + "_holder");
                var currentHash = item.attr("data-hash");
                
                providerElement.find("h3 span").html("<img src='../images/loading.gif' title='loading...' />");
                item.find("span").html("<img src='../images/loading.gif' title='loading...' />");

                jQuery.ajax({
                    type: "POST",
                    url: "compareRevision.aspx/GetHash",
                    contentType: "application/json; charset=utf-8",
                    data: '{"id":"' + itemId + '","destination":"' + target + '"}',
                    dataType: "json",

                    success: function (meh) {
                        var hash = meh.d;
                        //   item.find("b").html(hash);

                        if (hash !== "" && hash === currentHash) {
                            item.find("span").html("Items are identical");
                            item.addClass("ignore");
                            item.find("input").attr("checked",false);
                            item.hide();
                        } else {
                            var response = "<img src='../images/ok.png' title='This item will be created on the target machine' /> Will be updated";
                            var c = "update";

                            if (hash === "") {
                                response = "<img src='../images/ok.png' title='This item will be created on the target machine' /> Will be created";
                                c = "create";
                            }

                            if (hash !== "" && hash !== currentHash) {
                                response = "<img src='../images/ok.png' title='This item will be created on the target machine' /> Will override";
                                c = "update";
                            }

                            item.addClass(c);
                            //   item.find("span").html(response);
                        }

                    },
                    error: function (meh) {
                        item.find("span").html("<img src='../images/error.png' title='could not load hash from the target site' />");
                    },
                    complete: function () {

                        var perc = (index / items.length) * 100;
                        jQuery("#progress .bar span").css("width", perc + "%");
                        jQuery("#progress small").text("comparing: " + item.attr("name"));

                        getHashFromElement(items, index + 1);
                    }
                });
                
            } else {

                jQuery("#progress").hide();
                jQuery("h3 span").html("");
                jQuery(".action").show();
                
                var total_added = 0;
                var total_updated = 0;
                var total_ignored = 0;


                jQuery("div.revisionItemGroup").each(function (index, value) {
                    var el = jQuery(value);

                    var p_added = jQuery("li.create", el).length;
                    var p_updated = jQuery("li.update", el).length;
                    var p_ignored = jQuery("li.ignore", el).length;
                    
                    /*
                    var text = "<small class='meta'>";
                    if(p_added > 0)
                        text += " <b class='create'>" + p_added + "</b>";

                    if(p_updated > 0)
                        text += " <b class='update'>" + p_updated + "</b>";

                    if(p_ignored > 0)
                        text += " <b class='ignore'>" + p_ignored + "</b>";

                    text += "</small>";
                                        
                    el.find("h3 span").html(text);
                    */


                    if (p_added + p_updated == 0)
                        el.hide();

                    total_added += p_added;
                    total_ignored += p_ignored;
                    total_updated += p_updated;
                    
                });

                jQuery("#info_added h3").text(total_added);
                jQuery("#info_updated h3").text(total_updated);
                jQuery("#info_ignored h3").text(total_ignored);
            } 
        }
    </script>
    

    <style type="text/css">
        div.action {
            display: none;
            width: 25%;
            float: left;
            padding: 0 1% 0 1%;
            color: #999;
            font-weight: bold;
        }

        div.mid {
            border-left: #999 1px dotted;
            border-right: #999 1px dotted;
            width: 25%;
            float: left;
        }

        div.button {
            float: right;
            width: auto;
            text-align: center;
        }

            div.button small {
                display: block;
            }

        .action h3 {
            float: left;
            margin: 7px;
            padding-left: 7px;
            margin-top: 0px;
            font-size: 30px;
            line-height: 30px;
            color: #666;
        }

        .action p {
            margin: 0px;
        }

        #progress {
            text-align: center;
            color: #999;
        }

            #progress .bar {
                border: 1px solid #d9d9d9;
                background: #fff;
                height: 12px;
                text-align: left;
            }

                #progress .bar span {
                    background: #2e8aea;
                    height: 12px;
                    display: block;
                    width: 0px;
                }

        .showHideAll {
            font-size: 11px;
            display: inline-block;
            position: absolute;
            right: 10px;
            top: 1px;
        }

        .create {
            color: #007000 !Important;
        }

        .update {
            color: #cf6118 !Important;
        }

        .ignore {
            color: #7f0000 !Important;
        }

        small.meta {
            font-weight: normal;
            padding: 3px;
            margin-left: 2px;
            webkit-border-radius: 3px;
            -moz-border-radius: 3px;
            border-radius: 3px;
            line-height: 0px;
            height: 6px;
            background: #f8f8f8;
        }
    </style>

</asp:content>

<asp:content id="Content2" contentplaceholderid="body" runat="server">
    <umb:UmbracoPanel runat="server" ID="panel" Text="Revision Details">

        <div class="umb-pane">
            <h2 class="propertypaneTitel" style="position: relative; height: 20px;" id="header_h2">Comparing revision: <asp:literal id="lt_name2" runat="server" /></h2>
            <div class="revisionItemBox">
                  <div id="progress">
                        <div class="bar"><span></span></div>
                        <small>Comparing...</small>
                  </div>
        

                   <div class="action" id="info_added">
                       <h3 class="create">0</h3> 
                       <p>Items will be <strong>created</strong><br />
                       <small>These items could not be found during compare</small></p>
                   </div>

                   <div class="action mid" id="info_updated">
                        <h3 class="update">0</h3> 
                        <p>Items will be <strong>updated</strong><br />
                        <small>Items was found, but not identical</small></p>
                   </div>

                   <div class="action" id="info_ignored">
                        <h3 class="ignore">0</h3> 
                        <p>Items will be <strong>ignored</strong><br />
                        <small>Items already exists and looks identical</small></p>
                   </div>


                   <div class="action button">
                        <button class="btn btn-primary">Install revision</button>
                        <small>Installs all checked items</small>
                   </div>

                   <div style="height: 1px; clear: both; visibility: hidden">-</div>
            </div>



            <div class="revisionItems">
                <h2 class="propertypaneTitel" style="position: relative; height: 20px;">Items in this revision:
                    <a class="showHideAll" href="#">Show hidden</a>
                </h2>
    
                <asp:Repeater runat="server" ID="RevisionProviderRepeater" >
                    <ItemTemplate>
                        <div class="revisionItemGroup" id="<%# Eval("Id") %>_holder">
                        <h3><i class="icon <%# GetProviderIcon((Guid)Eval("Id")) %>"></i><%# Eval("Name") %> <span></span> 
                        <div class="openProvider" style="FLOAT: right"><i class="icon icon-navigation-down"></i></div>
                        <div class="closeProvider" style="FLOAT: right"><i class="icon icon-navigation-up"></i></div>
                        </h3>
                           
                        <ul class="revisionItems">
                            <asp:Repeater runat="server" id="rp">
                                <ItemTemplate>
                                    <li class="revisionItem" name="<%#Eval("Name") %>" data-hash="<%#Eval("SourceHash") %>" data-itemId="<%#Eval("ItemId.Id") %>" data-providerId="<%#Eval("ItemId.ProviderId") %>">
                                        <input type="checkbox" checked="checked" id="<%#Eval("ItemId.Id") %>_<%#Eval("ItemId.ProviderId") %>" /><%#Eval("Name") %>
                                    </li>
                                </ItemTemplate>
                            </asp:Repeater>
                        </ul>

                    </div>

                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </umb:UmbracoPanel>
</asp:content>
