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
      xml.Style{
      xml.LineStyle{
        xml.color("5fff0000")
        xml.width("3")
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
  }
end