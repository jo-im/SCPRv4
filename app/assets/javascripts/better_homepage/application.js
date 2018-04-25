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
//= require ../visual_campaign
//= require ../../../../node_modules/mutationobserver-shim/dist/mutationobserver.min

PortableHoles = require('portable-holes');

new scpr.adSizer();

jQuery(document).ready(function() {
  history.navigationMode = 'compatible';
  require('svgxuse');
  // require('better_homepage/page-adjuster');
  new scpr.BetterHomepage({el: $('.hp-content')});
  scpr.VisualCampaign.enqueue('pushdown-global', $('#global-pushdown'));
  scpr.VisualCampaign.enqueue('pushdown-homepage', $('#homepage-pushdown'));
  scpr.VisualCampaign.fetchQueue();
});

