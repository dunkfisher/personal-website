<%@ Page MasterPageFile="../MasterPages/CourierDialog.Master" Language="C#" AutoEventWireup="true"
    CodeBehind="CommitItem.aspx.cs" Inherits="Umbraco.Courier.UI.Dialogs.CommitItem" %>
<%@ Register Namespace="umbraco.uicontrols" Assembly="controls" TagPrefix="umb" %>


<asp:Content ID="Content2" ContentPlaceHolderID="head" runat="server" Visible="false">
    
    <script type="text/javascript" src="../scripts/RevisionJsonRender.js"></script>
    
    <style type="text/css">
        .groupWarning h3{color: #9d261d;}
        .groupWarning .help-block {color:  #9d261d;}
    </style>    

    <script type="text/javascript">

        var tb_ChildItemIDs;
        var ul_selectTedList;

        jQuery(document).ready(function () {
            jQuery("#buttons input").click(function () {
               jQuery("#buttons").hide();
                    jQuery(".bar").show();
                    var msg = jQuery("#loadingMsg").html();
                    if (msg != '')
                        jQuery(".bar").find("small").text(msg);
            });
        });

        function SetSelectedChildren() {
            var ids = "";
            jQuery(".itemchb::checked").each(function () {
                ids += jQuery(this).attr("id") + ";";
            });
            selectedChildItems.val(ids);
        }


        function updateResources(s_root, parentDom) {
            jQuery.ajax({
                type: "POST",
                url: "CommitItem.aspx/GetFilesAndFolders",
                data: "{'root':'" + s_root + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",

                success: function (meh) {

                    parentDom.children().remove();

                    var list = "<ul>";

                    jQuery(meh.d).each(function (index, domEle) {
                        var html = "";
                        if (domEle.Type == "file")
                            html = "<li class='file'><a href='#' onClick='addFile(\"" + domEle.Path + "\",\"" + domEle.Name + "\"); return false;'>" + domEle.Name + "</a></li>";
                        else
                            html = "<li class='folder'><a href='#'onClick='addFolder(\"" + domEle.Path + "\",\"" + domEle.Name + "\"); return false;'>" + domEle.Name + "</a><span><img class='expand' onclick='updateResources(\"" + domEle.Path + "\", jQuery(this.parentNode)); return false;' src='/umbraco/images/nada.gif'/></span></li>";

                        list += html;
                    });

                    list += "</ul>";

                    parentDom.append(list);
                }
            });
        }


        function remove(elm, path) {
            var list = tb_ChildItemIDs.val().replace(path, "").replace("||", "|");
            tb_ChildItemIDs.val(list);
            jQuery(elm).parent().remove();
        }

        function startPollingForUpdates() {
            jQuery("#buttons").hide();

            (function update() {

                setTimeout(function () {
                    updateCurrent('<%=SnapShotDirectory%>', '<%=Target%>', update);
                }, 1000);
            })();
        }
    </script>
</asp:Content>


<asp:Content ID="Content1" ContentPlaceHolderID="body" runat="server">
    <div class="courierModal">
        

    <umb:Pane runat="server" ID="paneNoRepositoriesAvailable" Text="No Locations available"
        Visible="false">
        <p>Please set a valid Location (as a target for this transfer).</p>
        <p>To create a target, add a Location from the Courier section.  <a target="_blank" href="http://umbraco.com/help-and-support/video-tutorials/umbraco-pro/courier/setting-up-courier-2-locations">Watch a video</a> about setting up Locations</p>
     </umb:Pane>
 

    <umb:Pane runat="server" ID="paneSelectItems" Visible="false">
        <script type="text/javascript">
            var cb_all;
            var dest_ddl;
            var selectedChildItems;

            function processCheckedNodes(nodes) {
                selectedChildItems = jQuery(".systemItemSelectorTextBox");

                var nodesAsString = "";

                jQuery.each(nodes, function (index, node) {
                    
                    var key = node.data.key;
                    if (node.hasChildren() == undefined) {
                        key = "$" + key;
                    }

                    nodesAsString += key + ";"
                });

                selectedChildItems.val(nodesAsString);
            }

            jQuery(document).ready(function () {
  
                jQuery(".itemchb").change(function () {
                    SetSelectedChildren();
                });
            });

        </script>

        <h5>Deploy selected node</h5>

        <asp:placeholder runat="server" id="phSelectDestination" visible="false">
            <p>Please choose where the selected node should be transfered to below</p>
            <asp:dropdownlist runat="server" id="stepOneDDl" cssclass="destinationDDL" />
        </asp:placeholder>
                
        <asp:placeholder runat="server" id="phdefaultDestination" visible="false">
            <p>This will deploy the selected node to <strong><asp:literal id="ltDestination" runat="server" /></strong></p>
        </asp:placeholder>
        
        <asp:placeholder runat="server" id="phChildSelection" visible="false">
            
            <p>
               Should all pages below this one be included in the deploy, or is it only this single node you want to deploy?
            </p>
           
            <hr/>
            
            <label><asp:checkbox runat="server" ID="cbTransferAllChildren" Checked="false"></asp:checkbox> Include all nodes below this one </label>   
             
        </asp:placeholder>
        
        <div id="loadingMsg" style="display: none; overflow: hidden; width: 100%" >
                <div class="umb-loader"></div>
                <small>Preparing deployment, please wait...</small>
        </div>        

        <div id="buttons">
            <asp:button runat="server" text="Continue" cssclass="btn btn-primary" onclick="oneSteptransfer"/>
        </div>     
    </umb:Pane>
        

    <asp:Panel runat="server" ID="paneConfirm" Visible="false" style="overflow:auto; height:inherit;">

        <script type="text/javascript">
            jQuery(document).ready(function () {
                startPollingForUpdates();
            });
        </script>


        <div id="loader">
            <h5>Collecting...</h5>
            <p>Please hang on as your content is collected...</p>

            <div class="progress progress-courier">
                <div class="bar" style="width: 0%;"></div>
            </div>       
            
            <small></small>     
        </div>
        
        <div id="deployError" style="display: none;">
            <h5>Something went wrong :(</h5>
            <p>Here is some technical information that might help shed some light on whats happened:</p>

            <p class="text-error"><strong>Message:&nbsp;</strong><small id="errMsg"></small></p>
            <p><strong>Exception Message:&nbsp;</strong><small id="errExceptionMsg"></small></p>
            <p><strong>Exception Type:&nbsp;</strong><small id="errType"></small></p>
            <p><strong>Stack Trace:&nbsp;</strong><small id="errStackTrace"></small></p>

        </div>

        <div id="revisionTabview" style="display: none; height:auto; overflow:auto; max-height: 500px">
            <asp:panel id="ph_revision" runat="server">
                <h5>Items to be deployed</h5>    
                <div id="revision"></div>
            </asp:panel>

            <asp:panel id="ph_resources" runat="server">
                <h5>Files to be deployed</h5> 
                <div id="resources"></div>
            </asp:panel>

            <br style="clear: both" />
            
            <span style="display: none">
                <asp:textbox id="tb_uncheckedItems" cssclass="tb_uncheckedItems" runat="server" textmode="multiline" />
                <asp:textbox id="tb_uncheckedResources" cssclass="tb_uncheckedResources" runat="server" textmode="multiline" />    
            </span>
        </div>

        <div id="loadingMsg" style="display: none; overflow: hidden; width: 100%" >
            <div class="umb-loader"></div>
            <small>Starting deployment...</small>
        </div>
        
        <div id="buttons">
            <asp:button runat="server" text="Deploy" cssclass="btn btn-primary" onclick="startDeploy"/>
        </div>  

    </asp:Panel>

    </div>
    
</asp:Content>
