$(document).ready(function () {
    $('#listing-wrapper li').mouseenter(function () {
        var beerName = $(this).find('.beer-name').data('name');

        ga('send', 'event', 'Beer Listing', 'Item Hover', beerName);
    });

    //$('#listing-wrapper li').click(function () {        
    //    var beerName = $(this).find('.beer-name').data('name');
    //    alert('Details for ' + beerName + ' not yet available.');
    //    ga('send', 'event', 'Beer Listing', 'Item View', beerName);
    //    return;
                
    //    $('#beer-name').text(beerName);
    //    $('#beer-brewer').text($(this).find('.beer-brewer').data('brewer'));
    //    $('#beer-country').text($(this).find('.beer-country').data('country'));
    //    $('#beer-country-flag-path').attr('src', $(this).find('.beer-country-flag').data('country-flag-path'));
    //    $('#beer-image-taken').text($(this).find('.beer-image-taken').data('image-taken'));
    //    $('#beer-last-tasted').text($(this).find('.beer-last-tasted').data('last-tasted'));
    //    $('#beer-review').text($(this).find('.beer-review').data('review'));
    //    $('#beer-rating').text($(this).find('.beer-rating').data('rating'));
    //    $('#beer-country-flag').attr('src', $(this).find('.beer-country-flag').data('country-flag-path'));
    //    $('#beer-image').attr('src', $(this).find('.beer-image').data('image-path'));

    //    //$('#beer-detail-wrapper').scrollTop(0);

    //    //$('body').addClass('no-scroll');
    //    //$('#overlay').addClass('visible');
    //    //$('#beer-detail-wrapper').addClass('visible');
    //    //$('#beer-detail-wrapper').animate({ width: 'toggle' }, 800, 'swing', function () { $('#beer-detail-wrapper > div').addClass('visible'); });
    //});

    $('#beer-detail-wrapper .close').click(function() {
        $('#beer-detail-wrapper > div').removeClass('visible');        
        $('#beer-detail-wrapper').animate({ width: 'toggle' }, 800, 'swing', function () { $('#overlay').removeClass('visible'); });
        //$('#overlay').removeClass('visible');
        //$('body').removeClass('no-scroll');
    });
});