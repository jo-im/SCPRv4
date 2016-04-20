CKEDITOR.timestamp = '20140219';

CKEDITOR.editorConfig = function(config) {

  config.toolbar = [
    ['Format', 'Bold', 'Italic', 'Underline', "RemoveFormat"],
    ['NumberedList', 'BulletedList', 'Blockquote'],
    ['Link', 'Unlink', 'DockAssetManager', 'EmbedPlaceholder'],
    ['Find', 'Paste'],
    ['Source', 'Maximize']
  ];

  config.format_tags = 'p;h2;h3';

  config.extraPlugins = [
    'image', // This plugin has custom changes so we didn't include it in the build
    'embed-placeholder',
    'webkit-span-fix',
    'divarea',
    'inline-asset-placeholder',
    'widget',
    'dialog',
    'lineutils',
    'clipboard',
  ].join(',');

  config.codemirror = {
    theme                   : 'monokai',
    mode                    : 'htmlmixed',
    useBeautify             : false,
    autoCloseBrackets       : false,
    autoCloseTags           : false,
    autoFormatOnStart       : false,
    autoFormatOnUncomment   : false,
    continueComments        : false,
    enableCodeFolding       : true,
    enableCodeFormatting    : true,
    enableSearchTools       : true,
    highlightActiveLine     : false,
    highlightMatches        : true,
    indentWithTabs          : false,
    lineNumbers             : true,
    lineWrapping            : true,
    matchBrackets           : true,
    matchTags               : true,
    showTrailingSpace       : false,
    showAutoCompleteButton  : false,
    showCommentButton       : false,
    showUncommentButton     : false,
    showFormatButton        : false,
    showSearchButton        : false
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
