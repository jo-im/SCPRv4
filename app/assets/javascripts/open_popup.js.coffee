# Open the Listen Live window
window.open_popup = (url) ->
    window.open(
        url,
        'pop_up',
        'height=800,'+
        'width=556,'+
        'resizable,'+
        'left=10,'+
        'top=10,'+
        'scrollbars=yes,'+
        'toolbar=no'
    )

    false
