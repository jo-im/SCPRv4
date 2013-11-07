jQuery(document).ready(function($) {


//	================================================
//	Instatiate FastClick
//	------------------------------------------------
	$(function() {
		FastClick.attach(document.body);
	});



//	================================================
//	Landing: Check up on the curated title length
//	------------------------------------------------
	if($("body").hasClass("landing")){
		var charcount = $(".headline h1 span").html().length;

		if((charcount < 58) && (charcount > 50))		{ $(".headline").addClass("concise"); }
		if((charcount < 51))							{ $(".headline").addClass("tiny"); }
	}



//	================================================
//	Show/hide the Ledge
//	------------------------------------------------
	$(".shownav").click(function(){
		$(".kpcc-ledge").animate({
			top: 0
		}, 300, function() {
			// Dropdown complete.
		});
	});
//	................................................
	$(".kpcc-ledge .close").click(function(){
		$(".kpcc-ledge").animate({
			top: "-280px"
		}, 300, function() {
			// Retraction complete.
		});
	});


//	================================================
//	Show/hide the Search
//	------------------------------------------------
	$(".search-trigger").click(function(){
		$(".kpcc-search").animate({
			top: 0
		}, 200, function() {
			// Dropdown complete.
		    $("#q").focus();
		});
	});
//	................................................
	$(".kpcc-search .close").click(function(){
		$(".kpcc-search").animate({
			top: "-130px"
		}, 200, function() {
			// Retraction complete.
		});
	});





}); // end doc ready