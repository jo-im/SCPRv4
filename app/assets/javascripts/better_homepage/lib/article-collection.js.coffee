Framework = require('framework')
module.exports = class extends Framework.Collection
  name: 'article-collection'
  model: require('./article')
  whatsNext: ->
    fc = @filter (model, index) => model.get('state') == 'new' # is below the top 3 stories
    firstIndex  = Math.round(fc.length * 0.5) - 1
    secondIndex = Math.round(fc.length * 0.75) - 1
    thirdIndex  = fc.length - 1
    _.reject [fc[firstIndex], fc[secondIndex], fc[thirdIndex]], (m) => m is undefined 