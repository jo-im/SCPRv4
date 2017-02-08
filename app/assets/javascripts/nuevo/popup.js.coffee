$ = require('jquery')

$('a.b-popup__link').on 'click', (e) =>
  e.preventDefault()
  el = $(e.currentTarget)
  window.open el.attr('href'), 'pop_up',
    'height=350,width=556,'+
    'resizable,left=10,top=10,scrollbars=no,toolbar=no'
  false 