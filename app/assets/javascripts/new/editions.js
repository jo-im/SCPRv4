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
      $(".edition-marquee time mark,.recents button,.recents-toggle time").click(function(){
        $(".edition-marquee").toggleClass("exposed");
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
      




    } // loadBehaviors

} // Editions