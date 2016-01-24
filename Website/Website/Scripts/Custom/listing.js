$(document).ready(function () {
    $('#listing-wrapper li').hover(function () {
        var beerName = $(this).find('.beer-name').data('name');

        ga('send', 'event', 'Beer Listing', 'Item Hover', beerName);
    });

    $('#listing-wrapper li').click(function () {
        var beerName = $(this).find('.beer-name').data('name');

        ga('send', 'event', 'Beer Listing', 'Item View', beerName);

        $('#beer-name').text(beerName);
        $('#beer-brewer').text($(this).find('.beer-brewer').data('brewer'));
        $('#beer-country').text($(this).find('.beer-country').data('country'));
        $('#beer-country-flag-path').attr('src', $(this).find('.beer-country-flag').data('country-flag-path'));
        $('#beer-image-taken').text($(this).find('.beer-image-taken').data('image-taken'));
        $('#beer-last-tasted').text($(this).find('.beer-last-tasted').data('last-tasted'));
        $('#beer-review').text($(this).find('.beer-review').data('review'));
        $('#beer-rating').text($(this).find('.beer-rating').data('rating'));
        $('#beer-country-flag').attr('src', $(this).find('.beer-country-flag').data('country-flag-path'));
        $('#beer-image').attr('src', $(this).find('.beer-image').data('image-path'));

        $('body').addClass('no-scroll');
        $('#overlay').show();
        $('#beer-detail-wrapper').slideToggle();
    });

    $('#beer-detail-wrapper .close').click(function() {
        $('#beer-detail-wrapper').slideToggle();
        $('#overlay').hide();
        $('body').removeClass('no-scroll');
    });
});