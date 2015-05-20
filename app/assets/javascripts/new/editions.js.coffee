scpr.Behaviors.Editions = loadBehaviors: ->
  # Give the OL back its numbers.
  # ---------------------------------------------------------
  # Shorten cosmetic names of days-of-the-week. (Debounced.)
  # ---------------------------------------------------------

  dayShortener = ->
    if $(window).width() < 761
      $('.recents li').each ->
        shortName = $(this).find('time span').attr('data-short')
        $(this).find('time span').html shortName
        return
    else
      $('.recents li').each ->
        longName = $(this).find('time span').attr('data-long')
        $(this).find('time span').html longName
        return
    return

  $('.contents ol li').each ->
    myIndex = $(this).index() + 1
    $(this).find('a').prepend '<mark>' + myIndex + '</mark> '
    return
  # Show/hide the "Recent Editions" flyout.
  # ---------------------------------------------------------
  $('.edition-marquee time mark,.recents button,.recents-toggle').click ->
    $('.edition-marquee').toggleClass 'exposed'
    return
  # Prevent internal-anchor URL hashes
  # NOTE: I (Jon) have a thought on this, but it might be
  # unfounded. Hit me up if this strikes anyone as a bad idea.
  # ---------------------------------------------------------
  $('.contents a,.subscribe-hint a').click ->
    desired = $(this).attr('href')
    $('html, body').animate { scrollTop: $(desired).offset().top }, 'slow'
    false
  # Focus email signup form input when user clicks subscribe anchor
  $('.subscribe-hint a').click ->
    $('.subscribe input[type=text]').focus()
    return
  # Show/hide the "KPCC Menu" flyout.
  # ---------------------------------------------------------
  $('.shortlist-ledge h1').click ->
    $('.shortlist-ledge nav').toggleClass 'exposed'
    return
  $(window).resize $.debounce(250, dayShortener)
  # SHORTLIST EDITION: Different aspect-ratios mean different faux-positionings.
  # ---------------------------------------------------------
  if $('.abstracts > article').length
    $('.abstracts > article img').each ->
      myWidth = $(this).attr('data-width')
      myHeight = $(this).attr('data-height')
      myRatio = myWidth / myHeight
      if myRatio >= 0.85 and myRatio < 1.1
        $(this).closest('article').addClass 'ratio-square'
      else if myRatio < 0.85
        $(this).closest('article').addClass 'ratio-tall'
      else if myRatio > 2
        $(this).closest('article').addClass 'ratio-squat'
      return
  # Conditionally add "hidden" class to the ledge when a URL 
  # hash of #no-prelims is passed to the page.
  # ---------------------------------------------------------
  url = document.location.hash
  if url == '#no-prelims'
    $('.shortlist-ledge').addClass 'hidden'
  # SINGLE EPISODE: Different aspect-ratios mean different faux-positionings.
  # ---------------------------------------------------------
  if $('body').hasClass('episode')
    $('.episode-enumeration > article img').each ->
      myWidth = $(this).attr('data-width')
      myHeight = $(this).attr('data-height')
      myRatio = myWidth / myHeight
      if myRatio > 1.5
        $(this).closest('article').addClass 'ratio-squat'
      else if myRatio < 1.0
        $(this).closest('article').addClass 'ratio-tall'
      return
  # SINGLE EPISODE: FPO Archive-Browser behavior.
  # ---------------------------------------------------------
  if $('.archive-browser').length
    # ---------------------------------------------------------
    # 1.) Standard-Picker triggers results.
    #     (And, while we're at it: update Liminal-Picker, too.)
    # ---------------------------------------------------------
    do (scpr) ->
      programSlug = undefined
      currentYear = undefined
      currentMonth = undefined
      currentMonthNumber = undefined
      loadLaminalMonthPicker = undefined
      getResults = undefined
      getMonths = undefined
      setLiminalPicker = undefined
      setLiminalYearPicker = undefined
      setLiminalMonthPicker = undefined
      setStandardMonthPicker = undefined
      setStandardYearPicker = undefined
      setStandardSelection = undefined

      programSlug = ->
        window.location.pathname.match(/programs\/(.*?)\//)[1]

      currentYear = ->
        $('.standard-picker .years select').find(':selected').text().replace /\s/g, ''

      currentMonth = ->
        $('.standard-picker .months select').find(':selected').text().replace /\s/g, ''

      currentMonthNumber = ->
        new Date(currentMonth() + ' 01, ' + currentYear()).getMonth() + 1

      loadLaminalMonthPicker = ->
        element = ($('.standard-picker .months select').find(':selected') or $('.standard-picker .months select')).text()
        return

      getResults = ->
        if currentMonthNumber()
          results = $('.archive-browser .results')
          episodeGroup = new (scpr.ArchiveBrowser.EpisodesCollection)
          episodesView = new (scpr.ArchiveBrowser.EpisodesView)(collection: episodeGroup)
          results.addClass 'loading'
          episodeGroup.on 'reset', (e) ->
            results.html episodesView.render().el
            results.removeClass 'loading'
            return
          episodeGroup.url = '/api/v3/programs/' + programSlug() + '/episodes/archive/' + currentYear() + '/' + currentMonthNumber()
          episodeGroup.fetch()
          if episodeGroup.length == 0
            episodeGroup.add new (scpr.ArchiveBrowser.Episode)
        return

      getYears = (callback) ->
        yearsGroup = new (scpr.ArchiveBrowser.YearsCollection)
        liminalYearsView = new (scpr.ArchiveBrowser.LiminalYearsView)(collection: yearsGroup)
        standardYearsView = new (scpr.ArchiveBrowser.StandardYearsView)(collection: yearsGroup)
        yearsGroup.url = '/api/v3/programs/' + programSlug() + '/episodes/archive/years'
        yearsGroup.on 'reset', (e) ->
          $('.liminal-picker .years').html liminalYearsView.render().el
          $('.standard-picker .fields .field.years').html standardYearsView.render().el
          setLiminalYearPicker()
          setStandardYearPicker()
          if callback
            callback.call()
          return
        yearsGroup.fetch()
        return

      getMonths = (callback) ->
        monthsGroup = new (scpr.ArchiveBrowser.MonthsCollection)
        liminalMonthsView = new (scpr.ArchiveBrowser.LiminalMonthsView)(collection: monthsGroup)
        standardMonthsView = new (scpr.ArchiveBrowser.StandardMonthsView)(collection: monthsGroup)
        monthsGroup.url = '/api/v3/programs/' + programSlug() + '/episodes/archive/' + currentYear() + '/months'
        monthsGroup.on 'reset', (e) ->
          $('.liminal-picker .months').html liminalMonthsView.render().el
          $('.standard-picker .fields .field.months').html standardMonthsView.render().el
          setLiminalMonthPicker()
          setStandardMonthPicker()
          if callback
            callback.call()
          return
        monthsGroup.fetch()
        return

      setLiminalPicker = (cssClass) ->
        element = $(cssClass)
        element.removeClass 'selected'
        $(element[0]).addClass 'selected'
        element.click ->
          myDropdown = $(this).closest('div').index()
          myChoice = $(this).index()
          $(this).siblings().attr 'class', ''
          $(this).addClass 'selected'
          $('.standard-picker .field:eq(' + myDropdown + ') select option').removeAttr 'selected'
          $('.standard-picker .field:eq(' + myDropdown + ') select option:eq(' + myChoice + ')').attr('selected', 'selected').trigger 'change'
          return
        return

      setLiminalYearPicker = ->
        setLiminalPicker '.liminal-picker div.years li'
        return

      setLiminalMonthPicker = ->
        setLiminalPicker '.liminal-picker div.months li'
        return

      setStandardYearPicker = ->
        $('.standard-picker .fields .field.years select').change ->
          setStandardSelection this
          getMonths ->
            getResults()
            return
          return
        return

      setStandardMonthPicker = ->
        $('.standard-picker .fields .field.months select').change ->
          setStandardSelection this
          getResults()
          return
        return

      setStandardSelection = (context) ->
        myIndex = $(context).find(':selected').index()
        myDropdown = $(context).closest('.field').index()
        $(context).find('option').removeAttr 'selected'
        $(context).find('option:eq(' + myIndex + ')').attr 'selected', 'selected'
        $('.liminal-picker div:eq(' + myDropdown + ') li').removeAttr 'class'
        $('.liminal-picker div:eq(' + myDropdown + ') li:eq(' + myIndex + ')').addClass 'selected'
        return

      $(document).ready ->
        getYears ->
          getMonths ->
            getResults()
            return
          return
        return
      return
    # ---------------------------------------------------------
    # 3.) Handheld users can opt to view all results.
    # ---------------------------------------------------------
    $('.show-full-results').click ->
      $('.results').toggleClass 'show-everything'
      $('.show-full-results').hide()
      return
    # ---------------------------------------------------------
  #.archive-browser existence check
  return

# ---
# generated by js2coffee 2.0.4