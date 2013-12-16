scpr.Behaviors.Verticals = {

    loadBehaviors: function() {

        //  ================================================
        //  Let's wrap text on hyphens
        //  ------------------------------------------------

        var re = /(.+?)-(.+?)/gi
        var reporters = $(".reporters figure h1 a")

        reporters.each(function() {
            var el = $(this)
            var text = el.html()
            var fixedText = $("<div />").html(
                text.replace(re, "$1-&#8203;$2")).text()

            el.html(fixedText)
        })


        //  ================================================
        //  Landing: Check up on the curated title length
        //  ------------------------------------------------
        if($("body").hasClass("landing")){
            var charcount = $(".headline h1 a").html().length;

            if((charcount < 58) && (charcount > 50)) {
                $(".headline").addClass("concise");
            }

            if((charcount < 51)) {
                $(".headline").addClass("tiny");
            }
        }

    } // loadBehaviors

} // Verticals
