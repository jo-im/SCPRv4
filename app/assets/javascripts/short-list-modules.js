$(document).ready(function() {


    // Homepage Short List tease module
    if ($(".shortlist-preview").length) {
      $(".shortlist-preview .titling button").click(function(){
        $(".shortlist-preview .enlistment").toggle();
        $(".shortlist-preview .brochure").toggle();
        $(".shortlist-preview input[type=text]").focus();
      });
    }


});