<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SystemItemSelector.ascx.cs" Inherits="Umbraco.Courier.UI.Usercontrols.SystemItemSelector" %>

<div id="systemItemSelectorDiv" class="systemItemSelectorDiv"></div>


<script type="text/javascript" src="../scripts/jquery-ui.custom.min.js"></script>
<script type="text/javascript" src="../scripts/jquery.dynatree.min.js"></script>

<script type="text/javascript">
    jQuery(document).ready(function () {
        var selectedChildItems = jQuery(".systemItemSelectorTextBox");
        var inEventHandler = false;
        
        jQuery('#systemItemSelectorDiv').dynatree(
            {   
                imagePath: " ",
                initAjax: {
                     url: "<%= umbraco.IO.IOHelper.ResolveUrl(Umbraco.Courier.Core.Settings.treeWebservicesPath) %>?id=<%= ParentID %>"
                },
                onLazyRead: function(node){
                    node.appendAjax({
                        url: "<%= umbraco.IO.IOHelper.ResolveUrl(Umbraco.Courier.Core.Settings.treeWebservicesPath) %>?id=" + node.data.key
                    });
                },

                <% if(!this.LinkList){ %>
                checkbox: true,
                selectMode: 2,
                onRender: function (dtNode, nodeSpan) {
                    //move the icon class to an icon element
                    var iconMatch = nodeSpan.className.match(/(icon[\-\w]+)\s/);
                    if (iconMatch && iconMatch.length === 2) {
                        var iconClass = iconMatch[1];
                        nodeSpan.className = nodeSpan.className.replace(/(icon[\-\w]+)\s/, "");
                        $(nodeSpan).find("a").before("<i class='icon " + iconClass + "'></i>");    
                    }
                },
                onCreate: function (dtNode, nodeSpan) {
                    
                    var parent = dtNode.getParent();
                    if(parent != null){
                        dtNode.select(parent.isSelected());
                    }
                },

                onSelect: function(select, dtnode) {
                    // Ignore, if this is a recursive call
                    if(inEventHandler) 
                        return;
                    // Select all children of currently selected node
                    try {
                        inEventHandler = true;
                        var selected = dtnode.bSelected;
                                                   
                        dtnode.visit(function(childNode){
                            childNode.select(selected);
                        });
                    }finally {
                         inEventHandler = false;
                    }

                    processCheckedNodes(dtnode.tree.getSelectedNodes());
                }

                <%}else{%>
                onActivate: function(node) {
                    processSelectedNode(node.data.key);
                    return false;
                }
                <%} %>
            }
         );
    });
</script>
