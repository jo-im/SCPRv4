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

          var myWidth   = $(this).attr("data-width");
          var myHeight  = $(this).attr("data-height");
          var myRatio   = myWidth / myHeight;

          if(myRatio > 1.5) {
            $(this).closest("article").addClass("ratio-squat");
          } else if(myRatio < 1.0) {
            $(this).closest("article").addClass("ratio-tall");
          }

        });
      };





      // SINGLE EPISODE: FPO Archive-Browser behavior.
      // ---------------------------------------------------------
      if ($(".archive-browser").length) {
      // ---------------------------------------------------------
      // 1.) Standard-Picker triggers results.
      //     (And, while we're at it: update Liminal-Picker, too.)
      // ---------------------------------------------------------
        $(".standard-picker select").change(function(){

          var myIndex       = $(this).find(":selected").index();
          var myDropdown    = $(this).closest(".field").index();
          var myMonth       = $(".standard-picker .months select").find(":selected").text();
          var myYear        = $(".standard-picker .years select").find(":selected").text();
          var sampleResult  = "<li><a href=\"#\"><time datetime=\"2000-01-01\">99</time> <span>Here's a bunch of results from " + myMonth + " of " + myYear + ".</span></a></li>";

          $(this).find("option").removeAttr("selected");
          $(this).find("option:eq(" + myIndex + ")").attr("selected","selected");

          $(".liminal-picker div:eq(" + myDropdown + ") li").removeAttr("class");
          $(".liminal-picker div:eq(" + myDropdown + ") li:eq(" + myIndex + ")").addClass("selected");

          $(".archive-browser .results ul li").remove();
          var sampleEpisode = new scpr.Episode({headline: "TURN DOWN FOR WHAT!??!?"})
          var episodeGroup = new scpr.EpisodesCollection([sampleEpisode])
          var episodesView = new scpr.EpisodesView({collection: episodeGroup})
          $(".results").html(episodesView.render().el)
          // $(".archive-browser .results ul").append(sampleResult,sampleResult,sampleResult,sampleResult,sampleResult,sampleResult,sampleResult,sampleResult);

        });
      // ---------------------------------------------------------
      // 2.) Liminal-Picker sends information to Standard-Picker.
      // ---------------------------------------------------------
        $(".liminal-picker li").click(function(){

          var myDropdown  = $(this).closest("div").index();
          var myChoice    = $(this).index();

          $(this).siblings().attr("class","");
          $(this).addClass("selected");

          $(".standard-picker .field:eq(" + myDropdown + ") select option").removeAttr("selected");
          $(".standard-picker .field:eq(" + myDropdown + ") select option:eq(" + myChoice + ")").attr("selected", "selected").trigger("change");

        });
      // ---------------------------------------------------------
      // 3.) Handheld users can opt to view all results.
      // ---------------------------------------------------------
        $(".show-full-results").click(function(){
          $(".results").toggleClass("show-everything");
          $(".show-full-results").hide();
        });
      // ---------------------------------------------------------
      };//.archive-browser existence check


 






    } // loadBehaviors

} // Editions