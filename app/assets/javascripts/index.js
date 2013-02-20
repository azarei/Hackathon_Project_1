// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
(function ($) {
	"use strict";

	$(document).ready(function () {
		var map, markers, tweetCount = 0;
		initialize();

		$('#search').click(function(event) {
            if ($('#searchBar').val()) {
                redrawMap();
                $('#info').hide();
                $('#main-description').hide();
                searchAndPlot($('#searchBar').val());
                refreshImages();
                $('#tweets-wrapper').show();
		    }
        });

        map.on('zoomstart', function () {
            var searchTerm = $('#searchBar').val();
            if (searchTerm) {
                refreshImages();               
            }
        });

        map.on('dragend', function () {
            var searchTerm = $('#searchBar').val();
            if (searchTerm) {
                refreshImages();               
            }
        });

		function initialize() {
			var southWest = new L.LatLng(-58.077876, -168.750000),
			northEast = new L.LatLng(74.683250, 178.945313),
			bounds = new L.LatLngBounds(southWest, northEast);
      $('#tweets-wrapper').hide();

			map = new L.Map('map', {
				center: new L.LatLng(28.304381, -21.445313),
				zoom: 1,
				maxBounds: bounds
			});

			var cloudmadeUrl = 'http://{s}.tile.cloudmade.com/30d1976aef28416ba4e9ed7cdd909ad8/50838/256/{z}/{x}/{y}.png',
			cloudmade = new L.TileLayer(cloudmadeUrl, {maxZoom: 18});
			map.addLayer(cloudmade);

			map.setView(new L.LatLng(40, -90), 3);
			markers = new L.MarkerClusterGroup();

			$('.trend').each(function(i) {
				$(this).click(function(event) {
					event.preventDefault();
					searchAndPlot($(this).text());
                    // remove the default messages
                    $('#info').hide();
                    $('#main-description').hide();
                    $('#tweets-wrapper').show();
                    $('#searchBar').val($(this).text());
                    refreshImages();
				});
			});
		}

	function redrawMap() {

		$('#map-content').append('<div id="overlay"></div>');
		$("#overlay").css({
			'opacity' : 0.8,
			'top': 0,
			'left': 0,
			'background-color': 'black',
			'background': 'url("assets/loader.gif") center no-repeat #000',
			'height': '850px',
			'width': '100%',
			'z-index': 5000
		});
		markers.clearLayers();
		map.removeLayer(markers);
		$('#overlay').fadeOut('slow', function() {
			$(this).remove();
		});
	}

    function refreshImages() {

        var coords = map.getBounds().toBBoxString().split(','),
            keyword = $('#searchBar').val(),
           lnt = (parseFloat(coords[0])+parseFloat(coords[2]))/2,
           lat = (parseFloat(coords[1])+parseFloat(coords[3]))/2;

        if (!$('#image-cont').hasClass('inited')) {
            $('#image-cont').html('loading images..');
            $('#image-cont').addClass('inited');
        }
        console.log('refreshing image');
       var request = $.get('index/image.json?phrase='+keyword+'&zoom='+map.getZoom()+'&long='+lnt+'&lat='+lat+'&num=4');
        request.success(function(data) {
            var imgdata = '';
            
            if (data) {
                var undefound = false;
                $.each(data, function (key, img) {
                    imgdata += '<img id="image-' + key + '" class="sample-image image" src="'+img.image+'" alt="'+img.caption+'" title="'+img.caption+'">'
							+ '<div id="dialog-for-image-' + key + '" class="dialog" style="width:700px; display:none;">'
							+ '<img style="float:left; margin:-10px 10px 10px 0;" src="' + img.image + '"/>'
							+ '<div>'
								+ '<h4>' + img.title + '</h4>'
								+ '<p>' + img.caption + '</p>'
                + '<a id="pricing">Get Pricing Info</a>' 
							+ '</div>'
							+ '</div>';

                    if (img.image == undefined) {
                        undefound = true;
                    }
                });

                if (!undefound) { 
                    $('#image-cont').fadeOut("slow", function(){
                        $('#image-cont').html(imgdata);
                        $('#image-cont').fadeIn("slow");
                    });
                    console.log('image replaced');
                }
            }
        });

        request.error(function(jqXHR, textStatus, errorThrown) {
            console.log('error trying to get images');
            $('#image-cont').html('error loading images'); 
        });
    }

	function searchAndPlot(searchTerm) {
		redrawMap();
		$("#tweets").liveTwitter(searchTerm, {rpp: 300000, filter: function(tweet){
			if(tweet.geo != null) {
				plotTweet(tweet);
			}
			return (tweet.geo != null);
		}});
	}
	

	function plotTweet(tweet) {
		var location = new L.LatLng(tweet.geo.coordinates[0], tweet.geo.coordinates[1]),
			marker = new L.Marker(location);

            tweetCount++;
            $('#tcount').html('('+tweetCount+')');
            console.log(tweetCount);

			marker.on('click', function() {
				$('#info').empty();
                var tweetMarkup = '<div class="tweet">' + tweet.text + '</div>';
				$('#info').append(tweetMarkup);
			});

		markers.addLayer(marker);
		map.addLayer(markers);
	}

	$('body').delegate('.sample-image', 'click', function(e){
		var dialogID = '#dialog-for-' + e.target.id;
		$(dialogID).modal({
			onOpen: function(dialog) {
				dialog.overlay.fadeIn('slow', function() {
					dialog.container.fadeIn('fast', function() {
						dialog.data.fadeIn();
					});
				})
			},
			onClose: function(dialog) {
				dialog.overlay.fadeOut('slow', function() {
					dialog.container.fadeOut('fast', function() {
						dialog.data.fadeOut(function() {
							$.modal.close();
						});
					});
				})
			}
		});
		return false;
	});
});
})(jQuery);
