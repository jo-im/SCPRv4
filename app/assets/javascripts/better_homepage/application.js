//= require jquery
//= require fastclick/lib/fastclick
// require slideshow/new_slideshow
//= require jquery.scrolldepth
// require page_mapping
//= require shared
//= require better_homepage/better_homepage
//= require ../utilities

new scpr.adSizer()

jQuery(document).ready(function() {
  new scpr.BetterHomepage({el: $('section#content')})
})
