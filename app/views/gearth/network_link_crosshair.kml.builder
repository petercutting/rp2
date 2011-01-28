server = url_for :controller => 'gearth',  :only_path => false
xml.instruct!
xml.kml(:xmlns => "http://earth.google.com/kml/2.2") {
xml.Document {
  xml.open(1)
  xml.visible(1)
  xml.NetworkLink {
    xml.name("crosshair")
    xml.open(1)
    xml.visibility(0)
    xml.flyToView(0)
    xml.Link {
      xml.href("#{server}/crosshair")
      xml.viewRefreshMode("onStop")
      xml.viewRefreshTime(0.5)
      xml.viewFormat("BBOX=[bboxWest],[bboxSouth],[bboxEast],[bboxNorth]&CENTRE=[lookatLon],[lookatLat]")
      }
    }

  }
}
