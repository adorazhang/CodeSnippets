document.write("<ul>")

chrome.history.search( {'text':''},
	function(historyItems) {
		var items = new Array();
		
		for (var i = 0; i < historyItems.length; ++i) {
		var item = new Object();
		item.url = historyItems[i].url;
		item.count = historyItems[i].visitCount;
		items.push(item);
		}
		
		items.sort( function(a,b) {return b.count - a.count} );
		
		for (var i = 0; i < items.length; ++i) {
			document.write("<li>"+items[i].count+": "+items[i].url+"</li>");
		}
	}
);

document.write("</ul>")