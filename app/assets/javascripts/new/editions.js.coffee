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

  $(document).ready ->

    class scpr.ArchiveBrowser.Picker
      constructor: (element, group, viewClass, options) ->
        @options = options or {}
        @element = element
        @group = group
        @viewClass = viewClass
        @previousValue = undefined
        @onClick = ->
        @onReset = ->
        @onChange = ->
        @onSelect = ->
        @group.on 'reset', (e) =>
          @previousValue = @value()
          view = new @viewClass(collection: group)
          @element.html view.render().el
          @behave()
          @onReset()

    class scpr.ArchiveBrowser.LiminalPicker extends scpr.ArchiveBrowser.Picker
      items: ->
        @element.find('li')
      select: (value) ->
        @previousValue = @value()
        @items().removeClass('selected')
        @find(value).addClass('selected')
        @onSelect(value)
      change: (value) ->
        @select(value)
        @onChange(value)
      find: (value) ->
        @element.find("li:contains('#{value}')")
      value: ->
        $(@element.find("li.selected")[0]).text()
      behave: ->
        @items().removeClass('selected')
        $(@items()[0]).addClass('selected')
        itemList = @items()
        clickBack = @onClick
        changeBack = @onChange
        context = @
        itemList.click ->
          myDropdown = $(this).closest('div').index()
          myChoice = $(this).index()
          itemList.removeClass 'selected'
          $(this).addClass 'selected'
          changeBack($(this).text())
          clickBack(@, context)

    class scpr.ArchiveBrowser.StandardPicker extends scpr.ArchiveBrowser.Picker
      constructor: (element, group, viewClass, options) ->
        super element, group, viewClass, options
        @element.change (e) =>
          @onChange(@value())
      items: ->
        @element.find('option')
      select: (value) ->
        @items().removeAttr('selected')
        @element.find("option:contains('#{value}')").attr('selected', 'selected')
        @onSelect(value)
      change: (value) ->
        @select(value)
        # @onChange(value)
        # @items.parent().trigger('change')
      value: ->
        $(@element.find("option:selected")[0]).text()
      behave: ->
        itemList = @items()
        clickBack = @onClick
        changeBack = @onChange
        context = @


    class scpr.ArchiveBrowser.Episodes
      constructor: (element, group, viewClass) ->
        @element = element
        @group = group
        @viewClass = viewClass
        @clickBack = ->
        @resetBack = ->
        @group.on 'reset', (e) =>
          view = new @viewClass(collection: group)
          @element.html view.render().el
          @resetBack()




    class scpr.ArchiveBrowser.Browser
      constructor: (element, program) ->
        @element         = element
        @program         = program
        @yearsGroup      = new (scpr.ArchiveBrowser.YearsCollection)
        @yearsGroup.url  = "/api/v3/programs/#{@program}/episodes/archive/years"
        @monthsGroup     = new (scpr.ArchiveBrowser.MonthsCollection)
        @episodesGroup   = new (scpr.ArchiveBrowser.EpisodesCollection)

        @lYearPicker     = new scpr.ArchiveBrowser.LiminalPicker(@element.find('.liminal-picker .years'), @yearsGroup, scpr.ArchiveBrowser.LiminalYearsView)
        @lMonthPicker    = new scpr.ArchiveBrowser.LiminalPicker(@element.find('.liminal-picker .months'), @monthsGroup, scpr.ArchiveBrowser.LiminalMonthsView, {'remember': true})
        @sYearPicker     = new scpr.ArchiveBrowser.StandardPicker(@element.find('.standard-picker .field.years'), @yearsGroup, scpr.ArchiveBrowser.StandardYearsView)
        @sMonthPicker    = new scpr.ArchiveBrowser.StandardPicker(@element.find('.standard-picker .field.months'), @monthsGroup, scpr.ArchiveBrowser.StandardMonthsView)
        @episodesResults = new scpr.ArchiveBrowser.Episodes(@element.find('.results'), @episodesGroup, scpr.ArchiveBrowser.EpisodesView)


        @lYearPicker.onChange = (val) =>
          @sYearPicker.select(val)
          @monthsGroup.url = "/api/v3/programs/#{@program}/episodes/archive/#{@currentYear()}/months"
          @monthsGroup.on "reset", =>
            @episodesGroup.url = "/api/v3/programs/#{@program}/episodes/archive/#{@currentYear()}/#{@currentMonth()}"
            @episodesGroup.fetch()
          @monthsGroup.fetch()

        @lMonthPicker.onChange = (val) =>
          @sMonthPicker.select(val)
          @episodesGroup.url = "/api/v3/programs/#{@program}/episodes/archive/#{@currentYear()}/#{@currentMonth()}"
          @episodesGroup.fetch()

        @sYearPicker.onChange = (val) =>
          @lYearPicker.change(val)

        @sMonthPicker.onChange = (val) =>
          @lMonthPicker.change(val)

        @yearsGroup.on "reset", =>
          @monthsGroup.url = "/api/v3/programs/#{@program}/episodes/archive/#{@currentYear()}/months"
          @monthsGroup.on "reset", =>
            @episodesGroup.url = "/api/v3/programs/#{@program}/episodes/archive/#{@currentYear()}/#{@currentMonth()}"
            @episodesGroup.fetch()
          @monthsGroup.fetch()
        @yearsGroup.fetch()


      getEpisodes: (year, month) ->
        @episodesGroup.url = "/api/v3/programs/#{@program}/episodes/archive/#{year}/#{month}"
        @episodesGroup.fetch()

      currentYear: ->
        @sYearPicker.value().replace(/\s/g, '')

      currentMonth: ->
        @sMonthPicker.value().replace(/\s/g, '')

      currentMonthNumber: ->
        new Date(@currentMonth() + ' 01, ' + @currentYear()).getMonth() + 1

      getMonths: (value, callback) ->        
        @monthsGroup.url = "/api/v3/programs/#{@program}/episodes/archive/#{value}/months"
        @monthsGroup.fetch()

    browser = new scpr.ArchiveBrowser.Browser($('section.archive-browser'), 'take-two')