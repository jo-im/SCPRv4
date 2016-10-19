//= require jquery
//= require fastclick/lib/fastclick
// require slideshow/new_slideshow
//= require jquery.scrolldepth
// require page_mapping
//= require shared
//= require better_homepage/better_homepage
//= require ../utilities
//= require ../open_popup

new scpr.adSizer();

jQuery(document).ready(function() {
  require('svg4everybody')();
  new scpr.BetterHomepage({el: $('.hp-content')});
})