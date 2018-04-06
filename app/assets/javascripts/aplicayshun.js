//= require shared
//= require page_mapping
//= require jquery.scrolldepth
//= require jplayer/dist/jplayer/jquery.jplayer.min
//= require audio
//= require utilities
//= require new/archive_browser
//= require masthead
//= require cookie
//= require visual_campaign
//= require svgxuse/svgxuse.min
//= require spin
//= require cms_popup
//= require_tree ./slideshow/templates

//= require embeditor
//= require embeditor/templates
//= require embeditor/adapters/oembed
//= require embeditor/adapters/cover_it_live
//= require embeditor/adapters/embedly
//= require embeditor/adapters/fire_tracker
//= require embeditor/adapters/polldaddy
//= require embeditor/adapters/twitter
//= require embeditor/adapters/instagram
//= require embeditor/adapters/storify
//= require embeditor/adapters/brightcove
//= require embeditor/adapters/rebel_mouse
//= require embeditor/adapters/google_fusion
//= require embeditor/adapters/ranker
//= require embeditor/adapters/document_cloud
//= require embeditor/adapters/youtube

//= require fastclick/lib/fastclick
//= require slideshow/new_slideshow

//= require new/behaviors
//= require new/layout
//= require new/verticals
//= require new/archive_browser
//= require new/editions
//= require new/episodes
//= require new/jquery.ba-throttle-debounce.min
//= require timeago/jquery.timeago

require('./nuevo/popup');
var adSizer = require('./nuevo/ad-sizer');
new adSizer();
