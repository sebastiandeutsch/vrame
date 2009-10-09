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

  var placemark  = JSON.parse($(".json_string", this.div).val(), GMap.georevive);

  if (typeof(placemark) == "object") {
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

GMap.georevive = function georevive(key, value) {
  if (key == "geometry"){
    var ac = function(x){return x * (180/Math.PI)};

    var retval = {};
    retval.location = new google.maps.LatLng(value.location.Lf, value.location.Nf);
    retval.location_type = value.location_type;
    var ne = new google.maps.LatLng(ac(value.viewport.O.h), ac(value.viewport.A.h));
    var sw = new google.maps.LatLng(ac(value.viewport.O.i), ac(value.viewport.A.i));
    retval.viewport = new google.maps.LatLngBounds(sw, ne);
    return retval;
  } else {
    return value;
  }
};

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
      $(".json_string").val(JSON.stringify(result[0]));
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


/*

function bounds_from_lat_lon_box(box) {
  var ne = new google.maps.LatLng(box.north, box.east);
  var sw = new google.maps.LatLng(box.south, box.west);
  return new google.maps.LatLngBounds(sw, ne);
}


function update_map(scope) {
  var placemark_div = $(scope).parents(".placemark")[0]; //TODO was wenn Scope == placemark_div?
  var address = $(".address", placemark_div).val();
  placemark_div.geocoder.geocode({address: address, bounds: placemark_div.map.getBounds()}, function(status, result){
    relocate_map(map, result[0]);
    $(".json_string").val(JSON.stringify(result[0]));
  })  
}

// Reviver for JSON.parse
function georevive(key, value) {
  if (key == "geometry"){
    var ac = function(x){return x * (180/Math.PI)};

    var retval = {};
    retval.location = new google.maps.LatLng(value.location.Lf, value.location.Nf);
    retval.location_type = value.location_type;
    var ne = new google.maps.LatLng(ac(value.viewport.N.h), ac(value.viewport.A.h));
    var sw = new google.maps.LatLng(ac(value.viewport.N.i), ac(value.viewport.A.i));
    retval.viewport = new google.maps.LatLngBounds(sw, ne);
    return retval;
  } else {
    return value;
  }
}

function initialize_placemark_divs(){
  var geocoder    = new google.maps.Geocoder();
  var deutschland = new google.maps.LatLng(51.1656910, 10.4515260);
  
  $("div.placemark").each(function(){
    var div        = this;
    var map_canvas = $(".map_canvas",  div)[0];
    var value      = $(".json_string", div).val();
    var placemark  = JSON.parse(value, georevive);

    var map = new google.maps.Map(map_canvas, {
      zoom: 5,
      center: deutschland,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    })
    div.map = map;
    div.geocoder = geocoder;
    if (typeof(placemark) == "object") {
      map.fitBounds(placemark.geometry.viewport);
      var position = placemark.geometry.location;
      div.marker = new google.maps.Marker({position: position, map: map});
      $(".address").val(placemark.address);
    } else {
    }
    var old_address = $(".address").val();
    var relocate_timer = null;
    $(".address")
      .keyup(function(){
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
            relocate_map(map_canvas);
            relocate_timer = null;
            $("#geolocation_spinner").hide();
          }, 1500)
        }
      })
    
  })
}

$(initialize_placemark_divs);

*/