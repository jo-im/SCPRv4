//= require jquery
//= require fastclick/lib/fastclick
// require slideshow/new_slideshow
//= require jquery.scrolldepth
// require page_mapping
//= require timeago
//= require shared
//= require smart_time
//= require better_homepage/better_homepage

jQuery(document).ready(function() {
  new scpr.BetterHomepage({el: $('section#content')})
})
