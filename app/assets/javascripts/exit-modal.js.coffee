$(document).ready( ->
  modalContent = $('#exit-modal')
  if modalContent.length
    modalContent.insertAfter('main')
    modal = new Modal()
    modal.bindExitEventListeners()
    modal.bindCloseEventListeners()
)

Modal = ->
  this.scrollSensitivity = -4
  this.throttleDelay = 250
  this.mouseLeaveSensitivity = 0
  this.lastOffset = $(window).scrollTop()
  this.lastDate = new Date().getTime()
  this.modalVisited = false

  this.scrollHandler = this.scrollHandler.bind this
  this.mouseLeaveHandler = this.mouseLeaveHandler.bind this
  this.closeModal = this.closeModal.bind this
  return

Modal.prototype.openModal = ->
  modal = $('#exit-modal')
  if !this.modalVisited
    gaDataset = modal.data()
    ga('send', 'event', 'Modal', 'Open Modal', gaDataset.gaModalLabel, {'nonInteraction': true});
    modal.removeClass 'exit-modal--hidden'
    modal.addClass 'exit-modal--shown'
    this.modalVisited = true

Modal.prototype.closeModal = (event) ->
  modal = $('#exit-modal')
  if event.type is 'click' or event.keyCode is 27
    gaDataset = modal.data()
    ga('send', 'event', 'Modal', 'Close Modal', gaDataset.gaModalLabel, {'nonInteraction': true});
    modal.removeClass 'exit-modal--shown'
    modal.addClass 'exit-modal--hidden'

Modal.prototype.scrollHandler = (event) ->
  delay = event.timeStamp - this.lastDate
  offset = event.target.scrollingElement.scrollTop - this.lastOffset
  speed = offset / delay
  this.lastDate = event.timeStamp
  this.lastOffset = event.target.scrollingElement.scrollTop
  if speed <= this.scrollSensitivity
    this.openModal $('#exit-modal')

Modal.prototype.mouseLeaveHandler = (event) ->
  if (event.clientY <= this.mouseLeaveSensitivity)
    this.openModal $('#exit-modal')

Modal.prototype.bindExitEventListeners = ->
  throttledScrollHandler = _.throttle(this.scrollHandler, this.throttleDelay)
  if /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test navigator.userAgent
    $(window).on('scroll', throttledScrollHandler)
  else
    $(window).on('mouseleave', this.mouseLeaveHandler)

Modal.prototype.bindCloseEventListeners = ->
  $('.exit-modal__underlay').on('click', this.closeModal)
  $('.exit-modal__close-button').on('click', this.closeModal)
  $(document).on('keyup', this.closeModal)
