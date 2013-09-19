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
              elements: [
                {
                  id          : 'embed-notification',
                  className   : "embed-notification",
                  type        : 'html',
                  html        : "<strong>There are no embeds yet! Add them below.</strong>"
                },
                {
                  id    : 'embed-selection',
                  className : 'embed-selection',
                  type  : 'radio',
                  label : "Select Embed",
                  items: [""] // This has to be here or CKEditor complains
                } // element
              ] // elements
            }], // contents

            onShow: function() {
              var notificationClass = $('.embed-notification'),
                  radioClass        = $('.embed-selection'),
                  radioWrapper      = $('.cke_dialog_ui_radio'),
                  embeds            = plugin.findEmbeds();

              // Clear out existing selection options
              radioWrapper.empty()

              // Handle the "No Embeds" notification
              if(embeds.length) {
                notificationClass.hide()
              } else {
                // If there are no embeds, show the notification
                // and return - no need to continue.
                notificationClass.show()
                return
              }

              // Loop through existing embeds and append them to the
              // list in the dialog.
              for(var i=0; i < embeds.length; i++) {
                var embed = embeds[i],
                    title = embed.title,
                    url   = embed.url


                var newRadio = '<input type="radio" class="embed-selection cke_dialog_ui_radio_input" ' +
                'name="embed-selection_radio" value="&lt;a href=\''+url+'\' class=\'embed-placeholder\'&gt;'+title+'&lt;/a&gt;" ' +
                'aria-labelledby="cke_52_radio_input_label" id="cke_53_uiElement">'

                newRadio += '<label id="cke_52_radio_input_label" for="cke_53_uiElement" class="embed-selection">'+title+'</label>'
                radioWrapper.append(newRadio)
              }
            },

            onOk: function() {
              if($("input.embed-selection").length) {
                var p = instance.document.createElement('p');
                console.log($('input.embed-selection:checked').val())
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
