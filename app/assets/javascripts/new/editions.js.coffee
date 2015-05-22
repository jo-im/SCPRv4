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

  scpr.ArchiveBrowser ?= {}
  scpr.ArchiveBrowser.active ?= []

  class scpr.ArchiveBrowser.Picker
    constructor: (element, group, viewClass, options) ->
      @options = options or {}
      @element = element
      @group = group
      @viewClass = viewClass
      @onClick = ->
      @onChange = ->
      @onSelect = ->
      @onRender = ->
      @group.on 'reset', (e) =>
        @render()
    on: (events, callback) =>
      _.each events, (event) =>
        @["on#{event}"] = callback
    render: ->
      view = new @viewClass(collection: @group)
      @element.html view.render().el
      @behave()
      @onRender(@value())

  class scpr.ArchiveBrowser.LiminalPicker extends scpr.ArchiveBrowser.Picker
    items: ->
      @element.find('li')
    select: (value) ->
      @items().removeClass('selected')
      @find(value).addClass('selected')
      @onSelect(value)
    selectFirst: ->
      @select $(@items()[0]).text()
    change: (value) ->
      @select(value)
      @onChange(value.replace(/\s/g, ''))
    find: (value) ->
      @element.find("li:contains('#{value}')")
    value: ->
      $(@element.find("li.selected")[0]).text().replace(/\s/g, '')
    behave: ->
      # @items().removeClass('selected')
      # $(@items()[0]).addClass('selected')
      # @onSelect(@value())
      itemList = @items()
      clickBack = @onClick
      changeBack = @onChange
      context = @
      itemList.click ->
        myDropdown = $(this).closest('div').index()
        myChoice = $(this).index()
        itemList.removeClass 'selected'
        $(this).addClass 'selected'
        changeBack($(this).text().replace(/\s/g, ''))
        clickBack(@, context)

  class scpr.ArchiveBrowser.StandardPicker extends scpr.ArchiveBrowser.Picker
    constructor: (element, group, viewClass, options) ->
      super element, group, viewClass, options
      @element.change (e) =>
        @onChange(@value().replace(/\s/g, ''))
    items: ->
      @element.find('option')
    select: (value) ->
      @items().removeAttr('selected')
      @element.find("option:contains('#{value}')").attr('selected', 'selected')
      @onSelect(value)
    change: (value) ->
      @select(value)
    value: ->
      $(@element.find("option:selected")[0]).text().replace(/\s/g, '')
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


  class scpr.ArchiveBrowser.Histogram
    constructor: (response) ->
      @data = response.histogram
    years: ->
      @data.years
    year: (year) ->
      _.findWhere(@years(), {year: parseInt(year)})
    months: (year) ->
      @year(year).months

  class scpr.ArchiveBrowser.Browser
    constructor: (element, program) ->
      scpr.ArchiveBrowser.active ?= []
      scpr.ArchiveBrowser.active.push @
      @element         = element
      @program         = program
      $.get "/api/v3/programs/#{@program}/histogram", (data) =>
        @histogram  = new scpr.ArchiveBrowser.Histogram(data)
        @yearsGroup = new (scpr.ArchiveBrowser.YearsCollection)
        @monthsGroup     = new (scpr.ArchiveBrowser.MonthsCollection)
        @episodesGroup   = new (scpr.ArchiveBrowser.EpisodesCollection)
        @lMonthPicker    = new scpr.ArchiveBrowser.LiminalPicker(@element.find('.liminal-picker .months'), @monthsGroup, scpr.ArchiveBrowser.LiminalMonthsView, {'remember': true})
        @sYearPicker     = new scpr.ArchiveBrowser.StandardPicker(@element.find('.standard-picker .field.years'), @yearsGroup, scpr.ArchiveBrowser.StandardYearsView)
        @sMonthPicker    = new scpr.ArchiveBrowser.StandardPicker(@element.find('.standard-picker .field.months'), @monthsGroup, scpr.ArchiveBrowser.StandardMonthsView)
        @episodesResults = new scpr.ArchiveBrowser.Episodes(@element.find('.results'), @episodesGroup, scpr.ArchiveBrowser.EpisodesView)
        @lYearPicker     = new scpr.ArchiveBrowser.LiminalPicker(@element.find('.liminal-picker .years'), @yearsGroup, scpr.ArchiveBrowser.LiminalYearsView)
        @lMonthPicker    = new scpr.ArchiveBrowser.LiminalPicker(@element.find('.liminal-picker .months'), @monthsGroup, scpr.ArchiveBrowser.LiminalMonthsView, {'remember': true})

        @month = undefined

        resetMonths = (value) =>
          months = @histogram.months(value)
          @monthsGroup.reset months
          @getEpisodes(@currentYear(), @currentMonth())

        @sYearPicker.on ['Change'], (value) =>
          @lYearPicker.select value
          @month = @sMonthPicker.value()
          resetMonths(value)

        @lYearPicker.on ['Change'], (value) =>
          @sYearPicker.select value
          @month = @lMonthPicker.value()
          resetMonths(value)

        @sMonthPicker.on ['Change'], (value) =>
          @lMonthPicker.select value
          @month = value
          @getEpisodes(@currentYear(), @currentMonth())

        @lMonthPicker.on ['Change'], (value) =>
          @sMonthPicker.select value
          @month = value
          @getEpisodes(@currentYear(), @currentMonth())

        @yearsGroup.on 'reset', =>
          value = @yearsGroup.models[0].attributes.year
          @lYearPicker.select value
          resetMonths(value)

        @monthsGroup.on 'reset', =>
          whichMonth = @monthsGroup.valueOrFirst(@month)
          @sMonthPicker.select whichMonth
          @lMonthPicker.select whichMonth
          
        @yearsGroup.reset @histogram.years()

    getEpisodes: (year, month) ->
      @month = month
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