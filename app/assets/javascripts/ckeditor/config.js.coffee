# Change this to force-refresh the JS/CSS files dynamically loaded
# by CKEditor.
CKEDITOR.timestamp = '20131125140627'

# Global Configuration
CKEDITOR.editorConfig = (config) ->
    config.extraPlugins = [
        'codemirror',
        'autosave',
        'embed-placeholder',
        'webkit-span-fix'
    ].join(',')

    config.codemirror =
        # https://github.com/w8tcha/CKEditor-CodeMirror-Plugin 
        theme                   : 'monokai'
        lineNumbers             : true
        lineWrapping            : true
        matchBrackets           : true
        matchTags               : true
        autoCloseTags           : false
        enableSearchTools       : false
        showSearchButton        : false
        enableCodeFolding       : true
        enableCodeFormatting    : true
        autoFormatOnStart       : false
        autoFormatOnUncomment   : false
        highlightActiveLine     : false
        highlightMatches        : false
        showTabs                : false
        showFormatButton        : false
        showCommentButton       : false
        showUncommentButton     : false

    config.autosave_SaveKey = "autosave-#{window.location.pathname}"

    config.toolbar = [
        ['Bold', 'Italic', 'Underline', "RemoveFormat"]
        ['NumberedList', 'BulletedList', 'Blockquote']
        ['Link', 'Unlink', 'Image', 'EmbedPlaceholder']
        ['Find', 'Paste']
        ['Source', 'Maximize']
    ]

    # Anything can have an ID or any class
    config.allowedContent = "*[id](*)"

    config.language     = 'en'
    config.height       = "400px"
    config.width        = "635px"
    config.bodyClass    = 'ckeditor-body'
    config.contentsCss  = "/assets/application.css?20131125"
    config.baseHref     = BASE_HREF

    config.disableNativeSpellChecker    = false
    config.forcePasteAsPlainText        = true

    true
