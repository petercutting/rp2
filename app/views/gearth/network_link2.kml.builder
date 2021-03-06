server = url_for :controller => 'gearth',  :only_path => false
xml.instruct!
xml.kml(:xmlns => "http://earth.google.com/kml/2.2") {
xml.Document {
  xml.name("Pass parameters to my Rails app")
  xml.open(1)
  xml.visible(1)
  xml.NetworkLink {
    xml.name("My rails app being passed parameters")
    xml.open(1)
    xml.visibility(0)
    xml.flyToView(0)
    xml.Link {
      xml.href("#{server}")
      xml.viewRefreshMode("onStop")
      xml.viewRefreshTime(0.5)
      xml.viewFormat("BBOX=[bboxWest],[bboxSouth],[bboxEast],[bboxNorth]&CENTRE=[lookatLon],[lookatLat]")
      }
    }


    @igcfs.each do |igcf|

    igcf.filename.split("/").each do |x|
    xml << "<Folder> "
xml.name("xx #{x}")
    end
  xml.NetworkLink {
    xml.name("#{igcf.filename}")
    xml.open(1)
    xml.visibility(0)
    xml.flyToView(0)
    xml.Link {
      xml.href(url_for(:action=>:route, :id => igcf.id.to_s,:only_path => false))
      xml.viewRefreshMode("onStop")
      xml.viewRefreshTime(0.5)
      xml.viewFormat("BBOX=[bboxWest],[bboxSouth],[bboxEast],[bboxNorth]&CENTRE=[lookatLon],[lookatLat]")
      }
    }

    igcf.filename.split("/").each do |x|
    xml << "</Folder> "
    end
end

  }
}
