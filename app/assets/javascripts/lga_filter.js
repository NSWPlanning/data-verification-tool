$(function() {
  function strip(from) {
    if(from !== undefined) {
      from = from.replace(/^\s+/, '');
      for (var i = from.length - 1; i >= 0; i--) {
          if (/\S/.test(from.charAt(i))) {
              from = from.substring(0, i + 1);
              break;
          }
      }
      return from;
    } else {
      ""
    }
  }

  function filter(ev) {
    var list = $('#lga_list');
    var filter = strip($('#lga_filter').val());

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

    if(ev !== undefined) {
      if(ev.which === 13) {
        var visible = list.find('div.lga:visible');
        if (visible.length === 1) {
          window.location.href = visible.find('a.resource-title').attr('href');
        }
      }
    }
  }

  $('#lga_filter').keyup(filter);
  filter();
});
