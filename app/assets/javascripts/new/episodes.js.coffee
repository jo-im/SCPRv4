scpr.Behaviors.Episodes = loadBehaviors: ->

  # SINGLE EPISODE: Different aspect-ratios mean different faux-positionings.
  # ---------------------------------------------------------
  if $('body').hasClass('episode')
    $('.episode-enumeration > article img').each ->
      myWidth = $(this).attr('data-width')
      myHeight = $(this).attr('data-height')
      myRatio = myWidth / myHeight
      if myRatio > 1.5
        $(this).closest('article').addClass 'ratio-squat'
      else if myRatio < 1.0
        $(this).closest('article').addClass 'ratio-tall'
      return

  # SINGLE EPISODE: Cosmetic toggle for full results in the episode archive browser
  # ---------------------------------------------------------
  $('.show-full-results').click ->
    $('.results').addClass 'show-everything'
    false