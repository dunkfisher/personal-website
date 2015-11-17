function AppendHelp(parentObj, url, title) {

    if (title == null)
        title = "Video tutorial";

    var link = "<a target='_blank' onclick='OpenHelp(this); return false;' class='courierHelpLink' href='http://umbraco.com/help-and-support/video-tutorials" + url + "'>" + title + "</a>";
    var parent = jQuery(parentObj).first();
    parent.append(link);
}

function OpenHelp(link) {
    //Position the popup center at the top
    var leftPos = (screen.availWidth / 2) - (750 / 2);

    var url = link.href;
    url = url + "/tvplayer";
    window.open(url, "TVPlayer", "left=leftPos,height=555,width=750,location=no,resizable=no,status=no,toolbar=no");
    return false;
}