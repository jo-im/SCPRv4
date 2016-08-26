// This provides test modes for the Embeditor script.
// That way, we can test the behavior of the Embeditor::Processor
// Ruby library to make sure that it can handle failures
// from the Node.js process.

module.exports = function(){

  process.stdin.setEncoding('utf8')
  var args = process.argv
  args.shift(); args.shift(); 

  var _ = require('underscore')._;

  if(_.contains(args, '--test')){
    // Just pass back the input without doing anything with it.
    process.stdin.on('data', function(html){
      process.stdin.pause()
      process.stdout.write(html + "\x04")
      process.stderr.write("\x04")
      process.stdin.resume()
    })
    return true;
  } else if(_.contains(args, '--test-error')) {
    process.stdin.on('data', function(html){
      // Pretend like we are sending an error.
      // An example of when this would happen IRL would
      // be if we received an error from an API during
      // an ajax call.
      process.stdin.pause()
      process.stdout.write("\x04")
      process.stderr.write('[embeditor error] a problem occurred.' + "\x04")
      process.stdin.resume()
    })
    return true;
  } else if(_.contains(args, '--test-hang')) {
    process.stdin.on('data', function(html){
      while(true){
        // do nothing indefinitely
        // yes, we want to do this
      }
    })
    return true;
  } else {
    return false;
  }

}
