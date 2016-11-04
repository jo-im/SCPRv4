$(document).ready ->
  currentDate = Date.now()
  startDate   = Date.parse('2016-06-07T01:00:00-07:00')
  endDate     = Date.parse('2017-06-07T23:59:59-07:00')
  if (currentDate > startDate) and (currentDate < endDate)
    $('.hero-election-2016').load 'https://elections.scpr.org/general-2016-11-08/results/homepage.html'