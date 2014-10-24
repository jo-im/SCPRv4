$(document).ready(function() {


    // Homepage Short List tease module
    if ($(".shortlist-preview").length) {
      $(".shortlist-preview .titling button").click(function(){
        $(".shortlist-preview .titling button").toggleClass("active");
        ($(".shortlist-preview .titling button span").text() === "Subscribe") ? $(".shortlist-preview .titling button span").text("Close") : $(".shortlist-preview .titling button span").text("Subscribe");
        $(".shortlist-preview .enlistment").toggle();
        $(".shortlist-preview .brochure").toggle();
        $(".shortlist-preview input[type=text]").focus();
      });
    }


});