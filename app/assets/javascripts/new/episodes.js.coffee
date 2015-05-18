class scpr.Episode extends Backbone.Model
  defaults:
    id: undefined
    title: "Untitled Episode"
    public_url: '#'
    published_at: undefined
    day: ->
      new Date(this.published_at).getDate() 

class scpr.EpisodesCollection extends Backbone.Collection
  model: scpr.Episode
  parse: (response) ->
    return response.episodes

class scpr.EpisodeView extends Backbone.View 
  tagName: 'li'
  className: 'Episode'
  template: ->
    return _.template($("#episodeView").text())
  render: ->
    episodeTemplate = @template()(@model.toJSON())
    @.$el.html(episodeTemplate)
    @

class scpr.EpisodesView extends Backbone.View
  tagName: 'ul'
  render: ->
    if @collection.length != 0
      @collection.each(@addEpisode, @)
    else
      @.$el.append("No episodes found.")
    @
  addEpisode: (episode)->
    episodeView = new scpr.EpisodeView({model: episode})
    @.$el.append(episodeView.render().el)
