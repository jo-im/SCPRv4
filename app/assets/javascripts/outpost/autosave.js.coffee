class outpost.Autosave
  Handlebars = require 'handlebars'
  moment     = require 'moment-strftime'

  constructor: (options={}) ->
    @options = 
      _id           : 'new'
      id            : undefined  # this is the ID 
      author        : 'anonymous'
      type          : 'document'
      databaseName  : 'scprv4_outpost'
      autoCompaction: true
      revsLimit     : 100
    for option of options
      @options[option] = options[option]
    @db         = new PouchDB(@options.databaseName, {auto_compaction: @options.autoCompaction, revs_limit: @options.revsLimit})
    @document   = $(document)
    @elementNames = [
      'input'
      'textarea'
      'select'
    ]
    query = []
    query.push("#main #{elName}[id]") for elName in @elementNames
    @query = query.join(", ")
    @fields     = $(@query).not(':button').not(':hidden').not('#autosave-revisions')
    @doc        = undefined
    @events     = {}

  listen: ->
    callback = (e) =>
      unless e.target.id is 'autosave-revisions'
        @_cancelTimeout()
        @_waitAndSave()
    for event in ['keydown', 'keyup', 'change']  # this is because keypress isn't triggered by backspace
      @document.on event, callback

  unlisten: ->
    @_cancelTimeout()
    @fields.off 'change'

  getDoc: (options={}, callback) ->
    if typeof options is 'function'
      callback = options
      options  = {}
    options.revs ||= true
    @db.get @options._id, options, (error, doc)=>
      unless error
        @doc = doc
        @updateRevisions()
        callback(error, doc) if callback
      else
        callback(error) if callback
        throw error

  saveDoc: (options={}, callback)->
    if typeof options is 'function'
      callback = options
      options  = {}
    options.revs     ||= true
    @getDoc options, (error, doc) =>
      if error?.status is 404
        doc  = @_newDoc()
      else if error
        throw error 
      mdoc = @_mergeDocs @_serialize(), (doc or {})
      mdoc.updatedAt = new Date()
      @db.put mdoc, options, (error, doc) =>
        unless error
          @options._id = doc.id
          @getDoc (error, doc) =>
            timestamp = moment(doc.updatedAt).strftime('%m/%d/%y %I:%M:%S %p')
            @_writeDialog "Local copy stored @ #{timestamp}"
          callback(error, doc) if callback
        else
          callback(error) if callback
          throw error

  removeDoc: (options={}, callback) ->
    if typeof options is 'function'
      callback = options
      options  = {}
    options.revs     ||= true
    @db.remove @doc, options, (error, doc) =>
      unless error
        console.log 'doc removed'
        callback(error, doc) if callback
      else
        callback(error) if callback
        throw error if error

  checkForChanges: ->
    @getDoc (error, doc) =>
      unless error
        for field in @fields
          field = $(field)
          field_id = field.attr('id')
          if field.val() isnt doc[field_id]
            @_changesHaveBeenMade()
            return true
    false

  updateRevisions: ->
    selectElement = $('select#autosave-revisions')
    selectElement.html('')
    for revision in @revisions()
      selectElement[0].innerHTML += "<option value='#{revision}'>#{revision}</option>"
    selectElement.select2 'val', (@doc._rev or '').match(/-(.*)/)[1]
    selectElement.on 'change', =>
      @getDoc({rev: selectElement.val()})

  revisions: ->
    revisionIds        = (@doc?._revisions?.ids or [])
    i = revisionIds.length + 1
    numerizedRevisions = []
    for revisionId in revisionIds
      numerizedRevisions.push "#{i}-#{revisionId}"
      i--
    numerizedRevisions

  on: (name, callback) ->
    @events[name] ||= []
    @events[name].push callback

  # private

  _newDoc: ->
    {_id: @options._id, id: @options.id, type: @options.type, author: @options.author}

  _waitAndSave: ->
    callback = => @saveDoc()
    @timeout = setTimeout callback, 1000 

  _cancelTimeout: ->
    clearTimeout(@timeout) if @timeout

  _mergeDocs: (a, b) ->
    # changes from a merge into b
    # not destructive
    mergedDoc = {}
    for key of b
      mergedDoc[key] = b[key]
    for key of a
      mergedDoc[key] = a[key]
    mergedDoc

  _changesHaveBeenMade: ->
    timestamp = moment(@doc.updatedAt).strftime('%m/%d/%y %I:%M %p')
    message   = "Outpost has recovered unsaved changes you made on #{timestamp}.\n
            Click YES to RESTORE your unsaved changes.\n
            Click NO  to LOSE your unsaved changes.\n
            HINT: If your computer or browser crashed and you need to get your work back, click YES.\n
            It's always safer to click YES."
    @_createModal 'You have some unsaved changes.', message

  _createModal: (title, body) ->
    modalSource   = $('#autosave-modal-template').html()
    modalTemplate = Handlebars.compile(modalSource)
    bodyTemplate  = Handlebars.compile(body)
    modalHTML     = modalTemplate({title: title, body: bodyTemplate()})
    $('body').append modalHTML
    modal         = $('#autosave-modal')
    modal.one 'click', 'button', (e) =>
      if e.target.id is 'yes'
        @_reflect()
      else if e.target.id is 'no'
        @removeDoc()
      modal.remove()
    modal.modal({show: true, background: true})

  _trigger: (name, doc) ->
    @events[name] ||= []
    for f in @events[name]
      f(doc)

  _reflect: ->
    @getDoc (error, doc) =>
      unless error
        @_trigger('reflect', doc)
        for key of doc
          el    = $("#main ##{key}")
          if el.length > 0
            type  = el.attr('type') or el.prop("tagName")?.toLowerCase()
            value = doc[key]
            @DefaultReflectors["#{type}Reflector"]?(el, value)

  _serialize: ->
    doc = {}
    for field in @fields
      field         = $(field)
      if field.length > 0
        fieldId       = field.attr('id')
        type          = field.attr('type') or field.prop("tagName")?.toLowerCase()
        doc[fieldId]  = @DefaultSerializers["#{type}Serializer"]?(field)
    @_trigger('serialize', doc)
    doc

  _writeDialog: (text) ->
    $(".submit-row span#dialog").text text

  DefaultSerializers: 
    ## Serializers are used to convert a field element
    ## to a value in a PouchDB document.
    ## The return value is assigned to the field.
    checkboxSerializer: (el) ->
      el.prop('checked')
    textSerializer: (el) ->
      el.val()
    textareaSerializer: (el) ->
      el.val()
    selectSerializer: (el) ->
      el.val()

  DefaultReflectors:
    ## Reflectors are used to take values stored in a
    ## document and display them properly in the DOM.
    ## Assign the value to the element according to type.
    checkboxReflector: (el, value) ->
      el.prop 'checked', value
    textReflector: (el, value) ->
      el.prop 'value', value
    textareaReflector: (el, value) ->
      el.val value
    selectReflector: (el, value) ->
      el.select2('val', value)