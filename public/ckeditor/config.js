CKEDITOR.timestamp = '20140205121936';

CKEDITOR.editorConfig = function(config) {

  config.toolbar = [
    ['Bold', 'Italic', 'Underline', "RemoveFormat"],
    ['NumberedList', 'BulletedList', 'Blockquote'],
    ['Link', 'Unlink', 'Image', 'EmbedPlaceholder'],
    ['Find', 'Paste'],
    ['Source', 'Maximize']
  ];

  config.extraPlugins = [
    'codemirror',
    'autosave',
    'embed-placeholder',
    'webkit-span-fix'
  ].join(',');

  config.codemirror = {
    theme                   : 'monokai',
    lineNumbers             : true,
    lineWrapping            : true,
    matchBrackets           : true,
    matchTags               : true,
    autoCloseTags           : false,
    enableSearchTools       : false,
    showSearchButton        : false,
    enableCodeFolding       : true,
    enableCodeFormatting    : true,
    autoFormatOnStart       : false,
    autoFormatOnUncomment   : false,
    highlightActiveLine     : false,
    highlightMatches        : false,
    showTabs                : false,
    showFormatButton        : false,
    showCommentButton       : false,
    showUncommentButton     : false
  };

  config.autosave_SaveKey           = "autosave-" + window.location.pathname;
  config.disableNativeSpellChecker  = false;
  config.forcePasteAsPlainText      = true;

  config.allowedContent   = "*[id](*)";

  config.language         = 'en';
  config.height           = "400px";
  config.width            = "635px";

  config.bodyClass        = 'ckeditor-body';
  config.contentsCss      = APPLICATION_CSS;
  config.baseHref         = BASE_HREF;

  return true;
};
