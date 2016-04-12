class outpost.Autosave
  Handlebars   = require 'handlebars'
  moment       = require 'moment-strftime'
  PouchDB.plugin require 'pouchdb-upsert'
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
    @db           = new PouchDB(@options.databaseName, {auto_compaction: @options.autoCompaction, revs_limit: @options.revsLimit})
    @document     = $(document)
    @elementNames = [
      'input'
      'textarea'
      'select'
    ]
    @doc         = undefined
    @events      = {}
    @_watchCollections()
    @_initializeWarning()

  listen: ->
    # Listens for keypress and change events on our form.
    callback = (e) =>
      unless e.target.id is 'autosave-revisions'
        @shouldWarn = true
        @_cancelTimeout()
        @_waitAndSave()
    for event in ['keydown', 'keyup', 'change']  # this is because keypress isn't triggered by backspace
      @document.on event, callback

  unlisten: ->
    @_cancelTimeout()
    @fields().off 'change'

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
          @getDoc()
          callback(error, doc) if callback
        else
          if error.status is 409
            @db.upsert @options._id, -> doc
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
    ## Checks to see if the form values differ
    ## from those in the autosave snapshot. 

    mapToIds = (collection) ->
      ids = $.map collection, (model) ->
        model.id
      ids.sort()

    @getDoc (error, doc) =>
      unless error
        docA = @_serialize()
        docB = doc
        for key of docA.fields
          if docA.fields[key] isnt docB.fields[key]
            @_changesHaveBeenMade()
            return true
        for key of docA.collections
          if mapToIds(docA.collections[key]).toString() isnt mapToIds(docB.collections[key]).toString()
            @_changesHaveBeenMade()
            return true
    false

  updateRevisions: ->
    selectElement = $('select#autosave-revisions')
    if selectElement.length > 0
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

  fields: ->
    # Returns all input fields we should be looking at.
    query = []
    query.push("#main #{elName}[id]") for elName in @elementNames
    query = query.join(", ")
    $(query).not(':button').not('[type=hidden]').not('#autosave-revisions')

  # private

  _newDoc: ->
    {
      _id: @options._id
      id: @options.id
      type: @options.type
      author: @options.author
      fields: {}
      collections: {}
      markup: {}
    }

  _watchCollections: ->
    # Observes changes to collections so
    # we can know when to serialize them.
    $(document).ready =>
      for collectionName in (@options.collections or [])
        if collection = eval("window.#{collectionName}").collection 
          collection.on 'change', =>
            @_waitAndSave()

  _initializeWarning: ->
    # This displays a warning window if a user tries to leave
    # the page while they have unsaved changes.  The warning
    # should not display if they have clicked 'Save', or if
    # no changes have occurred.
    @shouldWarn  = false
    $("form.simple_form").on 'submit', =>
      @shouldWarn = false
      true
    $(window).on 'beforeunload', =>
      if @shouldWarn
        return 'This content has unsaved changes.  If you want to keep these changes, you can stay on the page and click \'Save\'.'


  _waitAndSave: ->
    ## Will save the document after 1 second unless
    ## the timeout is cancelled by more typing.
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
    # Displays modal if changes are detected
    # in the autosaved document on page load.
    @shouldWarn = true
    modalHTML = @_render
      template: '#autosave-recovery-modal-body-template'
      locals: 
        timestamp: moment(@doc.updatedAt).strftime('%m/%d/%y %I:%M %p')
    @_createModal 'You have some unsaved changes.', modalHTML

  _createModal: (title, body) ->
    # General purpose method for displaying a modal.
    html = @_render
      template: '#autosave-modal-template'
      locals:
        title: title
        body: body
    $('body').append html
    modal         = $('#autosave-modal')
    modal.one 'click', 'button', (e) =>
      if e.target.id is 'yes'
        @_reflect()
      else if e.target.id is 'no'
        @removeDoc()
      modal.remove()
    modal.modal({show: true, background: true})

  _render: (options={}) ->
    ## Renders a Handlebars template.
    ## Pass in a tag ID through the `template` option.
    ## Pass variables through the `locals` option.
    options.locals ||= {}
    if options.template
      source   = $(options.template).html()
      template = Handlebars.compile(source)
      template(options.locals)

  _trigger: (name, doc) ->
    @events[name] ||= []
    for f in @events[name]
      f(doc)

  _reflect: ->
    # Take an autosaved document, if it exists,
    # and display the values of its fields
    # in the form on the page.
    @getDoc (error, doc) =>
      unless error
        @_trigger('reflect', doc)
        # fields
        for key of (doc.fields ||= {})
          el    = $("#main ##{key}")
          if el.length > 0
            type  = el.attr('type') or el.prop("tagName")?.toLowerCase()
            value = doc.fields[key]
            @DefaultReflectors["#{type}Reflector"]?(el, value)
        # collections
        for name of (doc.collections ||= {})
          if collectionView = eval("window.#{name}")
            collection = collectionView.collection
            @DefaultReflectors["collectionReflector"]?(name, collection, doc.collections[name])
        # elements
        for selector of (doc.elements ||= {})
          el = $(selector)
          if el.length > 0
            @DefaultReflectors["elementReflector"]?(el, doc.elements[selector])

  _serialize: ->
    # Convert the form fields on the page to a JSON
    # document that can be used to save to PouchDB.
    doc = 
      fields:      {}
      collections: {}
      elements:    {}
    # fields
    for field in @fields()
      field         = $(field)
      if field.length > 0
        fieldId       = field.attr('id')
        type          = field.attr('type') or field.prop("tagName")?.toLowerCase()
        doc.fields[fieldId]  = @DefaultSerializers["#{type}Serializer"]?(field)
    # collections (e.g. asset manager, content aggregator)
    for name in (@options.collections or [])
      if collectionView = eval("window.#{name}")
        doc.collections[name] = @DefaultSerializers["collectionSerializer"]?(name, collectionView.collection)
    # elements (e.g. stuff like bylines where fields might be dynamically appended)
    for selector of (@options.elements or [])
      el = $(selector)
      if el.length > 0
        doc.elements[selector] = @DefaultSerializers["elementSerializer"]?($(selector))
    @_trigger('serialize', doc)
    doc

  _writeDialog: (text) ->
    # Writes a snippet of text to the submit-row.
    # Could be useful to display status.
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
    collectionSerializer: (name, collection) ->
      collection.toJSON()
    elementSerializer: (el) ->
      el.html()

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
    collectionReflector: (name, collection, json) ->
      collection.update json
      if collectionView = eval("window.#{name}")
        collectionView.render()
    elementReflector: (el, value) ->
      el.html doc.elements[selector]