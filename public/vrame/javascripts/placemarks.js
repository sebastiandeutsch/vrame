function bounds_from_lat_lon_box(box) {
  var ne = new google.maps.LatLng(box.north, box.east);
  var sw = new google.maps.LatLng(box.south, box.west);
  return new google.maps.LatLngBounds(sw, ne);
}


function initialize_placemark_divs(){
  var geocoder    = new google.maps.Geocoder();
  var deutschland = new google.maps.LatLng(51.1656910, 10.4515260);
  
  $("div.placemark").each(function(){
    var div        = this;
    var map_canvas = $(".map_canvas",  div)[0];
    var value      = $(".json_string", div).val()
    var placemark  = eval("("+value+")") //TODO: JSON.parse besser

    if (typeof(placemark) == "object") {
      var map = new google.maps.Map(map_canvas, {
        zoom: 8,
        center: deutschland,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      })
     map.fitBounds(bounds_from_lat_lon_box(placemark.ExtendedData.LatLonBox));
    } else {
      var map = new google.maps.Map(map_canvas, {
        zoom: 8,
        center: deutschland,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      })      
    }
  })
}

$(initialize_placemark_divs);