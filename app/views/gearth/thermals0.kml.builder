text =    "
Centre Lng: #{@centre[0]}
Centre Lat: #{@centre[1]}
X Min: #{@bbox[0]}
Y Min: #{@bbox[1]}
X Max: #{@bbox[2]}
Y Max: #{@bbox[3]}
"

xml.instruct! :xml
xml.kml(:xmlns => "http://earth.google.com/kml/2.2") do
  xml.Document {

	xml.Placemark {
		xml.name("thermals0")
		xml.Style {
			xml.LineStyle {
				xml.color("8fefe0ff")
				xml.width("3")
			}
    	}

		xml.MultiGeometry {
			@windpoints.each do |o|
				xml.LineString {
					xml.extrude("2")
					xml.altitudeMode("absolute")
					xml.coordinates {
						xml.text! "#{o[:dlon]},#{o[:dlat]},#{o[:altitude]} "
						xml.text! "#{o[:lon0]},#{o[:lat0]},0.0} "
					}
        		}
			end
		}
	}

	xml.Placemark {
		xml.name("source")

		xml.MultiGeometry {
			@windpoints.each do |o|
						xml.Point {
						xml.coordinates {
							xml.text! "#{o[:lon0]},#{o[:lat0]},0.0} "
					}
				}

			end
		}
	}


  }
end