jQuery(document).ready(function($) {


//  ================================================
//  Do we support -webkit-filter?
//  ------------------------------------------------
//  Credit & thanks & source: http://stackoverflow.com/questions/18986156/detect-support-for-webkit-filter-with-javascript?lq=1
//  ------------------------------------------------
//  Which model of "brightness" is being used?
//  ------------------------------------------------
//  Credit & thanks & source: http://stackoverflow.com/questions/16303344/brightness-filter-css-safari-vs-chrome
//  ------------------------------------------------

    var e = document.querySelector("img");
    e.style.webkitFilter = "grayscale(1)";
    if(window.getComputedStyle(e).webkitFilter == "grayscale(1)"){

        $("body").addClass("supports-filters");

        var oldBrightnessModel = $("<div/>").css("-webkit-filter","brightness(101%)").css("-webkit-filter")==""?true:false;

        if(oldBrightnessModel == true) {
            $(".prologue .ephemera").addClass("model-old");
        } else {
            $(".prologue .ephemera").addClass("model-new");
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
        var middleEl    = $($(".prose > p")[middleInt - 1]) // thanks, bryan!
        $(".prose .related").insertBefore(middleEl);
    }


//  ================================================
//  Single: Figure out the orientation of any images
//  ------------------------------------------------
    if ($(".report .prose img").length) {
        $(window).load(function() { // because WebKit browsers need this in order to *definitely* load/assess the images
            $(".report .prose img").each(function(){
                var myWidth     = $(this).width();
                var myHeight    = $(this).height();
                var myRatio     = myWidth / myHeight;
                if(myRatio > 1.2)                           { myRatio = "wide"; }
                if((myRatio <= 1.2) && (myRatio >= 0.9))    { myRatio = "squarish"; }
                if(myRatio < 0.9)                           { myRatio = "skinny"; }
                $(this).addClass(myRatio);
            });
        });
    }





//  ================================================
//  Instatiate FastClick
//  ------------------------------------------------
    $(function() {
        FastClick.attach(document.body);
    });



//  ================================================
//  Landing: Check up on the curated title length
//  ------------------------------------------------
    if($("body").hasClass("landing")){
        var charcount = $(".headline h1 span").html().length;

        if((charcount < 58) && (charcount > 50))        { $(".headline").addClass("concise"); }
        if((charcount < 51))                            { $(".headline").addClass("tiny"); }
    }



//  ================================================
//  Show/hide the Ledge
//  ------------------------------------------------
    $(".shownav").click(function(){
        $(".kpcc-ledge").animate({
            top: 0
        }, 300, function() {
            // Dropdown complete.
        });
    });
//  ................................................
    $(".kpcc-ledge .close").click(function(){
        $(".kpcc-ledge").animate({
            top: "-280px"
        }, 300, function() {
            // Retraction complete.
        });
    });


//  ================================================
//  Show/hide the Search
//  ------------------------------------------------
    $(".search-trigger").click(function(){
        $(".kpcc-search").animate({
            top: 0
        }, 200, function() {
            // Dropdown complete.
            $("#q").focus();
        });
    });
//  ................................................
    $(".kpcc-search .close").click(function(){
        $(".kpcc-search").animate({
            top: "-130px"
        }, 200, function() {
            // Retraction complete.
        });
    });





}); // end doc ready
