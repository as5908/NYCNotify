function altRows(id){
	if(document.getElementsByTagName){  
		
		var table = document.getElementById(id);  
		var rows = table.getElementsByTagName("tr"); 
		 
		for(i = 0; i < rows.length; i++){          
			if(i % 2 == 0){
				rows[i].className = "evenrowcolor";
			}else{
				rows[i].className = "oddrowcolor";
			}      
		}
	}
}

window.onload=function(){
	altRows('alternatecolor');
}
$(function() {
  $("#metrics th a, #metrics .pagination a").live("click", function() {
    $.getScript(this.href);
    return false;
  });
  $("#metrics_search input").keyup(function() {
    $.get($("#metrics_search").attr("action"), $("#metrics_search").serialize(), null, "script");
    return false;
  });
});
