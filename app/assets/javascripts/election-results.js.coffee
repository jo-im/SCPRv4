$(document).ready ->
  currentDate = Date.now()
  startDate   = Date.parse('2016-06-07T01:00:00-07:00')
  endDate     = Date.parse('2016-06-07T23:59:59-07:00')
  if (currentDate > startDate) and (currentDate < endDate)
    $.getScript "//pym.nprapps.org/pym.v1.min.js", ->
      pymParent = new pym.Parent('hero-election-2016', 'https://elections.scpr.org/general-2016-11-08/results/homepage.html', {})