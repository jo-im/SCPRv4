$(document).ready ->
  currentDate = Date.now()
  startDate   = Date.parse('2016-05-07T01:00:00-07:00')
  endDate     = Date.parse('2016-06-07T23:59:59-07:00')
  if (currentDate > startDate) and (currentDate < endDate)
    $('.hero-election').load 'http://162.243.135.6/static/results/featured.html'