//= require jquery
//= require fastclick/lib/fastclick
// require slideshow/new_slideshow
//= require jquery.scrolldepth
// require page_mapping
//= require timeago
//= require shared
//= require smart_time
//= require event_tracking
//= require better_homepage/better_homepage

jQuery(document).ready(function() {
  jQuery.timeago.settings.strings = {
    suffixAgo: " ago",
    minute: "about a minute",
    minutes: "%dm",
    hour: "about 1h",
    hours: "%dh",
    day: "1d",
    days: "%dd",
    month: "1mo",
    months: "%dmo"
  }

  jQuery("time.timeago").timeago()

  var smartTime = new scpr.SmartTime({
    prefix: "Last Updated "
  });

  new scpr.BetterHomepage({el: $('section#content')})

})
