$(function() {
  $('#lga_filter').keyup(function(ev) {
    var list = $('#lga_list');
    var filter = $(this).val();

    if (filter === '') {
      // Show all when the filter is cleared
      list.find('div.lga').show();
    } else {
      // Hide all LGAs that don't match the filter
      var filterRegexp = new RegExp(filter, 'i');
      list.find('div.lga').each(function(index, lga_element) {
        var name = $(lga_element).data('name');
        $(lga_element).toggle(filterRegexp.test(name));
      });
    }

    if(ev.which === 13) {
      var visible = list.find('div.lga:visible');
      if (visible.length === 1) {
        window.location.href = visible.find('a.resource-title').attr('href');
      }
    }
  });
});
