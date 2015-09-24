CKEDITOR.config.autoParagraph = false;

CKEDITOR.disableAutoInline = true;

CKEDITOR.plugins.add('inline-asset-placeholder', {
  init: function(editor) {
    CKEDITOR.dialog.add('inlineAssetOptions', function(editor) {
      return {
        title: 'Inline Asset Options',
        minWidth: 200,
        minHeight: 100,
        contents: [
          {
            id: 'info',
            elements: [
              {
                id: 'align',
                type: 'select',
                label: 'Align',
                setup: function(widget) {
                  return this.setValue(widget.data.align);
                },
                commit: function(widget) {},
                items: [[editor.lang.common.alignLeft, 'left'], [editor.lang.common.alignRight, 'right']]
              }
            ]
          }
        ]
      };
    });

    editor.addCommand("dockAssetManager", {
      exec: {
        call: function() {
          var child;
          child = $("#form-block-asset-management.dockable").not('.docked');
          return child.find("legend a.dock-control").trigger("click");
        }
      }
    });

    editor.ui.addButton('DockAssetManager', {
      label: "Dock Asset Manager",
      command: 'dockAssetManager',
      toolbar: 'insert'
    });

    editor.widgets.add('inline_asset_placeholder', {
      dialog: "inlineAssetOptions",
      downcast: function() {
        return new CKEDITOR.htmlParser.element('img', {
          src: "#",
          "class": "inline-asset",
          "data-asset-id": this.data['asset-id'],
          "data-align": this.data['align']
        });
      },
      init: function() {
        this.setData('asset-id', this.element.$.dataset.assetId);
        return this.setData('align', this.element.$.dataset.align);
      },
      render: function() {
        var align, asset, assetId, caption, html, small, thumbnail;
        if (window.assetManager) {
          assetId = parseInt(this.element.$.getAttribute('data-asset-id'));
          align = this.element.$.getAttribute('data-align');
          asset = window.assetManager.assets.where({
            id: assetId
          })[0].attributes;
          thumbnail = new CKEDITOR.htmlParser.element('img', {
            src: asset.urls.thumb,
            width: "120",
            height: "120",
            style: "float: left;"
          });
          caption = new CKEDITOR.htmlParser.element('div', {
            "class": "asset-info",
            style: "width: 200px; float: left;"
          });
          small = new CKEDITOR.htmlParser.element('small', {
            "class": "muted"
          });
          if (asset.caption) {
            small.setHtml(asset.caption);
          }
          caption.add(small, 0);
          html = thumbnail.getOuterHtml() + caption.getOuterHtml();
          return this.element.setHtml(html);
        }
      },
      data: function() {
        this.render();
        if (window.assetManager) {
          return window.assetManager.assets.on("reset", (function(_this) {
            return function() {
              return _this.render();
            };
          })(this));
        }
      }
    });

    editor.dataProcessor.dataFilter.addRules({
      elements: {
        img: function(element) {
          var outerElement, widgetWrapper;
          if (element.attributes["data-asset-id"] && element.attributes["class"] === "inline-asset") {
            outerElement = new CKEDITOR.htmlParser.element('div', {
              'class': 'cke_inline_asset_placeholder',
              'data-asset-id': element.attributes["data-asset-id"],
              'data-align': element.attributes["data-align"],
              'min-height': '120px',
              'style': 'float: left; display: inline-block; width: 100%;'
            });
            outerElement.add(new CKEDITOR.htmlParser.text());
            widgetWrapper = editor.widgets.wrapElement(outerElement, 'inline_asset_placeholder');
            return element.replaceWith(widgetWrapper);
          }
        }
      }
    });
  }
});