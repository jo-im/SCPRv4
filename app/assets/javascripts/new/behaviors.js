// Behaviors is a queueing system to help load procedural DOM behaviors
// without having to worry (too much) about scoping and other collisions.
//
// Each of your Behaviors should define a `loadBehaviors` function, which
// contains the script that you want to run. Somewhere in your page, call
// `scpr.Behaviors.loadBehaviors()`, passing an array of behaviors you
// want to load (as strings).
//
// Note that because these behaviors are meant to be regarding DOM
// manipulation, they will get loaded automatically inside of a
// $(document).ready() callback, so there's no need to wrap your
// behaviors in it yourself.
//
// Example usage:
//   <script>
//     scpr.Behaviors.loadBehaviors(['Verticals', 'Single'])
//   </script>

scpr.Behaviors = {
    loadBehaviors: function(behaviors) {
        $(document).ready(function() {
            for (var i=0; i<behaviors.length; i++) {
                var name        = behaviors[i];
                var behavior    = scpr.Behaviors[name];

                if (behavior) {
                    behavior.loadBehaviors()
                } else {
                    console.warn("[behaviors] Tried to load a " +
                        "behavior which doesn't exist ("+name+")")
                }
            }
        })
    }
}
