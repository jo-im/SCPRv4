module.exports = function(callback){
  
  var cp  = require('child_process');
  var self = this;

  // There's no reason this has to be asynchronous other than that
  // the version of Node.js on our servers does not support the 
  // execSync function.
  cp.exec("bundle show embeditor-rails", {encoding: "utf-8"}, function(error, stdout, stderr){
    var embeditorRoot = stdout.toString().replace("\n", "") + "/app/assets/javascripts/embeditor"
    var jsdom         = require('jsdom');
    var domCallback = function(err, window) {
      // INITIALIZE
      var fs, CoffeeScript, $, _, body, embeditor, najax, eco;
      fs           = require('fs');
      CoffeeScript = require('coffee-script');
      $            = require("jquery")(window);
      _            = require('underscore')._;
      najax        = require('najax');
      eco          = require('eco');
      global.window = window
      global.jQuery = $
      global.$ = $
      window = global;

      JST = {};

      var include = function(){
        var len  = Object.keys(arguments).length
        var code = '';
        var i = 0;
        while(i < len){
          var file = arguments[i]
          code += (fs.readFileSync(embeditorRoot + "/" + file + '.js.coffee', "utf8") + "\n")
          i++
        }
        (function(){
          eval(CoffeeScript.compile(code))
        }).call(self)
      }

      // Include our base code.
      include('embeditor', 'utility', 'adapter')

      // Template renderer shim.
      fs.readdirSync(embeditorRoot + '/templates').forEach(function(filename){
        var templateName = filename.replace(".jst.eco", "");
        JST[Embeditor.TemplatePath + templateName] = function(options){
          var template = fs.readFileSync(embeditorRoot + '/templates/' + filename, "utf-8");
          return eco.render(template, options);
        }
      });

      // We do this in order to know when all embeds have been completed
      // by forcing inserts to happen in succession, as opposed to async.
      Embeditor.Adapter.fn = Embeditor.Adapter.fn || {};
      Embeditor.Adapter.fn.embed = Embeditor.Adapter.prototype.embed
      // Essentially, what we are doing is overriding embed() to call
      // onembed() at the end of every call in order to perform embed()
      // on the next placeholder.
      Embeditor.Adapter.prototype.embed = function(){
        Embeditor.Adapter.fn.embed.apply(this, arguments);
        if(typeof this.onembed === "function"){
          this.onembed();
        }
      }
      // Include our "base" adapters.
      include('adapters/oembed', 'adapters/static_template')

      // We have to rewrite this method using "najax", as jQuery's ajax
      // function doesn't work in Node.  Also, simply replacing the prototype
      // function on jQuery with the najax function causes other problems.
      Embeditor.Adapters.Oembed.prototype.swap = function(){
        najax({
          url: this.adapter.Endpoint,
          type: 'GET',
          dataType: 'json',
          data: _.extend(this.queryParams, {
            url: this.href
          }),
          success: (function(_this) {
            return function(data, textStatus, jqXHR) {
              return _this.embedData(data);
            };
          })(this),
          error: (function(_this) {
            return function(jqXHR, textStatus, errorThrown) {
              // The error callback has also been changed t write to stderr
              // instead of using console.log, which writes to stdout, which
              // can cause problems.
              return process.stderr.write(JSON.stringify(['[embeditor oembed] error.', jqXHR]) + "\x04");
            };
          })(this)
        });
      }

      // Include all our other adapters.
      fs.readdirSync(embeditorRoot + '/adapters').forEach(function(filename){
        include('adapters/' + filename.replace(".js.coffee", ""))
      })

      // Run a function within our environment.
      callback(Embeditor, $, _, window)
    }
    jsdom.env({
      html: "", 
      features: {
        SkipExternalResources: true,
        FetchExternalResources: false,
        ProcessExternalResources: false
      }, 
      done: domCallback
    })
  })
};