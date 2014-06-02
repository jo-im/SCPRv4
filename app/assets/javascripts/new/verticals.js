scpr.Behaviors.Verticals = {

    loadBehaviors: function() {



        //  ================================================
        //  Landing: Your vertical's category name might be too long
        //  ------------------------------------------------
            if ($("body").hasClass("landing")) {
                var vertLength = $(".titling h1 a").text().length;
                if(vertLength > 25) {
                    $(".titling").addClass("verbose");
                }
            }


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
                var charcount = $(".headline h1 a").text().length;
                if(charcount > 67)                          { $(".headline").addClass("verbose"); }
                if((charcount < 58) && (charcount > 50))    { $(".headline").addClass("concise"); }
                if(charcount < 51)                          { $(".headline").addClass("tiny"); }
            }



    } // loadBehaviors

} // Verticals
