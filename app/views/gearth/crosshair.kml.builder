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
    xml.name("bbox")
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
            xml.text! "#{@bbox[0]},#{@bbox[3]},1000 "
            xml.text! "#{@bbox[2]},#{@bbox[1]},1000 "
            xml.text! "#{@bbox[0]},#{@bbox[1]},1000 "
            xml.text! "#{@bbox[2]},#{@bbox[3]},1000 "
        }
        }
      }
    }


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

      xml.Point {
        xml.coordinates("#{@centre[0]}, #{@centre[1]}");
      }
    }
  }
end
