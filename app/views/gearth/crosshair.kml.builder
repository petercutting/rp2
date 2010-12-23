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
        xml.cdata!(text)
      }
      xml.name("cross-hair")
      xml.Style {
        xml.LabelStyle {
          xml.scale(0)
        }
        xml.IconStyle {
          xml.color("ffefebde")
          xml.Icon {
            xml.href("root://icons/palette-3.png")
            xml.x(128)
            xml.y(32)
            xml.w(32)
            xml.h(32)
          }
        }
      }
      		xml.MultiGeometry {

      xml.LineString {
        xml.name("IGC data")
        xml.extrude("1")
        xml.altitudeMode("relativeToGround")
        xml.coordinates{
            xml.text! "#{@bbox[0]}, #{@bbox[1]},100 "
            xml.text! "#{@bbox[1]}, #{@bbox[2]},100 "
            xml.text! "#{@bbox[2]}, #{@bbox[3]},100 "
            xml.text! "#{@bbox[3]}, #{@bbox[0]},100 "
        }
        }

      xml.Point {
        xml.coordinates("#{@centre[0]}, #{@centre[1]}");
      }
    }
    }
  }
end
