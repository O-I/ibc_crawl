// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require turbolinks
//= require_tree .

$(function(){ $(document).foundation(); });

// Scroll to top arrow
$(document).ready(function() {
  $(window).scroll(function() {
    if($(this).scrollTop() > 1000) {
      $('#to-top').stop().animate({
        top: '130px'
        }, 500);
    }
    else{
      $('#to-top').stop().animate({
        top: '-100px'
        }, 500);
    }
  });
  $('#to-top').click(function() {
    $('html, body').stop().animate({
      scrollTop: 0
    }, 500, function() {
      $('#to-top').stop().animate({
        top: '-100px'
      }, 500);
    });
  });
});