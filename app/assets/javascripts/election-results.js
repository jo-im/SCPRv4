$(document).ready(function(){
  var currentDate = Date.now();
  var startDate   = Date.parse('2016-06-07T20:00:00-07:00');
  var endDate     = Date.parse('2016-06-08T23:59:59-07:00');
  if ((currentDate > startDate) && (currentDate < endDate)){
    $('.hero-election').load('http://162.243.135.6/static/results/featured.html');
  }
  return
});
