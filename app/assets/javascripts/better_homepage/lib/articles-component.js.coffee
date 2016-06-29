Framework        = require('framework')
ArticleComponent = require('./article-component')
module.exports   = class extends Framework.Component
  name: 'articles-component'
  components:
    article: ArticleComponent
  init: (options={}) ->
    @options.headless = true
    for model in @collection.models
      objKey = model.get('id')
      new ArticleComponent
        model: model
        el: @$el.find("[data-obj-key='#{objKey}']")