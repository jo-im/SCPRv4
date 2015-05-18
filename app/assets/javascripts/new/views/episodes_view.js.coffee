class scpr.EpisodesView extends Backbone.View
  tagName: 'ul'
  render: ->
    @collection.each(@addEpisode, @)
    @
  addEpisode: (episode)->
    episodeView = new scpr.EpisodeView({model: episode})
    @.$el.append(episodeView.render().el)
