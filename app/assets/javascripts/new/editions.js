scpr.Behaviors.Editions = {

    loadBehaviors: function() {
      

      $(".contents ol li").each(function(){
        var myIndex = $(this).index() + 1;
        $(this).find("a").prepend("<mark>" + myIndex + "</mark> ");
      });
      


    } // loadBehaviors

} // Editions