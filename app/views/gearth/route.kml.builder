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
      xml.Snippet(:maxLines => "9") {
##        xml.cdata!(text)
      }

      xml.LineString {
            xml.name("IGC data")

        xml.extrude("1")
        xml.altitudeMode("absolute")
        xml.coordinates(
          @ps.each{ |p|
            "#{p}"
          }
        )
      }
    }
  }
end