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
})
