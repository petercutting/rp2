text =    "test3
"

xml.instruct! :xml
xml.kml(:xmlns => "http://earth.google.com/kml/2.2") do
  xml.Document {
    xml.Placemark {
      xml.Snippet(:maxLines => "1") {
##        xml.cdata!(text)
      }
        xml.name("IGC data")
		xml.MultiGeometry {
        xml.LineString {

        xml.extrude("1")
        xml.altitudeMode("absolute")
        xml.coordinates{
          @ps.each do |@p|
            xml.text! "#{@p[0]},#{@p[1]},#{@p[2]} "
          end
        }
        }
      }
    }
  }
end