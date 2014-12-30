scpr.Behaviors.Editions = {

    loadBehaviors: function() {
      
      // Give the OL back its numbers.
      // ---------------------------------------------------------
      $(".contents ol li").each(function(){
        var myIndex = $(this).index() + 1;
        $(this).find("a").prepend("<mark>" + myIndex + "</mark> ");
      });
      
      
      // Show/hide the "Recent Editions" flyout.
      // ---------------------------------------------------------
      $(".edition-marquee time mark,.recents button,.recents-toggle").click(function(){
        $(".edition-marquee").toggleClass("exposed");
      });


      // Prevent internal-anchor URL hashes
      // NOTE: I (Jon) have a thought on this, but it might be
      // unfounded. Hit me up if this strikes anyone as a bad idea.
      // ---------------------------------------------------------
      $(".contents a,.subscribe-hint a").click(function(){
        var desired = $(this).attr("href");
        $("html, body").animate({
            scrollTop: $(desired).offset().top
        }, "slow");
        return false;
      });

      // Focus email signup form input when user clicks subscribe anchor
      $(".subscribe-hint a").click(function() {
        $(".subscribe input[type=text]").focus();
      }); 


      // Show/hide the "KPCC Menu" flyout.
      // ---------------------------------------------------------
      $(".shortlist-ledge h1").click(function(){
        $(".shortlist-ledge nav").toggleClass("exposed");
      });


      // Shorten cosmetic names of days-of-the-week. (Debounced.)
      // ---------------------------------------------------------
      function dayShortener() {
          if ($(window).width() < 761 ){
            $(".recents li").each(function(){
              var shortName = $(this).find("time span").attr("data-short");
              $(this).find("time span").html(shortName);
            });
          } else {
            $(".recents li").each(function(){
              var longName = $(this).find("time span").attr("data-long");
              $(this).find("time span").html(longName);
            });
          }
      };
      $(window).resize( $.debounce( 250, dayShortener ) );
      


      // SHORTLIST EDITION: Different aspect-ratios mean different faux-positionings.
      // ---------------------------------------------------------
      if ($(".abstracts > article").length) {
        $(".abstracts > article img").each(function(){

          var myWidth   = $(this).attr("data-width");
          var myHeight  = $(this).attr("data-height");
          var myRatio   = myWidth / myHeight;
          if((myRatio >= 0.85) && (myRatio < 1.1)) {
            $(this).closest("article").addClass("ratio-square");
          } else if(myRatio < 0.85) {
            $(this).closest("article").addClass("ratio-tall");
          } else if(myRatio > 2) {
            $(this).closest("article").addClass("ratio-squat");
          }

        });
      };


      // Conditionally add "hidden" class to the ledge when a URL 
      // hash of #no-prelims is passed to the page.
      // ---------------------------------------------------------
      var url = document.location.hash;

      if (url == "#no-prelims"){
          $(".shortlist-ledge").addClass("hidden");
      }




      // SINGLE EPISODE: Different aspect-ratios mean different faux-positionings.
      // ---------------------------------------------------------
      if ($("body").hasClass("episode")) {
        $(".episode-enumeration > article img").each(function(){
          
//          $(this).css("border","3px solid red");

          var myWidth   = $(this).attr("data-width");
          var myHeight  = $(this).attr("data-height");
          var myRatio   = myWidth / myHeight;

//          alert("my ratio is " + myRatio);

          if(myRatio > 1.5) {
            $(this).closest("article").addClass("ratio-squat");
          } else if(myRatio < 1.0) {
            $(this).closest("article").addClass("ratio-tall");
          }

        });
      };




    } // loadBehaviors

} // Editions