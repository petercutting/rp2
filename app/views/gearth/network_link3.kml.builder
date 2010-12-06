server = url_for :controller => 'gearth',  :only_path => false
xml.instruct!
xml.kml(:xmlns => "http://earth.google.com/kml/2.2") {
xml.Document {
  xml.name("No effect")
  xml.open(1)
  xml.visible(1)

    @entries.each do |entry|

    if File.directory?(entry)
    xml.NetworkLink {
    xml.name("#{entry}")
    xml.open(1)
    xml.visibility(0)
    xml.flyToView(0)
    xml.Link {
      xml.href(url_for(:action=>:network_link3, :path => entry,:only_path => false))
      xml.viewRefreshMode("onRequest")
      xml.viewFormat("BBOX=[bboxWest],[bboxSouth],[bboxEast],[bboxNorth]&CENTRE=[lookatLon],[lookatLat]")
      }
    }
  end

  if File.file?(entry)
    xml.NetworkLink {
    xml.name("#{entry}")
    xml.open(1)
    xml.visibility(0)
    xml.flyToView(0)
    xml.Link {
      xml.href(url_for(:action=>:route, :path => entry,:only_path => false))
      xml.viewRefreshMode("onRequest")
      xml.viewFormat("BBOX=[bboxWest],[bboxSouth],[bboxEast],[bboxNorth]&CENTRE=[lookatLon],[lookatLat]")
      }
    }
  end
end

  }
}
