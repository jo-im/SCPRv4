//= require jquery
//= require fastclick/lib/fastclick
// require slideshow/new_slideshow
//= require jquery.scrolldepth
// require page_mapping
//= require shared
//= require better_homepage/better_homepage
//= require ../utilities
//= require ../open_popup
//= require better_homepage/html-collection-foreach-polyfill
//= require ../election-results

new scpr.adSizer();

jQuery(document).ready(function() {
  require('svgxuse');
  require('better_homepage/page-adjuster');
  new scpr.BetterHomepage({el: $('.hp-content')});
})