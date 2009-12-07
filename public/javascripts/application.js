
var one_hour = 1000 * 60 * 60.0;

function log(val, name) {
  if (typeof console == 'undefined') return "can't log";
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

function now() {
  var date = new Date();
  return date;
};

function Entry(timeline, color, start) {
  this.timeline = timeline;
  this.color = color;
  this.start = start;
  this.dom = $('<div id="'+ this.start.getTime() +'"class="entry"></div')
    .css('background-color', this.color);
  
  this.append = function() {
    this.timeline.dom
      .append(this.dom);
    
    return this;
  }
  
  this.data = function () {
    return {
      'entry[raw_time]': this.start.getTime(), 
      'entry[color]': this.color }
  }
  
  this.save = function(previous_entry, previous_start) {
    if (previous_entry) var previous_start = previous_entry.start.getTime();
    var timeline = this.timeline;
    $.post('entries', $.extend({}, this.data(), {'entry[parent]': previous_start}), function (data, status) {
      clearInterval(timeline.interval);
      timeline.interval = setInterval(function () {
        timeline.watch_timeline();
      }, 500);
    });
    
    return this;
  }
  
  return this;
}

function Timeline(timeline_div) {
  this.dom = $(timeline_div);
  this.current_entry;
  this.current_start;
  this.interval;

  this.watch_timeline = function() {
    var diff = now().getTime() - this.current_entry.start.getTime();
    var percent = diff / one_hour * 100;
    if (percent <= 100) {
      this.current_entry.dom
        .css('width', percent + '%')
        .text(now().toString());
    }
  }
  
  this.new_entry = function() {
    this.current_entry = new Entry(this, random_color('hex'), now())
      .save(this.current_entry)
      .append();
  }
}

jQuery(function($) {
  var start_link = $('a[href=#start]');
  var timeline = new Timeline('#timeline');
  
  start_link.live('click', function() {
    timeline.new_entry();
    return false;
  });
});
