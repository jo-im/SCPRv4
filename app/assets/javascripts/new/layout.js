scpr.Behaviors.Layout = {

    loadBehaviors: function() {

        //  ================================================
        //  Instatiate FastClick
        //  ------------------------------------------------
        $(function() {
            FastClick.attach(document.body);
        });



        //  ================================================
        //  Show/hide the Ledge
        //  ------------------------------------------------
            $(".shownav, .kpcc-ledge .close").click(function(){
                $(".kpcc-ledge").toggleClass("active");
            });



        //  ================================================
        //  Show/hide the Search
        //  ------------------------------------------------
            $(".search-trigger").click(function(){
                $(".kpcc-search").addClass("active");
                $("#q").focus();
            });
        //  ................................................
            $(".kpcc-search .close").click(function(){
                $(".kpcc-search").removeClass("active");
            });




    } // loadBehaviors

} // Layout
