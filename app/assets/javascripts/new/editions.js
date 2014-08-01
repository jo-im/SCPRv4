scpr.Behaviors.Editions = {

    loadBehaviors: function() {
      

      $(".contents ol li").each(function(){
        var myIndex = $(this).index() + 1;
        $(this).find("a").prepend("<mark>" + myIndex + "</mark> ");
      });
      
      
      $(".edition-marquee time mark,.recents button").click(function(){
        $(".edition-marquee").toggleClass("exposed");
      });


    } // loadBehaviors

} // Editions