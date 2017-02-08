class scpr.ArchiveBrowser
  constructor: (finder, @program) ->
    scpr.ArchiveBrowser.active ?= []
    scpr.ArchiveBrowser.active.push @

    @element = $(finder)
    @episodes = new Episodes [], url:"/api/v3/programs/#{@program}/episodes/archive/"

    @episodesView = new EpisodesView collection:@episodes, el:@element.find(".results ul")

    $.get "/api/v3/programs/#{@program}/histogram", (data) =>
      # histogram has a collection of years, each of which have a collection of months
      @histogram  = new Histogram(data.histogram)

      @standardPicker = new StandardPicker model:@histogram, el:@element.find(".standard-picker")
      @liminalPicker  = new LiminalPicker model:@histogram, el:@element.find(".liminal-picker")

      @standardPicker.render()
      @liminalPicker.render()

      setYear = (y) =>
        @histogram.set year:y

      @standardPicker.on "click:year", setYear
      @liminalPicker.on "click:year", setYear

      setMonth = (m) =>
        @histogram.set month:m

      @standardPicker.on "click:month", setMonth
      @liminalPicker.on "click:month", setMonth

      @histogram.on "change", =>
        @getEpisodes @histogram.get("month")

      # load our initial episodes
      @getEpisodes @histogram.get("month")

  getEpisodes: (month) ->
    @episodes.load(month.get("year"),month.get("month"))

  ## Child Classes

  # standard picker is an element with selects for years and months
  class StandardPicker extends Backbone.View
    initialize: ->
      @template = _.template $("#standardPicker").text()

      @model.on "change", =>
        @render()

    events:
      "change .years select ": "_changeYear"
      "change .months select": "_changeMonth"

    _changeYear: (evt) ->
      year = evt.currentTarget.selectedOptions[0].value
      y = @model.years.get(year)
      @trigger "click:year", y

    _changeMonth: (evt) ->
      month = evt.currentTarget.selectedOptions[0].value
      m = @model.get("year").months.get(month)
      @trigger "click:month", m

    render: ->
      @$el.html @template()

      cy = @model.get("year")
      cm = @model.get("month")

      # fill in our selects
      @$(".years select").html @model.years.collect (y) =>
        el = $("<option/>").attr("value",y.get("year")).text y.get("year")

        if y == cy
          el.attr("selected","selected")

        el

      @$(".months select").html @model.get("year").months.collect (m) =>
        el = $("<option/>").attr("value",m.get("month")).text m.get("name")

        el.attr("selected","selected") if m == cm

        el

      @

  class LiminalItem extends Backbone.View
    tagName: "li"

    events:
      click: "_click"

    initialize: (opts) ->
      @nameAttr = opts.nameAttr
      @selected = opts.selected || false

    _click: (evt) ->
      @trigger "click", evt, @model

    render: ->
      monthDictionary =
        January: "JAN"
        February: "FEB"
        March: "MAR"
        April: "APR"
        May: "MAY"
        June: "JUNE"
        July: "JULY"
        August: "AUG"
        September: "SEPT"
        October: "OCT"
        November: "NOV"
        December: "DEC"

      timeFrame = @model.get(@nameAttr)

      option = if typeof timeFrame is 'number' then timeFrame else monthDictionary[@model.get(@nameAttr)]

      @$el.html $("<span/>").text option
      @$el.addClass "selected" if @selected
      @

  class LiminalPicker extends Backbone.View
    initialize: ->
      @template = _.template $("#liminalPicker").text()

      @model.on "change", =>
        @render()

    render: ->
      @$el.html @template()

      cy = @model.get("year")
      cm = @model.get("month")

      @$(".years ul").html @model.years.collect (y) =>
        v = new LiminalItem model:y, nameAttr:"year", selected:(y == cy)
        v.on "click", => @trigger "click:year", y
        v.render().el

      @$(".months ul").html @model.get("year").months.collect (m) =>
        v = new LiminalItem model:m, nameAttr:"name", selected:(m == cm)
        v.on "click", => @trigger "click:month", m
        v.render().el

      @

  #----------

  class Histogram extends Backbone.Model
    initialize: ->
      @years = new HistogramYearCollection @attributes.years

      # to start, set active to to last month of the first (newest) year
      active = @years.first().months.last()
      @set year:active.collection.year, month:active

      @on "change:year", =>
        # is our current month available in the new year?
        if m = @attributes.year.months.get( @attributes.month.id )
          # yes... use it
          @set month:m
        else
          # no... use the last month
          @set month:@attributes.year.months.last()

  class HistogramMonth extends Backbone.Model
    idAttribute: "month"

  class HistogramMonthCollection extends Backbone.Collection
    model: HistogramMonth
    initialize: (data,opts) ->
      @year = opts.year

  class HistogramYear extends Backbone.Model
    idAttribute: "year"
    initialize: ->
      @months = new HistogramMonthCollection @attributes.months, year:@

  class HistogramYearCollection extends Backbone.Collection
    model: HistogramYear
    comparator: (m) -> -1 * m.get('year')

  #----------

  ## Models, views, collections

  ## EPISODES

  class Episode extends Backbone.Model
    initialize: ->
      @attributes.day = (new Date(@attributes.air_date)).getDate()

  class Episodes extends Backbone.Collection
    model: Episode

    initialize: (data, options) ->
      @url = options.url

    load: (year,month) ->
      $.getJSON "#{@url}/#{year}/#{month}", (data) =>
        @reset data.episodes

      true

  #----------

  class EpisodeView extends Backbone.View
    tagName: 'li'
    className: 'episode'

    initialize: ->
      @template = _.template $("#episodeView").text()

    render: ->
      @$el.html @template @model.toJSON()
      @

  class EpisodesView extends Backbone.View
    tagName: 'ul'

    initialize: ->
      @collection.on "reset", =>
        @render()

    render: ->
      if @collection.length > 0
        @$el.html @collection.collect (ep) => (new EpisodeView model:ep).render().el
      else
        @$el.text "No episodes found."

      @
