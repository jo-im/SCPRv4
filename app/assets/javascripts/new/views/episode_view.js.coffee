temp = '<li><a href="<%= url %>"><time datetime="<%= published_at %>">1</time> <span><%= headline %></span></a></li>'

class @scpr.EpisodeView extends Backbone.View 
  tagName: 'li'
  className: 'Episode'
  template: _.template(temp)
  render: ->
    episodeTemplate = @template(@model.toJSON())
    @.$el.html(episodeTemplate)
    @
