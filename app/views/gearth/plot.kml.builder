text =    "
Centre Lng: #{@centre[0]}
Centre Lat: #{@centre[1]}
X Min: #{@bbox[0]}
Y Min: #{@bbox[1]}
X Max: #{@bbox[2]}
Y Max: #{@bbox[3]}
"

xml.instruct! :xml
xml.kml(:xmlns => "http://earth.google.com/kml/2.2", "xmlns:gx" => "http://www.google.com/kml/ext/2.2") do
  xml.Document {
        xml.flyToView("1")

    xml.Placemark {
    xml.name("plot")
      xml.Style{
      xml.LineStyle{
        xml.color("ffffffff")
        xml.width("2")
      }
    }
      xml.Snippet(:maxLines => "9") {
##        xml.cdata!(text)
      }



       xml.gx(:FlyTo){
          xml.gx(:duration,"2.0")
          xml.gx(:flyToMode,"bounce")
          xml.LookAt {
             xml.longitude("#{@po[:longitude]}")
             xml.latitude("#{@po[:latitude]}")
             xml.altitude("0")
             xml.range("1500.0")
             xml.tilt("70.0")
             xml.heading("71.131493")
           }
       }
		xml.MultiGeometry {
        xml.LineString {
        xml.altitudeMode("clampToGround")
        xml.coordinates{
          @pos.each do |o|
            xml.text! "#{o[:longitude]},#{o[:latitude]},#{o[:altitude]} "
          end
        }
        }
      }
    }


        xml.Placemark {
    xml.name("pos")


          xml.LookAt {
             xml.longitude("#{@po[:longitude]}")
             xml.latitude("#{@po[:latitude]}")
             xml.altitude("0")
             xml.range("1500.0")
             xml.tilt("70.0")
             xml.heading("71.131493")
           }

        xml.Point {
        xml.coordinates{

            xml.text! "#{@po[:longitude]},#{@po[:latitude]},#{@po[:altitude]} "

        }
        }

    }




  }
end