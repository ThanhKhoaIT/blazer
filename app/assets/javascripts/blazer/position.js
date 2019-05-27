(function($) {
    jQuery.fn.weOffset = function () {
      var top = $(this).offset().top - (window.scrollY || window.pageYOffset || document.body.scrollTop);
      var left =  $(this).offset().left - (window.scrollX || window.pageXOffset || document.body.scrollLeft);
      return { top: top, left: left };
    };
}(jQuery));
