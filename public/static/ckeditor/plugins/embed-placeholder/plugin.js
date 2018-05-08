/*
* Dialogue to add Embed placeholders.
*
* Plugin name:      embed-placeholder
* Menu button name: EmbedPlaceholder
*
* @author Bryan Ricker / SCPR
* @version 0.1
*/


(function() {
    var pluginName      = 'embed-placeholder',
        dialogName      = 'embed-placeholder-dialog',
        command         = 'openEmbedPlaceholderDialog',
        button          = 'EmbedPlaceholder', // icon must match this, lowercased.
        icon            = 'embedplaceholder',
        services        = [
          ['Brightcove', 'brightcove', 'brightcove.com'],
          ['Cover It Live', 'coveritlive', 'coveritlive.com'],
          ['DocumentCloud', 'documentcloud', 'documentcloud.org'],
          ['Ranker', 'ranker', 'ranker.com'],
          ['Facebook', 'facebook', 'facebook.com'],
          ['Fire Tracker', 'firetracker', 'firetracker.scpr.org'],
          ['Google Maps', 'googlemaps', 'maps.google.com'],
          ['Google Fusion', 'googlefusion', 'fusiontables'],
          ['Instagram', 'instagram', 'instagram.com'],
          ['LiveStream', 'livestream', 'livestream.com'],
          ['NBC Bay Area', 'nbc', 'nbcbayarea.com'],
          ['NBC Los Angeles', 'nbc', 'nbclosangeles.com'],
          ['Polldaddy', 'polldaddy', 'polldaddy.com'],
          ['RebelMouse', 'rebelmouse', 'rebelmouse.com'],
          ['Scribd', 'scribd', 'scribd.com'],
          ['SoundCloud', 'soundcloud', 'soundcloud.com'],
          ['Spotify', 'spotify', 'spotify.com'],
          ['Storify', 'storify', 'storify.com'],
          ['Twitter', 'twitter', 'twitter.com'],
          ['Ustream', 'ustream', 'ustream.tv'],
          ['Vimeo', 'vimeo', 'vimeo.com'],
          ['Vine', 'vine', 'vine.co'],
          ['YouTube', 'youtube', 'youtube.com'],
          ['Other (Embedly)', 'other', '']
        ];

    var selectItems = [['Select a Service:', '']];

    for (var i = 0; i < services.length; i++) {
      var service = services[i];
      selectItems.push([service[0], service[1]])
    }

    CKEDITOR.plugins.add(pluginName, {
      hidpi: true,
      icons: icon,

      findService: function(text) {
        if (!text) return;
        var foundService;

        for (var i = 0; i < services.length; i++) {
          var service = services[i];

          if (text.match(service[2])) {
            foundService = service[1];
            break;
          }
        }

        return foundService;
      },

      init: function(editor) {
        var plugin = this;

        CKEDITOR.dialog.add(dialogName, function (instance) {
          return {
            title       : 'Embed Placeholder',
            minWidth    : 550,
            minHeight   : 200,

            contents : [
              {
                id        : 'embed',
                label     : 'Embed via URL',
                elements  : [
                  {
                    id          : 'embedUrl',
                    type        : 'text',
                    label       : '<strong>URL</strong> (<a href="' +
                                  'http://scpr.github.io/oembed-manual/' +
                                  '" target="_blank">Help</a>)',
                    autofocus   : 'autofocus',

                    onBlur : function() {
                      var service = plugin.findService(this.getValue().trim());

                      this.getDialog().getContentElement(
                        'embed', 'embedService').setValue(service);
                    },
                    validate : function() {
                      if (this.getDialog().getContentElement(
                        'embed-code', 'embedCode').getValue().trim()
                      ) return true;

                      if(!this.getValue()) {
                        alert("URL can't be empty.")
                        return false
                      }
                    } // validate
                  }, // embedUrl
                  {
                    id      : 'embedService',
                    type    : 'select',
                    label   : '<strong>Service</strong><br />',
                    items   : selectItems,

                    validate : function() {
                      if(!this.getValue()) {
                        alert("Service can't be empty.")
                        return false
                      }
                    } // validate
                  }, // embedService
                  {
                    id      : 'linkTitle',
                    type    : 'text',
                    label   : 'Link Title (optional)<br />' +
                              '<small>The URL will be used if no title is ' +
                              'specified. To hide this, select ' +
                              '"No Title" in the Advanced tab.</small>'
                  } // linkTitle
                ] // elements
              }, // embed
              {
                id        : 'embed-advanced',
                label     : 'Options',
                elements  : [
                  {
                    id      : 'embedMaxHeight',
                    type    : 'text',
                    label   : 'Embed Maximum Height (Optional)<br />' +
                              '<small>' +
                              'This parameter is not honored by all ' +
                              'embeds. It is recommended that you ' +
                              'leave it blank unless necessary.</small>',
                    width   : '45px',

                    onLoad: function() {
                      $('input', '#'+this.domId).after(' <strong>px</strong>')
                    }
                  }, // embedMaxHeight
                  {
                    id          : 'embedPlacement',
                    type        : 'select',
                    label       : '<strong>Placement</strong>',
                    'default'   : 'replace',

                    // The options are actually the placement of the
                    // Embed relative to the Title. For the end-user,
                    // it's less confusing to think of it was where the
                    // Title is.
                    items   : [
                      ['No Title', 'replace'],
                      ['Title on Top', 'after'],
                      ['Title on Bottom', 'before']
                    ] // items
                  } // embedPlacement
                ] // elements
              }, // embed-advanced
              {
                id        : 'embed-code',
                label     : 'Embed via Code',
                elements  : [
                  {
                    id    : 'embedCodeHelp',
                    type  : 'html',
                    html  : "If embedding via URL isn't working, you can " +
                           "still paste in an embed code here."
                  }, // embedCodeHelp
                  {
                    id      : 'embedCode',
                    type    : 'textarea',
                    label   : 'Embed Code',
                    onBlur: function() {
                      var service = plugin.findService(this.getValue().trim());

                      this.getDialog().getContentElement(
                        'embed', 'embedService').setValue(service);
                    }
                  } // embedCode
                ] // elements
              } // embed-code
            ], // contents

            onOk: function() {
              var p = editor.document.createElement('p');
              var html;

              var embedCode = this.getContentElement(
                'embed-code', 'embedCode').getValue().trim();

              if (embedCode) {
                // Force a wrapper around the embed, for styling.
                service     = this.getContentElement(
                                'embed', 'embedService'
                              ).getValue();

                var classNames = "embed-wrapper"
                if (service) {
                  classNames += " " + service
                }

                var div = $('<div />', { class: classNames });
                div.html(embedCode);
                html = div[0].outerHTML;

              } else {

                var url         = this.getContentElement(
                                    'embed', 'embedUrl'
                                  ).getValue().trim(),

                    title       = this.getContentElement(
                                    'embed', 'linkTitle'
                                  ).getValue(),

                    maxheight   = this.getContentElement(
                                    'embed-advanced', 'embedMaxHeight'
                                  ).getValue(),

                    placement   = this.getContentElement(
                                    'embed-advanced', 'embedPlacement'
                                  ).getValue(),

                    service     = this.getContentElement(
                                    'embed', 'embedService'
                                  ).getValue();

                if(title === "") title = url;

                var markBegin   = "<!-- EMBED PLACEHOLDER: " + url + " -->",
                    markEnd     = "<!-- END PLACEHOLDER -->";

                var tagProps = {
                  'href'            : url,
                  'class'           : "embed-placeholder",
                  'title'           : title,
                  'text'            : title,
                  'data-placement'  : placement
                }

                if(maxheight !== "") tagProps['data-maxheight'] = maxheight;
                if(service !== "") tagProps['data-service'] = service;

                var tag  = $("<a />", tagProps);
                html = [markBegin, tag[0].outerHTML, markEnd].join("")
              }

              p.setHtml(html)
              instance.insertElement(p)
            } // onOk
          }; // return
        }); // dialog.add


        editor.addCommand(command,
          new CKEDITOR.dialogCommand(dialogName, {
            allowedContent: 'a[*](*)'
          })
        )

        editor.ui.addButton(button, {
          label     : 'Embed Placeholder',
          command   : command
        })
      } // init
    }) // plugins.add
})() // closure
