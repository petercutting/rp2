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
        xml.altitudeMode("absolute")
        xml.coordinates{
          @objects.each do |o|
            xml.text! "#{o[:dlon]},#{o[:dlat]},#{o[:dedt]/35} "
          end
        }
        }
      }
    }


    xml.Placemark {
    xml.name("mams")
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
        xml.altitudeMode("absolute")
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
    xml.name("route")
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