
$(document).ready( function(){ 


});

//Pulldown
$(".dropdown").hover(function() {
	$(this).children('ul').show();
},function() {
	$(this).children('ul').hide();
});