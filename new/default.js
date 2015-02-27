

$(function() {
  $.localScroll();

  $(document).on("scroll", onScroll);

  var extraspace = 0 + $(window).height() - ($('#endspace').position().top - $('#lastanchor').position().top);
  if (extraspace > 0) {
  	$('#endspace').height(extraspace);
  }

});

hljs.initHighlightingOnLoad();


function onScroll(event){
    var scrollPos = $(document).scrollTop();
    var lastLink = null;
    $('a.smoothScroll').each(function () {
        var currLink = $(this);
        var refElement = $(currLink.attr("href"));
        if(typeof(refElement.position()) != "undefined") {
        	if (refElement.position().top > scrollPos + 10 ) {
            	return false;
	        }
        }

        lastLink = currLink;
    });

    $('a.smoothScroll').removeClass("active");
	lastLink.addClass("active");
}

function copyToClipboard(ctext) {
  window.prompt("Please git-clone from the following URL: ", ctext);
}