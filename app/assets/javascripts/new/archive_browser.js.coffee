scpr.ArchiveBrowser ?= {}

## EPISODES

class scpr.ArchiveBrowser.Episode extends Backbone.Model
  defaults:
    id: undefined
    title: "Untitled Episode"
    public_url: '#'
    air_date: undefined
    day: ->
      new Date(this.air_date).getDate() 
  parse: (response) ->
    return response

class scpr.ArchiveBrowser.EpisodesCollection extends Backbone.Collection
  model: scpr.ArchiveBrowser.Episode
  parse: (response) ->
    return response.episodes

class scpr.ArchiveBrowser.EpisodeView extends Backbone.View 
  tagName: 'li'
  className: 'Episode'
  template: ->
    return _.template($("#episodeView").text())
  render: ->
    episodeTemplate = @template()(@model.toJSON())
    @.$el.html(episodeTemplate)
    @

class scpr.ArchiveBrowser.EpisodesView extends Backbone.View
  tagName: 'ul'
  render: ->
    if @collection.length != 0
      @collection.each(@addEpisode, @)
    else
      @.$el.append("No episodes found.")
    @
  addEpisode: (episode)->
    episodeView = new scpr.ArchiveBrowser.EpisodeView({model: episode})
    @.$el.append(episodeView.render().el)


## MONTHS

class scpr.ArchiveBrowser.Month extends Backbone.Model
  defaults:
    name: undefined
  parse: (response) ->
    return {'name': response}

class scpr.ArchiveBrowser.MonthsCollection extends Backbone.Collection
  model: scpr.ArchiveBrowser.Month
  parse: (response) ->
    return response.months

class scpr.ArchiveBrowser.MonthView extends Backbone.View 
  tagName: 'li'
  className: 'Month'
  template: ->
    return _.template($("#monthView").text())
  render: ->
    monthTemplate = @template()(@model.toJSON())
    @.$el.html(monthTemplate)
    @

class scpr.ArchiveBrowser.MonthsView extends Backbone.View
  tagName: 'ul'
  render: ->
    @collection.each(@addMonth, @)
    @
  addMonth: (month)->
    monthView = new scpr.ArchiveBrowser.MonthView({model: month})
    @.$el.append(monthView.render().el)