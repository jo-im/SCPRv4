CKEDITOR.timestamp = '20140219';

CKEDITOR.editorConfig = function(config) {

  config.toolbar = [
    ['Bold', 'Italic', 'Underline', "RemoveFormat"],
    ['NumberedList', 'BulletedList', 'Blockquote'],
    ['Link', 'Unlink', 'Image', 'EmbedPlaceholder'],
    ['Find', 'Paste'],
    ['Source', 'Maximize']
  ];

  config.extraPlugins = [
    'image', // This plugin has custom changes so we didn't include it in the build
    'autosave',
    'embed-placeholder',
    'webkit-span-fix'
  ].join(',');

  config.codemirror = {
    theme                   : 'monokai',
    mode                    : 'htmlmixed',
    useBeautify             : false,
    autoCloseBrackets       : true,
    autoCloseTags           : true,
    autoFormatOnStart       : false,
    autoFormatOnUncomment   : false,
    continueComments        : false,
    enableCodeFolding       : true,
    enableCodeFormatting    : true,
    enableSearchTools       : true,
    highlightActiveLine     : false,
    highlightMatches        : false,
    indentWithTabs          : false,
    lineNumbers             : true,
    lineWrapping            : true,
    matchBrackets           : true,
    matchTags               : true,
    showAutoCompleteButton  : true,
    showCommentButton       : false,
    showUncommentButton     : false,
    showFormatButton        : false,
    showSearchButton        : false,
    showTrailingSpace       : false
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
