$(document).ready(function () {
    $('#listing-wrapper li').hover(function () {
        ga('send', 'event', 'Beer Listing', 'Item Hover', 'Unknown');
    });

    $('#listing-wrapper li').click(function() {
        $('#overlay').show();
        $('#beer-detail-wrapper').slideToggle();

        ga('send', 'event', 'Beer Listing', 'Item View', 'Unknown');
    });

    $('#beer-detail-wrapper .close').click(function() {
        $('#beer-detail-wrapper').slideToggle();
        $('#overlay').hide();
    });
});