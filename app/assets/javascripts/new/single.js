scpr.Behaviors.Single = {

    loadBehaviors: function() {

        //  ================================================
        //  Do we support -webkit-filter?
        //  ------------------------------------------------
        //  Credit & thanks & source:
        //  http://stackoverflow.com/questions/18986156
        //  ------------------------------------------------
        //  Which model of "brightness" is being used?
        //  ------------------------------------------------
        //  Credit & thanks & source:
        //  http://stackoverflow.com/questions/16303344
        //  ------------------------------------------------

        if ($(".prologue .ephemera").length) {

            var e = $(".prologue .ephemera img")[0];
            e.style.webkitFilter = "grayscale(1)";
            if(window.getComputedStyle(e).webkitFilter == "grayscale(1)"){

                // Okay, we're off to the races.
                $("body").addClass("supports-filters");

                // But first, clean up our little test station.
                e.style.webkitFilter = "";


                var oldBrightnessModel =
                    $("<div/>").css("-webkit-filter","brightness(101%)"
                        ).css("-webkit-filter") == ""

                if(oldBrightnessModel == true) {
                    $(".prologue .ephemera").addClass("model-old");
                } else {
                    $(".prologue .ephemera").addClass("model-new");
                }

            }

        }

        //  ================================================
        //  Single: An article's first paragraph should be magical
        //  ------------------------------------------------

        if ($(".report .prose p").length) {
            $(".report .prose p:first").addClass("inaugural");
        }


        //  ================================================
        //  Single: Let's reposition our "Related" box
        //  ------------------------------------------------
        if ($(".report .prose .related").length) {
            var qtyGrafs    = $(".report .prose > p").length;
            var middleInt   = Math.ceil(qtyGrafs / 2);
            var middleEl    = $($(".prose > p")[middleInt - 1])
            $(".prose .related").insertBefore(middleEl);
        }


        //  ================================================
        //  Single: Figure out the orientation of any images
        //  ------------------------------------------------
        if ($(".report .prose img").length) {
            // WebKit browsers need window.load in order to *definitely*
            // load/assess the images
            $(window).load(function() {
                $(".report .prose img").each(function(){
                    var myWidth     = $(this).width();
                    var myHeight    = $(this).height();
                    var myRatio     = myWidth / myHeight;

                    if(myRatio > 1.2) {
                        myRatio = "wide";
                    }

                    if((myRatio <= 1.2) && (myRatio >= 0.9)) {
                        myRatio = "squarish";
                    }

                    if(myRatio < 0.9) {
                        myRatio = "skinny";
                    }

                    $(this).addClass(myRatio);
                });
            });
        }


        //  ================================================
        //  Single: Audio-trigger stuff
        //  ------------------------------------------------
        if ($("body").hasClass("single") && $(".audio-trigger").length) {

            // Okay, the page just loaded. Right now, should it live?
            if ($(".report .supportive").css("float") == "none" ){
                $("aside.audio").prependTo(".cubbyhole");
            }

            // Move it around based on screen width
            $(window).resize(function(){
                if ($(".report .supportive").css("float") == "none" ){
                    $("aside.audio").prependTo(".cubbyhole");
                } else {
                    $("aside.audio").prependTo(".report .supportive");
                }
            });

            // Make it do something
            $(".audio-trigger button").click(function(){
                alert("Wow, you must really want to listen to audio!");
            });

        }

    } // loadBehaviors

} // Single
