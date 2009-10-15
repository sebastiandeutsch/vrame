GMap = function(placemark_div) {
  this.div        = placemark_div;
  this.div.gmap   = this;
  this.map_canvas = $(".map_canvas",  this.div)[0];
  this.map = new google.maps.Map(this.map_canvas, {
    zoom: 5,
    center: GMap.deutschland,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  });
  this.marker = new google.maps.Marker({visible: false, map: this.map, clickable: false});

  var placemark  = GMap.parse($(".json_string", this.div).val());

  if (typeof(placemark) == "object" && placemark != null) {
    this.relocate_map(placemark);
    this.set_marker(placemark.geometry.location);
    $(".address").val(placemark.formatted_address);
  } else {
  }

  var old_address = $(".address").val();
  var relocate_timer = null;
  var gmap = this;
  $(".address")
    .keyup(function(e){
      if(e.keyCode == 13){
        e.preventDefault();
      }
      var new_address = $(this).val();
      if (new_address != old_address) { //only act on changes
        old_address = new_address;

        if (relocate_timer != null) { //reset old timer
          clearTimeout(relocate_timer);
          relocate_timer = null;
          $("#geolocation_spinner").hide();
        }
        $("#geolocation_spinner").show();
        relocate_timer = setTimeout(function(){
          gmap.update();
          relocate_timer = null;
          $("#geolocation_spinner").hide();
        }, 1500)
      }
    })
    .keypress(function(e){
      if(e.keyCode == 13){
        e.preventDefault();
        gmap.update();
      }      
    })
  
}

GMap.stringify = function(o) {
  var result_geometry = {
    location : {
      lat   : o.geometry.location.lat(),
      lng   : o.geometry.location.lng() },
    location_type : o.geometry.location_type,
    viewport : {
      north : o.geometry.viewport.getNorthEast().lat(),
      east  : o.geometry.viewport.getNorthEast().lng(),
      south : o.geometry.viewport.getSouthWest().lat(),
      west  : o.geometry.viewport.getSouthWest().lng() }
  };
  if (o.geometry.bounds) {
    result_geometry.bounds = {
      north : o.geometry.bounds.getNorthEast().lat(),
      east  : o.geometry.bounds.getNorthEast().lng(),
      south : o.geometry.bounds.getSouthWest().lat(),
      west  : o.geometry.bounds.getSouthWest().lng()
    }
  }
  o.geometry = result_geometry;
  return JSON.stringify(o);
}

GMap.parse = function(s) {
  if (s == "") return null;
  var o = JSON.parse(s);
  var geometry = {};
  geometry.location = new google.maps.LatLng(o.geometry.location.lat, o.geometry.location.lng);
  geometry.location_type = o.geometry.location_type;
  geometry.viewport = new google.maps.LatLngBounds(
      new google.maps.LatLng(o.geometry.viewport.south, o.geometry.viewport.west),
      new google.maps.LatLng(o.geometry.viewport.north, o.geometry.viewport.east)
    );
  if (o.geometry.bounds) {
    geometry.bounds = new google.maps.LatLngBounds(
        new google.maps.LatLng(o.geometry.bounds.south, o.geometry.bounds.west),
        new google.maps.LatLng(o.geometry.bounds.north, o.geometry.bounds.east)
      );    
  }
  o.geometry = geometry;
  return o;
}

GMap.prototype = {
  set_marker : function(pos){
    this.marker.setPosition(pos);
    this.marker.setVisible(true);
  },
  
  unset_marker : function() {
    this.marker.setVisible(false);    
  },
  
  relocate_map : function(placemark) {
    this.map.fitBounds(placemark.geometry.viewport);
    this.set_marker(placemark.geometry.location);
  },
  
  update : function() {
    var address = $(".address", this.div).val();
    var gmap = this;
    GMap.geocoder.geocode({address: address, bounds: this.map.getBounds()}, function(result, status){
      gmap.relocate_map(result[0]);
      $(".json_string").val(GMap.stringify(result[0]));
      $(".address", gmap.div).val(result[0].formatted_address)
    })
  }
  
}

GMap.update = function(field_id) {
  var placemark_div = $("#"+field_id)[0];
  placemark_div.gmap.update();
}

GMap.initialize_placemark_divs = function(){
  GMap.geocoder    = new google.maps.Geocoder();
  GMap.deutschland = new google.maps.LatLng(51.1656910, 10.4515260);
  $("div.placemark").each(function(){
    this.gmap = new GMap(this)
  });
}


$(GMap.initialize_placemark_divs);
