//= require jquery
//= require fastclick/lib/fastclick
// require slideshow/new_slideshow
//= require jquery.scrolldepth
// require page_mapping
//= require timeago
//= require shared
//= require smart_time
//= require better_homepage/article_tracking

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

  new scpr.ArticleTracking('section#content')

})
