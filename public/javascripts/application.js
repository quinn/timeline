
var one_hour = 1000 * 60 * 60.0;

function log(val, name) {
  if (typeof console == 'undefined') return "can't log";
  if (name) {
    console.log('the value of ' + name + ' is ' + val);
  } else {
    console.log(val)
  }
};

// '#'+(Math.random()*0xFFFFFF<<0).toString(16);
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

function now(setting) {
  var date = new Date();
  if (setting) date.setTime(setting);
  return date;
};

function Entry(timeline, color, start) {
  this.timeline = timeline;
  if (typeof color == 'object') {
    this.dom = color;
    this.start = now(this.dom.attr('id'));
    this.color = this.dom.css('background-color');
  } else {
    this.color = color;
    this.start = start;
    this.dom = $('<div id="'+ this.start.getTime() +'"class="entry"><a href="#tag">(tags)</a><div class="current_time"></div></div')
      .css('background-color', this.color);
  }
  
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
  
  this.save = function(params) {
    var timeline = this.timeline;
    $.post('entries', $.extend({}, this.data(), params), function (data, status) {
      clearInterval(timeline.interval);
      timeline.interval = setInterval(function () {
        timeline.watch_timeline();
      }, 500);
    });
    
    return this;
  }
  
  this.tag = function() {
    
  }
  
  return this;
}

function Timeline(timeline_div) {
  this.dom = $(timeline_div);
  
  if (typeof $('.entry:last').attr('data-ended_at') == 'undefined') {
    this.current_entry = new Entry(this, $('.entry:last'));
    var timeline = this;
    this.interval = setInterval(function () {
      timeline.watch_timeline();
    }, 500);
  }
  
  this.watch_timeline = function() {
    var diff = now().getTime() - this.current_entry.start.getTime();
    var percent = diff / one_hour * 100;
    this.current_entry.dom
      .css('width', percent + '%')
      .find('.current_time')
        .text(now().toString());
  }
  
  this.new_entry = function() {
    var previous_start;
    if (this.current_entry) previous_start = this.current_entry.start.getTime();
    this.current_entry = new Entry(this, random_color('hex'), now())
      .save({'entry[parent]': previous_start})
      .append();
    if ($('input[name=tags]').val() != "") {
      this.current_entry.dom.find('a').click();
    }
  }
  
  this.stop = function() {
    this.current_entry.save({'entry[raw_ending]': now().getTime()})
    clearInterval(this.interval);
    this.current_entry = undefined;
  }
}

jQuery(function($) {
  var timeline = new Timeline('#timeline');
  
  $('a[href=#start]').live('click', function() {
    timeline.new_entry();
    return false;
  });
  
  $('a[href=#tag]').live('click', function() {
    var tag_link = $(this);
    var entry = new Entry(timeline, tag_link.parents('.entry'));
    var tag_field = $('input[name=tags]');
    
    if (!tag_field.val() == '') {
      entry.save({'entry[tags]': tag_field.val()});
      tag_link.text(tag_field.val());
      tag_field.val('');
    }
  });
  
  $('a[href=#stop]').live('click', function() {
    timeline.stop();
    return false;
  });
});
