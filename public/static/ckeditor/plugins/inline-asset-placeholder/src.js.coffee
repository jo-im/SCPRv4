CKEDITOR.config.autoParagraph = false
CKEDITOR.disableAutoInline = true

CKEDITOR.plugins.add 'inline-asset-placeholder',
  init: (editor) ->
    CKEDITOR.dialog.add 'inlineAssetOptions', (editor)->
      title: 'Inline Asset Options'
      minWidth: 200
      minHeight: 100
      contents: [
        id: 'info'
        elements: [
          id: 'align'
          type: 'select'
          label: 'Align'
          setup: ( widget ) ->
            this.setValue widget.data.align
          commit: (widget) ->
            #We are disabling this for the time-being
            #widget.setData 'align', this.getValue()
          items: [
            [ editor.lang.common.alignLeft, 'left' ]
            [ editor.lang.common.alignRight, 'right' ]
          ]
        ]
      ]

    editor.addCommand "dockAssetManager", 
      exec: 
        call: ->
          child = $("#form-block-asset-management.dockable").not('.docked')
          child.find("legend a.dock-control").trigger("click")

    editor.ui.addButton 'DockAssetManager', 
      label: "Dock Asset Manager",
      command: 'dockAssetManager',
      toolbar: 'insert'

    editor.widgets.add 'inline_asset_placeholder',
      dialog: "inlineAssetOptions"
      downcast: ->
        new CKEDITOR.htmlParser.element 'img',
          src: "#"
          class: "inline-asset"
          "data-asset-id": @data['asset-id']
          "data-align"   : @data['align']
      init: ->
        @setData 'asset-id', @element.$.dataset.assetId
        @setData 'align', @element.$.dataset.align
      render: ->
        if window.assetManager
          assetId = parseInt(@element.$.getAttribute('data-asset-id'))
          align   = @element.$.getAttribute('data-align')
          asset = window.assetManager.assets.where({id: assetId})[0].attributes
          thumbnail = new CKEDITOR.htmlParser.element 'img',
            src: asset.urls.thumb
            width: "120"
            height: "120"
            style: "float: left;"
          caption = new CKEDITOR.htmlParser.element 'div',
            class: "asset-info"
            style: "width: 200px; float: left;"
          small = new CKEDITOR.htmlParser.element 'small', 
            class: "muted"
          small.setHtml(asset.caption) if asset.caption
          caption.add small, 0
          html = thumbnail.getOuterHtml() + caption.getOuterHtml()
          @element.setHtml html
      data: ->
        @render()
        if window.assetManager
          window.assetManager.assets.on "reset", =>
            @render()
            
    editor.dataProcessor.dataFilter.addRules
      elements: 
        img: (element) ->
          if element.attributes["data-asset-id"] and element.attributes["class"] is "inline-asset"
            outerElement = new CKEDITOR.htmlParser.element 'div',
              'class': 'cke_inline_asset_placeholder'
              'data-asset-id': element.attributes["data-asset-id"]
              'data-align'   : element.attributes["data-align"]
              'min-height': '120px'
              'style': 'float: left; display: inline-block; width: 100%;'
            outerElement.add new CKEDITOR.htmlParser.text()
            widgetWrapper = editor.widgets.wrapElement(outerElement, 'inline_asset_placeholder')
            element.replaceWith widgetWrapper