module.exports = function(callback){
  // INITIALIZE
  var coffee, fs;
  var jsdom = require('jsdom')

  var domCallback = function(err, window) {
    var $, _, body, embeditor, XMLHttpRequest, najax, cp;
    fs = require('fs');
    CoffeeScript = require('coffee-script');
    cp  = require('child_process');
    $   = require("jquery")(window);
    _   = require('underscore')._;
    najax = require('najax');
    eco = require('eco');
    // $.ajax = require('najax')
    global.window = window
    global.jQuery = $
    global.$ = $
    window = global;

    // Figure out where our working path is.
    var embeditorRoot = cp.execSync("bundle show embeditor-rails", {encoding: "utf-8"}).replace("\n", "") + "/app/assets/javascripts/embeditor"

    JST = {};
    // Include our base code.
    eval(CoffeeScript.compile(fs.readFileSync(embeditorRoot + "/embeditor.js.coffee", "utf8")));
    eval(CoffeeScript.compile(fs.readFileSync(embeditorRoot + "/utility.js.coffee", "utf8")));
    eval(CoffeeScript.compile(fs.readFileSync(embeditorRoot + "/adapter.js.coffee", "utf8")));

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
    eval(CoffeeScript.compile(fs.readFileSync(embeditorRoot + "/adapters/oembed.js.coffee", "utf8")));
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

    eval(CoffeeScript.compile(fs.readFileSync(embeditorRoot + "/adapters/static_template.js.coffee", "utf8")));
    // Include all our other adapters.
    fs.readdirSync(embeditorRoot + '/adapters').forEach(function(filename){
      eval(CoffeeScript.compile(fs.readFileSync(embeditorRoot + "/adapters/" + filename, "utf8")));
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
};