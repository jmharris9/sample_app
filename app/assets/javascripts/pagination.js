  $("#update_paginate a").live('click', function () {  
    	$.getScript(this.href); 
    return false;  
  });  