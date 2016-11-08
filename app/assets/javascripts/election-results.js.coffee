$(document).ready ->
  currentDate = Date.now()
  startDate   = Date.parse('2017-11-08T19:55:00-08:00')
  endDate     = Date.parse('2017-11-09T23:59:00-08:00')
  if (currentDate > startDate) and (currentDate < endDate)
    $.getScript "//pym.nprapps.org/pym.v1.min.js", ->
      pymParent = new pym.Parent('hero-election-2016', 'https://elections.scpr.org/general-2016-11-08/results/homepage.html', {})