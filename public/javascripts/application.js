function log(val, name) {
  if (name) {
    console.log('the value of ' + name + ' is ' + val);
  } else {
    console.log(val)
  }
};

function random_color(format) {
  var rint = Math.round(0xffffff * Math.random());
  switch(format)
  {
    case 'hex':
      return ('#0' + rint.toString(16)).replace(/^#0([0-9a-f]{6})$/i, '#$1');
    break;
    
    case 'rgb':
     return 'rgb(' + (rint >> 16) + ',' + (rint >> 8 & 255) + ',' + (rint & 255) + ')';
    break;
    
    default:
     return rint;
    break;
  }
}

jQuery(function($) {
  
  var start_link = $('a[href=#start]');
  var timeline = $('#timeline');
  var start = 0;
  var one_hour = 1000 * 60 * 60.0;
  var now = function () {
    var date = new Date();
    return date;
  };
  
  start_link.live('click', function() {
    start = now();
    
    $.post('entry', {started_at: start.getTime()}, function (data, status) {
      
    });
    $('#started_at');
    return false;
  });
  
  setInterval(function() {
    var diff = now().getTime() - start;
    var percent = diff / one_hour * 100;
    if (percent <= 100) {
      timeline
        .css('width', percent + '%')
        .find('.current_time')
          .text(now().toString());
    }
  }, 500);
  
  timeline.css('background-color', random_color('hex'));
});
