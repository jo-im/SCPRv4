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
        (function(scpr){
          var programSlug, currentYear, currentMonth, currentMonthNumber, loadLaminalMonthPicker, getResults, getMonths, 
          setLiminalPicker, setLiminalYearPicker, setLiminalMonthPicker, setStandardMonthPicker, setStandardYearPicker, setStandardSelection 

          programSlug = function(){
            return window.location.pathname.match(/programs\/(.*?)\//)[1]
          }
          currentYear = function(){
            return $(".standard-picker .years select").find(":selected").text().replace(/\s/g, "")
          }
          currentMonth = function(){
            return $(".standard-picker .months select").find(":selected").text().replace(/\s/g, "")
          }
          currentMonthNumber = function(){
            return new Date(currentMonth() + " 01, " + currentYear()).getMonth() + 1
          }
          loadLaminalMonthPicker = function(){
            var element = ($(".standard-picker .months select").find(":selected") || $(".standard-picker .months select")).text()
          }
          getResults = function(){
            if(currentMonthNumber()){
              var results = $(".archive-browser .results")
              var episodeGroup  = new scpr.ArchiveBrowser.EpisodesCollection()
              var episodesView  = new scpr.ArchiveBrowser.EpisodesView({collection: episodeGroup})
              results.addClass("loading")
              episodeGroup.on("reset", function(e){
                results.html(episodesView.render().el)
                results.removeClass("loading")
              })
              episodeGroup.url = "/api/v3/programs/" + programSlug() + "/episodes/archive/" + currentYear() + "/" + currentMonthNumber()
              episodeGroup.fetch()
              if (episodeGroup.length == 0){
                episodeGroup.add(new scpr.ArchiveBrowser.Episode())
              }
            }
          }
          getYears = function(callback){
            var yearsGroup  = new scpr.ArchiveBrowser.YearsCollection()
            var liminalYearsView  = new scpr.ArchiveBrowser.LiminalYearsView({collection: yearsGroup})
            var standardYearsView  = new scpr.ArchiveBrowser.StandardYearsView({collection: yearsGroup})
            yearsGroup.url = "/api/v3/programs/" + programSlug() + "/episodes/archive/years"
            yearsGroup.on("reset", function(e){
              $(".liminal-picker .years").html(liminalYearsView.render().el)
              $(".standard-picker .fields .field.years").html(standardYearsView.render().el)
              setLiminalYearPicker()
              setStandardYearPicker()
              if(callback){callback.call()}
            })
            yearsGroup.fetch()
          }
          getMonths = function(callback){
            var monthsGroup  = new scpr.ArchiveBrowser.MonthsCollection()
            var liminalMonthsView  = new scpr.ArchiveBrowser.LiminalMonthsView({collection: monthsGroup})
            var standardMonthsView  = new scpr.ArchiveBrowser.StandardMonthsView({collection: monthsGroup})
            monthsGroup.url = "/api/v3/programs/" + programSlug() + "/episodes/archive/" + currentYear() + "/months"
            monthsGroup.on("reset", function(e){
              $(".liminal-picker .months").html(liminalMonthsView.render().el)
              $(".standard-picker .fields .field.months").html(standardMonthsView.render().el)
              setLiminalMonthPicker()
              setStandardMonthPicker()
              if(callback){callback.call()}
            })
            monthsGroup.fetch()
          }
          setLiminalPicker = function(cssClass){
            var element = $(cssClass)
            element.removeClass("selected")
            $(element[0]).addClass("selected")

            element.click(function(){
              var myDropdown  = $(this).closest("div").index()
              var myChoice    = $(this).index()
              $(this).siblings().attr("class","")
              $(this).addClass("selected")
              $(".standard-picker .field:eq(" + myDropdown + ") select option").removeAttr("selected")
              $(".standard-picker .field:eq(" + myDropdown + ") select option:eq(" + myChoice + ")").attr("selected", "selected").trigger("change")
            })
          }
          setLiminalYearPicker = function(){
            setLiminalPicker(".liminal-picker div.years li")
          }
          setLiminalMonthPicker = function(){
            setLiminalPicker(".liminal-picker div.months li")
          }
          setStandardYearPicker = function(){
            $(".standard-picker .fields .field.years select").change(function(){
              setStandardSelection(this)
              getMonths(function(){
                getResults()
              })
            })
          }
          setStandardMonthPicker = function(){
            $(".standard-picker .fields .field.months select").change(function(){
              setStandardSelection(this)
              getResults()
            })
          }
          setStandardSelection = function(context){
            var myIndex    = $(context).find(":selected").index()
            var myDropdown = $(context).closest(".field").index()
            $(context).find("option").removeAttr("selected")
            $(context).find("option:eq(" + myIndex + ")").attr("selected","selected")

            $(".liminal-picker div:eq(" + myDropdown + ") li").removeAttr("class")
            $(".liminal-picker div:eq(" + myDropdown + ") li:eq(" + myIndex + ")").addClass("selected")
          }

          $(document).ready(function(){
            getYears(function(){
              getMonths(function(){
                getResults()
              })
            })            
          })

        })(scpr)

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