var viewportScrollPos;

var setupPopup = function () {
    $('#listing-wrapper li').click(function () {
        var beername = $(this).find('.beer-name').data('name');
        ga('send', 'event', 'beer listing', 'item view', beername);

        $('#beer-name').text(beername);
        $('#beer-brewer').text($(this).find('.beer-brewer').data('brewer'));
        $('#beer-country').text($(this).find('.beer-country').data('country'));
        $('#beer-country-flag-path').attr('src', $(this).find('.beer-country-flag').data('country-flag-path'));
        $('#beer-image-taken').text($(this).find('.beer-image-taken').data('image-taken'));
        $('#beer-last-tasted').text($(this).find('.beer-last-tasted').data('last-tasted'));
        $('#beer-review').text($(this).find('.beer-review').data('review'));
        $('#beer-rating').text($(this).find('.beer-rating').data('rating'));
        $('#beer-country-flag').attr('src', $(this).find('.beer-country-flag').data('country-flag-path'));
        $('#beer-image').attr('src', $(this).find('.beer-image').data('image-path'));

        viewportScrollPos = window.scrollY;
        $('body').addClass('no-scroll');
        $('#overlay').addClass('visible');
        $('#beer-detail-wrapper').addClass('visible');
        $('#beer-detail-wrapper .main').scrollTop(0);        
    });
}

$(document).ready(function () {
    $('input#filter').click(function () {
        ga('send', 'event', 'filter', 'apply', $('#countrySelect').val());
    });

    $('#listing-wrapper li').mouseenter(function () {
        var beerName = $(this).find('.beer-name').data('name');
        ga('send', 'event', 'Beer Listing', 'Item Hover', beerName);
    });
    
    $('#beer-detail-wrapper .close').click(function() {
        $('#beer-detail-wrapper').removeClass('visible');        
        $('#overlay').removeClass('visible');
        $('body').removeClass('no-scroll');
        window.scrollTo(0, viewportScrollPos);
    });
});