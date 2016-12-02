# This adjusts the height of the page to fit the content.
# Not the greatest thing in the world, but enables us to 
# very easily arrange items on the homepage using only CSS.
#
# It's mostly an issue on IE and Firefox.  Webkit/Blink based 
# browsers clear the whitespace at the bottom of the page after
# transform:translateY for some reason.

footerEl     = $('.o-footer')
pageAdjuster = =>
  $('.l-page').addClass('l-page--adjusted');
  $('.l-page').height footerEl.offset().top + footerEl.height() + parseInt($('.o-footer').css('padding-top'))

$(window).on 'resize', pageAdjuster

# Observe root HTML element for classes added by TypeKit
observer = new MutationObserver pageAdjuster
observer.observe document.querySelector('html'), { attributes: true }

# Observe ads and adjust to them when they load.
observer = new MutationObserver pageAdjuster
observer.observe document.querySelector('.dfp'), { childList: true }

# Observe election results
observer = new MutationObserver pageAdjuster

pageAdjsuter();

## Just leaving this here for future reference.  Might save me a few minutes. :grin:
# $("#hero-election-2016").one 'DOMNodeInserted', ->
#   $("#hero-election-2016 iframe").on 'DOMSubtreeModified', ->
#     pageAdjuster()
  # observer.observe document.querySelector('.hero-election-2016 iframe'),
  #   childList: true
  #   attributes: true
  #   characterData: true
  #   attributeOldValue: true
  #   characterDataOldValue: true
  #   attributeFilter: true
  #   subtree: true