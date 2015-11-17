<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="../MasterPages/CourierPage.Master" CodeBehind="ViewTaskManager.aspx.cs" Inherits="Umbraco.Courier.UI.Pages.ViewTaskManager" %>

<%@ Import Namespace="Umbraco.Courier.UI" %>
<%@ Register Namespace="umbraco.uicontrols" Assembly="controls" TagPrefix="umb" %>

<asp:Content ContentPlaceHolderID="head" runat="server">

    <script type="text/javascript">

        var detailsPage = '<%= Umbraco.Courier.UI.UIConfiguration.RevisionViewPage %>';
        var redirect = '<%= Request.QueryString["redirWhenDone"] %>';
        var revision = '<%= Request.QueryString["revision"] %>';

        var isDialog = '<%= Request.QueryString["dialog"]%>';
        var taskId = '<%= Request.QueryString["taskId"]%>';

        var latest = '';

        function showError(message) {
            var div = jQuery("deploy-error");
            div.show();
            if (message) {
                div.find("div.details").html(message);
            }
        }

        function updateTaskList(endpoint, parentDom, pollCallback) {

            var parentList = parentDom.find("ul");
            var show = false;

            jQuery.ajax({
                type: "POST",
                url: "ViewTaskManager.aspx/" + endpoint,
                contentType: "application/json; charset=utf-8",
                dataType: "json",

                success: function (meh) {

                    var list = "<li class='task'>";
                    var render = true;

                    jQuery(meh.d).each(function (index, el) {

                        if (index === 0) {
                            if (latest !== el.UniqueId) {
                                latest = el.UniqueId;
                                render = true;
                            }
                            else
                                render = false;
                        }

                        //var html = "<li class='task " + el.TaskType + "  " + el.State + "'>";
                        var html = "<div class='taskItem taskItem_" + el.State + "'>";
                        html += "<div class='label'><h3><a href='" + (isDialog ? "#" : "viewRevisionDetails.aspx?revision=" + el.RevisionAlias) + "'>" + el.TaskType + "</a></h3><small>" + el.FriendlyName + "</small></div>";


                        if (el.Message != null)
                            html += "<div class='message'>" + el.Message + "</div>";

                        html += "<br style='clear: both'/></div>";
                        list += html;

                        show = true;
                    });
                    list += "</li>";

                    if (render) {
                        parentList.children().remove();
                        parentList.append(list);
                    }
                    if (show)
                        parentDom.show();
                    else
                        parentDom.hide();

                    //call the callback with the result data
                    if (pollCallback) {
                        pollCallback(meh);
                    }

                },
                error: function (x, t, e) {

                    var msg = "<p>Unhandled exception occurred.</p><p>Status: " + x.status + "</p><p>Message: " + x.statusText + "</p>";
                    if (x.responseText && x.responseText.length > 0 && x.responseText[0] === "{") {
                        var jsonError = JSON.parse(x.responseText);
                        msg += "<p>ExceptionType: " + jsonError.ExceptionType + "</p>";
                        msg += "<p>Message: " + jsonError.Message + "</p>";
                        msg += "<p>StackTrace: " + jsonError.StackTrace + "</p>";
                    }
                    else {
                        msg += x.responseText;
                    }
                    showError(msg);
                }

            });
        }

        jQuery(document).ready(function () {

            var retryCount = 0;
            var hasCurrentTaskStatus = true;

            (function updateCurrent() {

                var parentDom = jQuery("#loader");
               
                jQuery.ajax({
                    type: "POST",
                    url: "ViewTaskManager.aspx/GetCurrentTask",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",

                    success: function (meh) {
                        
                        jQuery(meh.d).each(function (index, el) {
                            if (el.TaskType != null) {

                                parentDom.show();
                                parentDom.find(".bar").css("width", el.Progress + "%");

                                if (el.State != null)
                                    parentDom.find("small").text(el.State);
                            }
                        });
                        
                        //re-poll
                        if (meh.d && meh.d.length && meh.d.length > 0) {
                            hasCurrentTaskStatus = true;
                            setTimeout(updateCurrent, 1000);
                        }
                        else {
                            hasCurrentTaskStatus = false;
                            parentDom.hide();
                        }
                    },
                    error: function (x, t, e) {
                        
                        hasCurrentTaskStatus = false;

                        var msg = "<p>Unhandled exception occurred.</p><p>Status: " + x.status + "</p><p>Message: " + x.statusText + "</p>";

                        if (x.responseText && x.responseText.length > 0 && x.responseText[0] === "{") {
                            var jsonError = JSON.parse(x.responseText);
                            msg += "<p>ExceptionType: " + jsonError.ExceptionType + "</p>";
                            msg += "<p>Message: " + jsonError.Message + "</p>";
                            msg += "<p>StackTrace: " + jsonError.StackTrace + "</p>";
                        }
                        else {
                            msg += x.responseText;
                        }

                        showError(msg);
                    }
                });

            })();

            (function updateView() {

                if (retryCount > 10) {
                    showError("Processing cannot continue, maximum retry attempts has been exceeded");
                }
                else {

                    updateTaskList("GetQueue", jQuery("#queue"), function (result) {

                        if (result && result.d && result.d.length !== undefined) {
                            if (result.d.length > 0) {
                                //poll again if there's anything in the queue
                                setTimeout(updateView, 1000);
                            }
                            else {
                                //if there's nothing in the queue, then get remaining processed until 
                                // the task id we are looking for is in the results.
                                // NOTE: since the way this works isn't very ideal and if some other admin is trying
                                // to do this at the same time and the processed tasks are cleared, we could end up in an 
                                // infinite loop. So we'll only retry 10 times and then fail.

                                updateTaskList("GetProcessed", jQuery("#processed"), function (processedResult) {
                                    //if there is no task id to search for and there's nothing processed then there's nothing to do
                                    if (!taskId && processedResult.d && processedResult.d.length !== undefined && processedResult.d.length === 0) {
                                        
                                        showNoTasks();

                                    }
                                    else {
                                        var done = false;
                                        jQuery(processedResult.d).each(function (index, el) {
                                            //if the task id matches, show done message.

                                            if (!taskId || (el.TaskType != null && el.UniqueId == taskId)) {

                                                showDoneMessage(el);
                                                done = true;
                                            }
                                        });
                                        if (!done) {
                                            //try again

                                            //if there is no longer any more current task, then we are just waiting for the task
                                            // to be finalized which should be almost immediate, however we'll need to keep retrying
                                            // until it's there but we'll set a max retry attempt
                                            if (!hasCurrentTaskStatus) {
                                                retryCount++;
                                            }

                                            setTimeout(updateView, 1000);
                                        }
                                    }
                                });
                            }
                        }
                    });

                    //show any that are processed
                    updateTaskList("GetProcessed", jQuery("#processed"));
                }

            })();

        });

        function showNoTasks() {
            jQuery("#notasks").show();
        }

        function showDoneMessage(el) {

            if (isDialog === 'true') {

                if (el.State === "completed") {
                    jQuery(".deploy-success").show();
                }
                else {
                    showError();
                }
            }
            else {
                if (el.State === "completed") {
                    if (redirect === 'true') {
                        self.location = detailsPage + "?revision=" + revision;
                    }
                    else {
                        jQuery(".deploy-success").show();
                    }
                }
                else {
                    showError();
                }
            }
        }
    </script>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="server">

    <umb:umbracopanel text="Taskmanager" runat="server" hasmenu="false" id="pagePanel">

        <div class="umb-pane">
            
            <div id="feedback" style="display: none"></div>

            <div id="loader">
                <div class="progress progress-courier">
                    <div class="bar" style="width: 0%;"></div>
                </div>       
                <small></small>     
            </div>

            <div id="queue" style="display: none;  overflow:auto; height: inherit;">
                <h2 class="propertypaneTitel">Queued tasks</h2>
                <ul class='taskmanager'></ul>
            </div>

            <div id="processed" style="display: none; overflow:auto; height: inherit;">
                <h4>Recently processed tasks</h4>
                <ul class='taskmanager'></ul>
            </div>
            
            <div class="deploy-error" style="display: none">
                <h5 class="text-error">Deployment failed</h5> 
                <p>Deployment of content could not complete due to an unexpected error, all changes have been cancelled</p>
                
                <hr/>

                <div class="details"></div>
                
                <button class="btn btn-primary" onclick='UmbClientMgr.closeModalWindow(); return false;'>Ok</button>   
            </div>
            
            <div id="notasks" style="display: none;  overflow:auto; height: inherit;">
                <h4>No current tasks running</h4>               
            </div>

        </div>
    </umb:umbracopanel>

    <asp:placeholder runat="server" id="dialogPanel" visible="false">
        
        <div class="umb-dialog">
            <div class="umb-pane courierModal">
        
            <div class="deploy-success" style="display: none">
                <h5 class="text-success">Deployment completed</h5>
                <p>All content was transfered to its destination</p>
            
                <button class="btn btn-primary" onclick='UmbClientMgr.closeModalWindow(); return false;'>Ok, great</button>   
            </div>
            
            <div class="deploy-error" style="display: none;">
                <h5 class="text-error">Deployment failed</h5> 
                <p>Deployment of content could not complete due to an unexpected error, all changes have been cancelled</p>
                
                <hr/>

                <div class="details"></div>
                
                <button class="btn btn-primary" onclick='UmbClientMgr.closeModalWindow(); return false;'>Ok</button>   
            </div>

            <div id="loader" style="display: none">
                <h5>Deploying...</h5>
                <p>Please hang on as your content is deployed...</p>

                <div class="progress progress-courier">
                    <div class="bar" style="width: 0%;"></div>
                </div>       
            
                <small></small>     
            </div>
            
        </div>
        </div>

    </asp:placeholder>
    
    

</asp:Content>
