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
    xml.name("wind directions")
      xml.Style{
      xml.LineStyle{
        xml.color("afffff00")
        xml.width("3")
      }
    }
      xml.Snippet(:maxLines => "9") {
##        xml.cdata!(text)
      }
      		xml.MultiGeometry {

      xml.LineString {
        xml.extrude("0")
        xml.altitudeMode("clampToGround")
        xml.coordinates{

          @windpoints.each do |o|
            xml.text! "#{o[:dlon_centred]},#{o[:dlat_centred]} "
            xml.text! "#{o[:dlon2_centred]},#{o[:dlat2_centred]} "
            xml.text! "#{o[:dlon_centred]},#{o[:dlat_centred]} "
          end
        }
        }
      }
    }

    xml.Placemark {
    xml.name("moving average pos")
      xml.Style{
      xml.LineStyle{
        xml.color("afffff00")
        xml.width("3")
      }
    }
      xml.Snippet(:maxLines => "9") {
##        xml.cdata!(text)
      }
		xml.MultiGeometry {
        xml.LineString {
        xml.extrude("0")
        xml.altitudeMode("absolute")
        xml.coordinates{
          @objects.each do |o|
            xml.text! "#{o[:malon]},#{o[:malat]},#{o[:baro_alt]} "
          end
        }
        }
      }
    }

	xml.Placemark {
		xml.name("thermals")
		xml.Style {
			xml.LineStyle {
				xml.color("afff0000")
				xml.width("8")
			}
    	}

		xml.MultiGeometry {
			@windpoints.each do |o|
				xml.LineString {
					xml.extrude("2")
					xml.altitudeMode("absolute")
					xml.coordinates {
						xml.text! "#{o[:dlon]},#{o[:dlat]},#{o[:altitude]} "
						xml.text! "#{o[:dlon2]},#{o[:dlat2]},#{o[:altitude2]} "
					}
        		}
			end
		}
	}

    xml.Placemark {
    xml.name("dedt")
      xml.Style{
      xml.LineStyle{
        xml.color("af0000ff")
        xml.width("2")
      }
    }
      xml.Snippet(:maxLines => "9") {
##        xml.cdata!(text)
      }
		xml.MultiGeometry {
        xml.LineString {
        xml.extrude("1")
        xml.altitudeMode("relativeToGround")
        xml.coordinates{
          @objects.each do |o|
            xml.text! "#{o[:dlon]},#{o[:dlat]},#{o[:dedt]/35} "
          end
        }
        }
      }
    }


    xml.Placemark {
    xml.name("moving average ms")
      xml.Style{
      xml.LineStyle{
        xml.color("af00ff00")
        xml.width("2")
      }
    }
      xml.Snippet(:maxLines => "9") {
##        xml.cdata!(text)
      }
		xml.MultiGeometry {
        xml.LineString {
        xml.altitudeMode("relativeToGround")
        xml.extrude("1")
        xml.coordinates{
          @objects.each do |o|
            xml.text! "#{o[:dlon]},#{o[:dlat]},#{o[:mams]*20} "
          end
        }
        }
      }
    }

    xml.Placemark {
    xml.name("track")
      xml.Style{
      xml.LineStyle{
        xml.color("ffffffff")
        xml.width("2")
      }
    }
      xml.Snippet(:maxLines => "9") {
##        xml.cdata!(text)
      }
		xml.MultiGeometry {
        xml.LineString {
        xml.altitudeMode("absolute")
        xml.coordinates{
          @objects.each do |o|
            xml.text! "#{o[:dlon]},#{o[:dlat]},#{o[:baro_alt]} "
          end
        }
        }
      }
    }
  }
end