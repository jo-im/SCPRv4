class scpr.ArchiveBrowser
  constructor: (element, program) ->
    scpr.ArchiveBrowser.active ?= []
    scpr.ArchiveBrowser.active.push @
    @element         = element
    @program         = program
    $.get "/api/v3/programs/#{@program}/histogram", (data) =>
      @browserView = new BrowserView
      @histogram  = new Histogram(data)
      @yearsGroup = new (YearsCollection)
      @monthsGroup     = new (MonthsCollection)
      @episodesGroup   = new (EpisodesCollection)

      $("section##{@program}-archive-browser").html @browserView.render().el
      @lMonthPicker    = new LiminalPicker(@element.find('.liminal-picker .months'), @monthsGroup, LiminalMonthsView)
      @sYearPicker     = new StandardPicker(@element.find('.standard-picker .field.years'), @yearsGroup, StandardYearsView)
      @sMonthPicker    = new StandardPicker(@element.find('.standard-picker .field.months'), @monthsGroup, StandardMonthsView)
      @episodesResults = new Episodes(@element.find('.results'), @episodesGroup, EpisodesView)
      @lYearPicker     = new LiminalPicker(@element.find('.liminal-picker .years'), @yearsGroup, LiminalYearsView)
      @lMonthPicker    = new LiminalPicker(@element.find('.liminal-picker .months'), @monthsGroup, LiminalMonthsView)

      @resetMonths = (value) =>
        months = @histogram.months(value)
        @monthsGroup.reset months
        @getEpisodes(@currentYear(), @currentMonth())

      @sYearPicker.on ['Change'], (value) =>
        @lYearPicker.select value
        @month = @sMonthPicker.value()
        @resetMonths(value)

      @lYearPicker.on ['Change'], (value) =>
        @sYearPicker.select value
        @month = @lMonthPicker.value()
        @resetMonths(value)

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
        @resetMonths(value)

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
    @sYearPicker.value()

  currentMonth: ->
    @sMonthPicker.value()

  currentMonthNumber: ->
    new Date(@currentMonth() + ' 01, ' + @currentYear()).getMonth() + 1

  ## Child Classes

  class Picker
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

  class LiminalPicker extends Picker
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

  class StandardPicker extends Picker
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


  class Episodes
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


  class Histogram
    constructor: (response) ->
      @data = response.histogram
    years: ->
      @data.years
    year: (year) ->
      _.findWhere(@years(), {year: parseInt(year)})
    months: (year) ->
      @year(year).months


  ## Models, views, collections

  class BrowserView extends Backbone.View
    template: ->
      return _.template($('#browserView').text())
    render: ->
      this.el = @template()()
      @

  ## EPISODES

  class Episode extends Backbone.Model
    defaults:
      id: undefined
      title: "Untitled Episode"
      public_url: '#'
      air_date: undefined
      day: ->
        new Date(this.air_date).getDate() 
    parse: (response) ->
      return response

  class EpisodesCollection extends Backbone.Collection
    model: Episode
    parse: (response) ->
      return response.episodes

  class EpisodeView extends Backbone.View 
    tagName: 'li'
    className: 'Episode'
    template: ->
      return _.template($("#episodeView").text())
    render: ->
      episodeTemplate = @template()(@model.toJSON())
      @.$el.html(episodeTemplate)
      @

  class EpisodesView extends Backbone.View
    tagName: 'ul'
    render: ->
      if @collection.length != 0
        @collection.each(@addEpisode, @)
      else
        @.$el.append("No episodes found.")
      @
    addEpisode: (episode)->
      episodeView = new EpisodeView({model: episode})
      @.$el.append(episodeView.render().el)


  ## MONTHS

  class Month extends Backbone.Model
    defaults:
      name: undefined
    parse: (response) ->
      return {'name': response}

  class MonthsCollection extends Backbone.Collection
    model: Month
    parse: (response) ->
      return response.months
    valueOrFirst: (value) =>
      if model = @where({name: value})[0] or @models[0]
        model.attributes.name

  class LiminalMonthView extends Backbone.View 
    tagName: 'li'
    className: 'Month'
    template: ->
      return _.template($("#liminalMonthView").text())
    render: ->
      monthTemplate = @template()(@model.toJSON())
      @.$el.html(monthTemplate)
      @

  class LiminalMonthsView extends Backbone.View
    tagName: 'ul'
    render: ->
      @collection.each(@addMonth, @)
      @
    addMonth: (month)->
      monthView = new LiminalMonthView({model: month})
      @.$el.append(monthView.render().el)

  class StandardMonthView extends Backbone.View 
    tagName: 'option'
    template: ->
      return _.template($("#standardMonthView").text())
    render: ->
      monthTemplate = @template()(@model.toJSON())
      @.$el.html(monthTemplate)
      @

  class StandardMonthsView extends Backbone.View
    tagName: 'select'
    render: ->
      @collection.each(@addMonth, @)
      @
    addMonth: (month)->
      monthView = new StandardMonthView({model: month})
      @.$el.append(monthView.render().el)


  ## YEARS

  class Year extends Backbone.Model
    defaults:
      number: undefined
    parse: (response) ->
      return {'number': response}

  class YearsCollection extends Backbone.Collection
    model: Year
    parse: (response) ->
      return response.years

  class LiminalYearView extends Backbone.View 
    tagName: 'li'
    className: 'Year'
    template: ->
      return _.template($("#liminalYearView").text())
    render: ->
      yearTemplate = @template()(@model.toJSON())
      @.$el.html(yearTemplate)
      @

  class LiminalYearsView extends Backbone.View
    tagName: 'ul'
    render: ->
      @collection.each(@addYear, @)
      @
    addYear: (year)->
      yearView = new LiminalYearView({model: year})
      @.$el.append(yearView.render().el)

  class StandardYearView extends Backbone.View 
    tagName: 'option'
    template: ->
      return _.template($("#standardYearView").text())
    render: ->
      yearTemplate = @template()(@model.toJSON())
      @.$el.html(yearTemplate)
      @

  class StandardYearsView extends Backbone.View
    tagName: 'select'
    render: ->
      @collection.each(@addYear, @)
      @
    addYear: (year)->
      yearView = new StandardYearView({model: year})
      @.$el.append(yearView.render().el)