$(function() {
  if($("#land-parcel-search").length == 1) {
    var searchTypeInput = $("#search_type");
    var titleInput = $("#filter");
    var selectedSearchType = $("#selected-search-type");
    $(".search-option").click(function(option) {
      label = $(this).find(".search-option-label").html();
      searchTypeInput.val(label);
      selectedSearchType.html(label);
      titleInput.attr("placeholder", "Look up by " + label)
    });
  }
});
