$(function() {

    // Media fluid width.
    // based on http://css-tricks.com/fluid-width-youtube-videos/
    var $container = $("article"),
        $elements = $("article iframe, article img");
    $elements.each(function() {
        $(this).data('ratio', this.width / this.height)
               .removeAttr('height')
               .removeAttr('width');
    });
    $(window).resize(function() {
        var container_width = $container.width();
        $elements.each(function() {
            $(this).width(container_width)
                   .height(container_width / $(this).data('ratio'));
        });
    }).resize();
});

