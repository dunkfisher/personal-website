function updateCurrent(g, target, checkAgainCallback) {

    var parentDom = jQuery("#loader");
    var parentList = parentDom.find("ul");

    var show = false;

    jQuery.ajax({
        type: "POST",
        url: "CommitItem.aspx/GetTask",
        contentType: "application/json; charset=utf-8",
        data: '{"id":"' + g + '"}',
        dataType: "json",

        success: function (meh) {
            parentList.children().remove();
            var list = "";

            jQuery(meh.d).each(function (index, el) {
                if (el.TaskType != null) {

                    if (el.State === "completed" || el.State === "error") {
                        
                        if (el.State === "completed")
                            loadRevision(g, target);
                        else
                            loadError(el);
                    }
                    else {

                        var html = "<li class='task " + el.TaskType + "'>";
                        var date = new Date(parseInt(el.TimeStamp.substr(6)));
                        var name = el.RevisionAlias;

                        html += "<div class='cou-progress' style='width: 100%'><div class='bar'><span style='width: " + el.Progress + "%;'></span></div><small>" + el.State + "</small></div>";

                        if (el.Message != null)
                            html += "<div class='message'>" + el.Message + "</div>";

                        html += "<br style='clear: both'/></li>";
                        list += html;

                        show = true;

                        //call the continuation callback if we're not done
                        if (checkAgainCallback) {
                            checkAgainCallback();
                        }
                        
                    }
                }
            });

            parentList.append(list);
        },
        error: function (x, t, e) {
            jQuery("#loader").hide();
            var jsonError = JSON.parse(x.responseText);
            jQuery("#errMsg").html(x.statusText);
            jQuery("#errExceptionMsg").html(jsonError.Message);
            jQuery("#errType").html(jsonError.ExceptionType);
            jQuery("#errStackTrace").html(jsonError.StackTrace);            
            jQuery("#deployError").show();
        }
    });

}


var loadedProviders = 0;
var totalProviders = 0;
var runningHashes = false;
var itemsToHash = [];

function loadError(el) {
    jQuery("#loader").hide().after("<h2 class='propertypaneTitel'>Error during packaging:</h2><div class='error'><p>" + el.State + ":" + el.Message + "</p></div>");
}

function loadRevision(g, target) {

    jQuery("#loader").hide();
    var parentList = jQuery("#revision");
    var resourceList = jQuery("#resources");

    var tabView = jQuery("#revisionTabview");
    var tabViewContainerId = jQuery("div", tabView).attr("id");


    jQuery.ajax({
        type: "POST",
        url: "CommitItem.aspx/GetRevision",
        contentType: "application/json; charset=utf-8",
        data: '{"id":"' + g + '"}',
        dataType: "json",
        async: false,

        success: function (meh) {
            parentList.children().remove();

            tabView.show();

            var providers = jQuery(meh.d);
            totalProviders = providers.length;
            
            if(totalProviders == 0){
                var html = '<h3>No changes found</h3><p>Your current selection did not contain any changes, there is therefore no items in this deployment, and you can safely close this window</p>';
                    html += '<p><a href="' + window.location.href + '&force=true">Deploy anyway</a></p>';
                parentList.append(html);
            }

            providers.each(function (index, el) {
                var isLast = (providers.length - 1) <= index;
                renderProvider(el, parentList, g, isLast);
            });

        }
    });


    getHashFromElement(itemsToHash, 0, target);
    
    collectSelectedItems();
    collectSelectedResources();
    collectBlockedItems();    
    

    jQuery.ajax({
        type: "POST",
        url: "CommitItem.aspx/GetResources",
        contentType: "application/json; charset=utf-8",
        data: '{"id":"' + g + '"}',
        dataType: "json",
        async: false,

        success: function (meh) {

            jQuery(meh.d).each(function (index, el) {
                var html = '<div class="revisionItemGroup">';
                html += '<ul class="resourceItems" style="margin: 0px; padding: 0px">';

                jQuery.each(el.Resources, function (index, value) {
                    var checked = "checked";
                    var disabled = "";
                    var message = "";

                    html += '<li class="revisionItem" id="li_' + value.Type + '"><input onclick="collectSelectedResources();" type="checkbox" ' + checked + ' ' + disabled + ' id="' + value.Path + '" rel="' + value.Path + '" /> <label for="' + value.Path + '">' + value.Path + ' </label><br/></li>';
                });

                html += '</ul>';
                html += '</div>';

                resourceList.append(html);
            });
        }
    });

}


function collapse(bt) {
    $(bt).closest('.revisionItemGroup').find('.revisionItems').hide(100);
    $(bt).closest('h3').find('.expand').show();
    $(bt).closest('h3').find('.allDependencies').hide();
    $(bt).closest('h3').find('.collapse').hide();
}

function expand(bt) {
    $(bt).closest('.revisionItemGroup').find('.revisionItems').show(100);
    $(bt).closest('h3').find('.expand').hide();
    $(bt).closest('h3').find('.allDependencies').show();
    $(bt).closest('h3').find('.collapse').show();
}

function collectSelectedItems() {
    var ids = "";

    $('#revision input[type=checkbox]').not(':checked').each(function (index, el) {
        ids += jQuery(el).attr("rel") + ";";
    });

    jQuery(".tb_uncheckedItems").val(ids);
}


function collectBlockedItems() {
    var ids = $('#revision .groupblocked input').length;
    var container = jQuery("#revision");

    if (ids > 0) {
        container.prepend("<div class='error'><p>This transfer requires " + ids + " items, you do not have permission to deploy. Courier is currently determining if these are needed. Please wait...</p></div>");
    } else {
        jQuery("#buttons").show();
    }
}

function evalBlockedItems() {
    var ids = $('#revision .groupblocked input').length;
    var container = jQuery("#revision .error");

    if (warningItemCount > 0) {
        container.html("<p>This transfer is not possible as <strong>" + warningItemCount + "</strong> required items are not available on the destination website. <strong>Please contact an administator to get the marked items below transfered</strong></p>");
    } else {
        container.removeClass("error");
        container.addClass("success");
        container.html("<p>This transfer has been deemed safe to transfer, click 'continue' below to start the transfer</p>");

        jQuery("#buttons").show();
    }
}

function collectSelectedResources() {
    var ids = "";

    $('#resources input[type=checkbox]').not(':checked').each(function (index, el) {
        ids += jQuery(el).attr("rel") + ";";
    });

    jQuery(".tb_uncheckedResources").val(ids);
}

function toggleCheckboxes(link) {
    var checkBoxes = jQuery(link).parents("ul").find("input").not(':disabled');
    checkBoxes.attr("checked", !checkBoxes.attr("checked"));
}


function renderProvider(provider, parentList, revisionAlias, isLast) {
    var typeClass = "";

    if (provider.Mandatory == "true")
        typeClass = "mandatoryProvider";

    var html = '<div id="' + provider.Id + '_holder" class="revisionItemGroup group' + provider.Status + ' ' + typeClass + '">';
    html += '<h3 style="background-image: url(' + provider.Icon + ');">' + provider.Name + " (" + provider.Items + ") <span><img src='../images/loading.gif' /></span>";
    html += '<img src="/umbraco/images/expand.png" class="expand" onclick="expand(this);" style="FLOAT: right"/>';
    html += '<img src="/umbraco/images/collapse.png" class="collapse" onclick="collapse(this);" style="FLOAT: right; display: none;"/>';
    html += '</h3>';

    html += '<ul class="revisionItems" id="' + provider.Id + '">';
    html += "<li><small><a href='#' onclick='toggleCheckboxes(this); return false;'>toggle all</a></small></li>";
    html += '</ul>';
    html += '</div>';

    parentList.append(html);
    
    loadProviderItems(provider, revisionAlias, parentList, isLast);
}


function loadProviderItems(provider, revisionAlias, isLast) {

    var html = "";

    jQuery.ajax({
        type: "POST",
        url: "CommitItem.aspx/GetProviderItems",
        contentType: "application/json; charset=utf-8",
        data: '{"providerId":"' + provider.Id + '","revision":"' + revisionAlias + '"}',
        dataType: "json",
        async: false,

        success: function (meh) {

            var ulId = "ul#" + provider.Id;
            var items = meh.d;

            jQuery(meh.d).each(function (index, el) {
                jQuery(ulId).append(renderProviderItem(provider.Status, el));


                if (provider.Mandatory == "true") {
                    el.providerId = provider.Id;
                    itemsToHash.push(el);
                }

                if (index - 1 >= items.length)
                    loadedProviders++;

            });
        }
    });


    jQuery("#" + provider.Id + "_holder h3 span").html("<img src='../images/ok.png' title='This item already exist on the target machine' />");
}


function renderProviderItem(status, value) {
    var html = "";

    var checked = "checked";
    var disabled = "";
    var message = "";

    if (status != "ok") {
        checked = "";
        disabled = "disabled='disabled'";
        message = "<img src='../images/warning.png' title='You do not have permission to transfer this item' />"; ;
    }

    html += '<li class="revisionItem item' + status + '" id="li_' + value.id + '"><input onclick="collectSelectedItems();" title="' + value.n + '" type="checkbox" ' + checked + ' ' + disabled + ' id="' + value.id + '" rel="' + value.id + '" /> <label for="' + value.id + '">' + value.n + ' <span>' + message + '</span></label><br/></li>';

    return html;
}


var warningItemCount = 0;
var warningItems = "";

function getHashFromElement(items, index, target) {

    if (index < items.length) {
            
        var item = items[index];

        
        var id = item.id;
        var provider = item.providerId;
        

        var element = jQuery("#li_" + id);
        var providerElement = jQuery("#" + provider + "_holder");

        //var id = element.find("input").attr("id");
        
        //var parent = element.parents("div.mandatoryProvider");
        
        /*
        var indicator = parent.find("h3 span");
        indicator.html("<img src='../images/loading.gif' />");
        */

        //jQuery("#" + providerId + "_holder h3 span").html("<img src='../images/loading.gif' title='loading...' />");
        
        providerElement.find("h3 span").html("<img src='../images/loading.gif' title='loading...' />");
        element.find("span").html("<img src='../images/loading.gif' title='loading...' />");
                       
        jQuery.ajax({
            type: "POST",
            url: "CommitItem.aspx/GetHash",
            contentType: "application/json; charset=utf-8",
            data: '{"id":"' + id + '","source":"' + target + '"}',
            dataType: "json",
            
            success: function (meh) {
                var hash = meh.d;
                var response = "<img src='../images/ok.png' title='This item already exist on the target machine' />";

                if (hash == "") {
                    response = "<img src='../images/warning.png' title='This item will be created on the target machine' />";

                    providerElement.addClass("groupWarning");

                    warningItemCount++;
                    warningItems += ";" + element.attr("title");
                }

                 element.find("span").html(response); 
            },
            error: function (meh) {

                element.find("span").html("<img src='../images/error.png' />");
                element.append("<span class='help-block'>Could not load hash from the target site</span>");
                providerElement.addClass("groupWarning");

                //element.closest(".umbracoDialog").find("#buttons input").hide();

            },
            complete: function () {                
                getHashFromElement(items, index + 1, target);
            }
        });

    } else {

        jQuery("div.mandatoryProvider h3 span").each(function (index, value) {
            var el = jQuery(value);

            el.html("");
            evalBlockedItems();
        });

    }
}