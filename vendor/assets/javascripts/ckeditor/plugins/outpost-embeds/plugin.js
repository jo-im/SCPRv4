/*
* Embed dialogue for Outpost.
*
* Plugin name:      outpost-embeds
* Menu button name: OutpostEmbeds
*
* @author Bryan Ricker / SCPR
* @version 0.1
*/
(function() {
    CKEDITOR.plugins.add('outpost-embeds', {
      hidpi: true,
      icons: "outpostembeds",

      findEmbeds: function() {
        var embeds =[];

        $('#embeds-fields tr').each(function() {
          var title = $(this).find('input[type=text]').val(),
              url   = $(this).find('input[type=url]').val();

          if(url != "") {
            embeds.push({
              title : title,
              url   : url
            })
          }
        });

        return embeds;
      },

      init: function(editor) {
        var plugin = this;

        CKEDITOR.dialog.add('OutpostEmbedsDialog', function (instance) {
          return {
            title : 'Embeds',
            minWidth : 550,
            minHeight : 200,

            contents: [{
              id: "main",
              elements: [] // ckeditor complains if this is missing.
            }], // contents

            onLoad: function() {
              var dialogEl = $(this.parts.contents.$)

              this.noEmbedNotification = $('<strong />', {
                text    : "There are no embeds yet. Add them in the Embeds section.",
                class   : "embed-notification"
              })

              this.embedSelectHeader = $('<strong />', {
                text : "Select an Embed to insert into the post body:"
              })

              this.inputsWrapper = $('<ul />', {
                class: 'cke_dialog_ui_radio'
              })

              dialogEl.append(this.noEmbedNotification)
              dialogEl.append(this.embedSelectHeader)
              dialogEl.append(this.inputsWrapper)
            },

            onShow: function() {
              var embeds = plugin.findEmbeds();

              // Clear out existing radio buttons.
              this.inputsWrapper.empty()

              // Handle the "No Embeds" notification
              if(embeds.length) {
                this.noEmbedNotification.hide()
                this.embedSelectHeader.show()
              } else {
                // If there are no embeds, show the notification
                // and return - no need to continue.
                this.noEmbedNotification.show()
                this.embedSelectHeader.hide()
                return
              }

              // Loop through existing embeds and append them to the
              // list in the dialog.
              for(var i=0; i < embeds.length; i++) {
                var embed       = embeds[i],
                    title       = embed.title,
                    url         = embed.url,
                    elId        = "cke_embed_"+i+"_uiElement",
                    labelId     = "cke_embed_"+i+"_radio_input_label",
                    li          = $("<li />");

                var input = $('<input />', {
                  'type'    : 'radio',
                  'class'   : 'embed-selection cke_dialog_ui_radio_input',
                  'name'    : 'embed-selection_radio',
                  'id'      : elId,
                  'value'   : "<a href=\'"+url+"\' " +
                              "class=\'embed-placeholder\'>"+title+"</a>"
                })

                var label = $('<label />', {
                  'id'      : labelId,
                  'for'     : elId,
                  'class'   : 'embed-selection',
                  'text'    : title
                })

                li.html(input)
                li.append(label)

                this.inputsWrapper.append(li)
              }
            },

            onOk: function() {
              if($("input.embed-selection").length) {
                var p = instance.document.createElement('p');
                p.setHtml($('input.embed-selection:checked').val());
                instance.insertElement(p);
              }
            }
          }; // return
        });


        editor.addCommand('OutpostEmbeds',
          new CKEDITOR.dialogCommand('OutpostEmbedsDialog', {
            allowedContent: 'a[*](*)'
          })
        );

        editor.ui.addButton('OutpostEmbeds', {
          label     : 'Outpost Embeds',
          command   : 'OutpostEmbeds',
          toolbar   : 'outpost-embeds'
        });
      } // init
    }); // add
})(); // closure
