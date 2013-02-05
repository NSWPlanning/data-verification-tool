/**
 * JavaScript fix for the lack of a CSS solution. Goal is to ensure the
 * breadcrumbs text does not wrap outside the nav bar.
 */
$(function() {
  var topNav = $("#top-nav");
  var breadCrumbs = $("#nav-breadcrumbs");
  var lastCrumb = breadCrumbs.find(".crumb.last");
  var originalLastCrumbText = lastCrumb.html();

  var minimizeCrumbs = function() {
    var resized = false;

    // Reset the text to its original state, minimize until it fits.
    lastCrumb.html(originalLastCrumbText);
    while((breadCrumbs.height() + breadCrumbs.offset().top) > topNav.height()) {
      lastCrumb.html(lastCrumb.html().substring(0, lastCrumb.html().length - 1));
      resized = true;
    }

    // Add elipsis after the text has been truncated.
    if(resized) {
      lastCrumb.html(lastCrumb.html().substring(0, lastCrumb.html().length - 3) + "...");
    }
  }

  // Ensure this is checked as the window is resized.
  $(window).resize(minimizeCrumbs)

  // Run once to start with.
  minimizeCrumbs();
});
