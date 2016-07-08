Framework = require('framework')
ArticleCollection = require('./article-collection')
module.exports = class extends Framework.Model.mixin(Framework.Persistent)
  name: 'article'
  states: ['new', 'seen', 'read']
  defaults:
    state: 'new'
  init: ->
    @load(['state']) # get saved attributes from localstorage, if any
    @listenTo @, 'change', => @save()
  whatsNext: ->
    (@collection or new ArticleCollection).whatsNext()
  isLastArticle: ->
    @collection.last() is @