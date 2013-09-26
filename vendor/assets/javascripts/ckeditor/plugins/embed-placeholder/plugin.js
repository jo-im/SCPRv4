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
        icon            = 'embedplaceholder';


    CKEDITOR.plugins.add(pluginName, {
      hidpi: true,
      icons: icon,

      init: function(editor) {
        var plugin = this;

        CKEDITOR.dialog.add(dialogName, function (instance) {
          return {
            title       : 'Embed Placeholder',
            minWidth    : 550,
            minHeight   : 200,

            contents : [
              {
                id : 'embed',
                elements : [
                  {
                    id : "alpha-warning",
                    type : 'html',
                    html : '<span style="color:#ff0000">Warning: ' +
                           'This feature is still a WIP, and you may see ' +
                           'some rendering errors. Please report any problems.</span>'
                  },
                  {
                    id          : 'embedUrl',
                    type        : 'text',
                    label       : 'oEmbed URL',
                    autofocus   : 'autofocus',

                    validate : function() {
                      if(!this.getValue()) {
                        alert("URL can't be empty.")
                        return false
                      }
                    }
                  },
                  {
                    id : 'embedService',
                    type : 'select',
                    label : "Service",
                    items : [
                      ['Select a Servce:', ''],
                      ['YouTube', 'youtube'],
                      ['Vimeo', 'vimeo'],
                      ['Brightcove', 'brightcove'],
                      ['Ustream', 'ustream'],
                      ['Google Maps', 'googlemaps'],
                      ['Scribd', 'scribd'],
                      ['DocumentCloud', 'documentcloud'],
                      ['Polldaddy', 'polldaddy'],
                      ['Facebook', 'facebook'],
                      ['Storify', 'storify'],
                      ['Cover It Live', 'coveritlive'],
                      ['RebelMouse', 'rebelmouse'],
                      ['Fire Tracker', 'firetracker'],
                      ['Twitter', 'twitter'],
                      ['Vine', 'vine'],
                      ['Instagram', 'instagram'],
                      ['SoundCloud', 'soundcloud'],
                      ['Spotify', 'spotify'],
                      ['Other', 'other']
                    ]
                  },
                  {
                    id          : 'linkTitle',
                    type        : 'text',
                    label       : 'Link Title'
                  },
                  {
                    id          : 'embedMaxHeight',
                    type        : 'text',
                    label       : 'Embed Maximum Height',
                    width       : '45px',
                    onLoad: function() {
                      $('input', '#'+this.domId).after(' <strong>px</strong>')
                    }
                  }
                ]
              }
            ],

            onOk: function() {
              var url         = this.getContentElement('embed', 'embedUrl').getValue(),
                  title       = this.getContentElement('embed', 'linkTitle').getValue(),
                  maxheight   = this.getContentElement('embed', 'embedMaxHeight').getValue(),
                  service     = this.getContentElement('embed', 'embedService').getValue();

              if(title === "") title = url;

              var p           = editor.document.createElement('p'),
                  n           = "\n",
                  markBegin   = "<!-- EMBED PLACEHOLDER: " + url + " -->",
                  markEnd     = "<!-- END PLACEHOLDER -->";

              var tagProps = {
                'href'            : url,
                'class'           : "embed-placeholder",
                'title'           : title,
                'text'            : title
              }

              if(maxheight !== "") tagProps['data-maxheight'] = maxheight;
              if(service !== "") tagProps['data-service'] = service;

              var tag = $("<a />", tagProps);

              var html = [markBegin,tag[0].outerHTML,markEnd].join("");
              p.setHtml(html)
              instance.insertElement(p)
            }
          }; // return
        });


        editor.addCommand(command,
          new CKEDITOR.dialogCommand(dialogName, {
            allowedContent: 'a[*](*)'
          })
        );

        editor.ui.addButton(button, {
          label     : 'Embed Placeholder',
          command   : command
        });
      } // init
    }); // add
})(); // closure
