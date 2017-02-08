//= require jquery
//= require shared
//= require page_mapping
//= require jquery.scrolldepth
//= require event_tracking
//= require jplayer/dist/jplayer/jquery.jplayer.min
//= require audio
//= require utilities
//= require new/archive_browser
//= require masthead
//= require cookie
//= require visual_campaign
//= require svgxuse/svgxuse.min

require('./nuevo/popup');
var adSizer = require('./nuevo/ad-sizer');
new adSizer();

$(document).ready(function() {
  $.scrollDepth({
      elements: ['.o-newsletter-appeal'],
      percentage: false,
      userTiming: false,
      pixelDepth: false,
      gtmOverride: true
    });
});