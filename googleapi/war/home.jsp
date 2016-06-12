<!DOCTYPE html>
<html>
  <head>
    <title>Know your Location</title>
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no">
    <meta charset="utf-8">
<link rel="stylesheet"
	href="https://ssl.gstatic.com/docs/script/css/add-ons1.css"></link>
    <style>
      html, body {
        height: 100%;
        margin: 0;
        padding: 0;
      }

      #map {
        height: 100%;       
      }
      #weather
{
  position:absolute;
  top:100px;  /* adjust value accordingly */
  left:50px;  /* adjust value accordingly */
   background-color: #E9E5DC;
    border: 1px solid transparent;
        border-radius: 2px 0 0 2px;
        box-sizing: border-box;
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.3);
}

    #buttons
{
  position:absolute;
  top:20px;  /* adjust value accordingly */
  right:50px;  /* adjust value accordingly */
   background-color: #E9E5DC;
   width:350px;
	height:450px;
    border: 1px solid transparent;
        border-radius: 2px 0 0 2px;
        box-sizing: border-box;
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.3);
    overflow-y:auto;
    overflow-x:auto;
}
    .controls {
        margin-top: 10px;
        border: 1px solid transparent;
        border-radius: 2px 0 0 2px;
        box-sizing: border-box;
        -moz-box-sizing: border-box;
        height: 32px;
        outline: none;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.3);
        top:20px;
      }
     
      #pac-input {
        background-color: #fff;
        font-family: Roboto;
        font-size: 15px;
        font-weight: 300;
        margin-left: 12px;
        padding: 0 11px 0 13px;
        text-overflow: ellipsis;
        width: 300px;
        top:20px;
      }

      #pac-input:focus {
        border-color: #4d90fe;
      }

      .pac-container {
        font-family: Roboto;
      }

      #type-selector {
        color: #fff;
        background-color: #4d90fe;
        padding: 5px 11px 0px 11px;
      }

      #type-selector label {
        font-family: Roboto;
        font-size: 13px;
        font-weight: 300;
      }
      #target {
        width: 345px;
      }
    </style>
  </head>
  <body>
  <input id="pac-input" class="controls" type="text" placeholder="Search " style="top:10px;">
	<input type="hidden" id="weather1" name="weather">
	<input type="hidden" id="address" name="address">
    <div id="map"></div> 
    <div id="weather" class="weather"></div>
   <div id="buttons" class="buttons">
   <output><%=request.getAttribute("logininfo")%></output>
   <br></br>
   <div id="foursquare" class="foursquare" style="overflow-y:auto;">  
   </div> 
  </div>
<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>
 
    <script>
   
    var pos;
    var revGeoCodeAddrs;
    var places;
    var place;
    var bounds;
    var icon ;
    var infoWindow;
    var marker;
    
    function initMap() {
        var map = new google.maps.Map(document.getElementById('map'), {
          zoom: 16,
          mapTypeId: google.maps.MapTypeId.ROADMAP
        });

        var input = document.getElementById('pac-input');
        var searchBox = new google.maps.places.SearchBox(input);
         infoWindow = new google.maps.InfoWindow({map: map});
           
        map.controls[google.maps.ControlPosition.TOP_LEFT].push(input);
		map.addListener('bounds_changed', function() {
        searchBox.setBounds(map.getBounds());
        });

        searchBox.addListener('places_changed', function() {
        places = searchBox.getPlaces();

        if (places.length == 0) {
            return;
          }
          place= places[0];
          
          bounds = new google.maps.LatLngBounds();
          icon = {
              url: place.icon,
              size: new google.maps.Size(71, 71),
              origin: new google.maps.Point(0, 0),
              anchor: new google.maps.Point(17, 34),
              scaledSize: new google.maps.Size(25, 25)
            };
          
           marker= new google.maps.Marker({
              map: map,
              draggable:true,
		      animation: google.maps.Animation.DROP,
              title: place.name,
              position: place.geometry.location
            });
            pos={lat:place.geometry.location.lat(),lng: place.geometry.location.lng()};
            map.setCenter(place.geometry.location);   
           address(pos);
           updateAPI(pos);
           infoWindow.open(map, marker);  
            
            marker.addListener('dragend',function(event) {
            pos={lat:event.latLng.lat(),lng: event.latLng.lng()};
           address(pos);
            updateAPI(pos);
            infoWindow.open(map, marker);   
              });
        });
        // Try HTML5 geolocation.
        if (navigator.geolocation) {
          navigator.geolocation.getCurrentPosition(function(position) {
             pos = {
              lat: position.coords.latitude,
              lng: position.coords.longitude
            };
            map.setCenter(pos);
            marker = new google.maps.Marker({
    		      map:map,
    		      draggable:true,
    		      animation: google.maps.Animation.DROP,
    		      position:pos
    		  });
            updateAPI(pos);  
       		 address(pos);
          infoWindow = new google.maps.InfoWindow({map: map});
      	  infoWindow.open(map, marker);
          marker.addListener('dragend',function(event) {
              pos={lat:event.latLng.lat(),lng: event.latLng.lng()};
              revGeoCodeAddrs = address(pos);
              updateAPI(pos);
              
              infoWindow.open(map, marker);   
                });

          }, function() {
            handleLocationError(true, infoWindow, map.getCenter());
          });
        } else {
          // Browser doesn't support Geolocation
          handleLocationError(false, infoWindow, map.getCenter());
        } 
    }

function address(pos){
	 console.log(pos);
	 var geocoder = new google.maps.Geocoder; 
		geocoder.geocode({'location': pos}, function(results, status) {
		    if (status == google.maps.GeocoderStatus.OK) {
		      if (results[0]) { 
		    	 infoWindow.setContent('Your location!!!</br>'+
		    			 results[0].formatted_address.replace(',',',</br>')+'</br>'+
		    			 ' <a id="tweet" href="https://twitter.com/intent/tweet?button_hashtag=MyLocation&text='+results[0].formatted_address+'" class="twitter-hashtag-button">Tweet #MyLocation</a>');
		    	 document.getElementById("address").value  =results[0].formatted_address;
		    } else {
		        window.alert('No results found');
		      }
		    } else {
		      window.alert('Geocoder failed due to: ' + status);
		    }
		  });
}

function updateAPI(position){
	 console.log(position);
	$.ajax({
           url: 'http://api.openweathermap.org/data/2.5/weather?lat='+position.lat+'&lon='+position.lng+'&mode=html&appid=75f773289aefd7f8743d75f61b05b49c',
           type: 'GET',
           dataType: 'html',
           success: function (data) {
          	 $('#div.weather').load(data);
          	 document.getElementById("weather1").value = data;
           }
       });
	
	$.ajax({
         url: 'https://api.foursquare.com/v2/venues/explore?ll='+position.lat+','+position.lng+'&limit=5&sights&venuePhotos=1&oauth_token=G0PJY3BF4JUNK0XU0WGCVR4NZMQBDREH1PDQBFJMNGQ4XSVN&v=20160318',
         type: 'GET',
         dataType: 'json',
         success: function (data) {
        	// console.log(data);
        	 var venues = data.response.groups[0].items;
        	// console.log(venues);
        
        	 var out = "<table><tr><th><strong>Places Nearby You!!!</strong></th></tr>";
        	    for(i = 0; i < venues.length; i++) {
        	        out += "<tr><td><strong>"+venues[i].venue.name+"</strong></br>";
        	        if(venues[i].venue.contact.formattedPhone ) {
        	        	out +=venues[i].venue.contact.formattedPhone+"</br>";	
        	        }
        	        if(venues[i].venue.hours.status ) {
        	        	out +=venues[i].venue.hours.status+"</br>";
        	        }
        	        if( venues[i].venue.url ) {
        	        	out +="<a href='+venues[i].venue.url+'>" +venues[i].venue.url +"</a></br>";	
        	        }
        	        if(venues[i].venue.location.formattedAddress) {
        	        	out +=venues[i].venue.location.formattedAddress+"</a></br>";	
        	        }
        	        out +="</td></tr>";
        	        }
        	    out += "</table>";
        	    out = out.toString().replace(/undefined/g, "");
        	    document.getElementById("foursquare").innerHTML = out;
        	//console.log(out);
         }
     });
	
	
}

      function handleLocationError(browserHasGeolocation, infoWindow, pos) {
        infoWindow.setPosition(pos);
        infoWindow.setContent(browserHasGeolocation ?
                              'Error: The Geolocation service failed.' :
                              'Error: Your browser doesn\'t support geolocation.');
      }
  
    </script>
    
     <script async defer src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBCLXS57IaH3kyZcdGY0uQ2kHPZ_-59tP4&libraries=places&callback=initMap"></script>
  </body>
</html>