var viewportScrollPos;

var clearResults = function () {
    $('#listing-wrapper').empty();
}

var setupPopup = function () {
    $('#listing-wrapper li').click(function () {
        var beername = $(this).find('.beer-name').data('name');
        ga('send', 'event', 'Beer Listing', 'Item View', beername);

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
    $('#filterToggle').click(function () {
        $('#searchOptions').removeClass('visible');
        $('#filterOptions').toggleClass('visible');
    });

    $('#searchToggle').click(function () {
        $('#filterOptions').removeClass('visible');
        $('#searchOptions').toggleClass('visible');
    });

    $('input#filter').click(function () {
        ga('send', 'event', 'Beer Listing', 'Filter', $('#countrySelect').val());
        $('#filterOptions').toggleClass('visible');
    });

    $('input#search').click(function () {
        ga('send', 'event', 'Beer Listing', 'Search', $('#searchTerm').val());
        console.log($('#searchTerm').val());
        $('#searchOptions').toggleClass('visible');
    });

    $('#listing-wrapper li').mouseenter(function () {
        var beerName = $(this).find('.beer-name').data('name');
        ga('send', 'event', 'Beer Listing', 'Item Hover', beerName);
    });
    
    $('#beer-detail-wrapper .close').click(function() {
        $('#beer-detail-wrapper').removeClass('visible');
        setTimeout(function () {
            $('#overlay').removeClass('visible');
            $('body').removeClass('no-scroll');
            window.scrollTo(0, viewportScrollPos);
        }, 500);                
    });
});