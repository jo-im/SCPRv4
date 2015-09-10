$(document).ready ->
  CKEDITOR.on "instanceReady", (env)->
    editor = env.editor
    editorElementName = "cke_#{editor.name}"
    editorElement = editor.document.getById(editorElementName)
    editorElement.on "dragover", (ev) ->
      ev.data.preventDefault()
    editorElement.on "drop", (ev) ->
      if (assetId = ev.data.$.dataTransfer.getData('asset-id')) and ($(editorElement.$).find(".cke_inline_asset_placeholder[data-asset-id=" + assetId + "]").length < 1)
        ev.data.preventDefault()
        shortcode = new CKEDITOR.htmlParser.element 'img',
          class: "inline-asset"
          "data-asset-id": assetId
          src: "#"
        editor.insertHtml(shortcode.getOuterHtml())
    assetList = CKEDITOR.document.getById('form-block-asset-management')
    assetList.on 'dragstart', (evt) ->
      if assetId = evt.data.getTarget().$.getAttribute('data-asset-id')
        dataTransfer = evt.data.$.dataTransfer
        dataTransfer.setData("text/html", "")
        dataTransfer.setData("asset-id", assetId)