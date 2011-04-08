server = url_for :controller => 'gearth',  :only_path => false

xml.instruct!
xml.kml(:xmlns => "http://earth.google.com/kml/2.2") {
xml.Document {

    xml.NetworkLink {
    xml.name("process_igc_files")
    xml.open(1)
    xml.visibility(0)
    xml.flyToView(0)
    xml.Link {
      xml.href(url_for(:action=>:process_igc_files, :path =>"#{@path}", :only_path => false))
      xml.viewRefreshMode("onRequest")
      }
    }

    xml.NetworkLink {
    xml.name("files")
    xml.open(1)
    xml.visibility(0)
    xml.flyToView(0)
    xml.Link {
      xml.href(url_for(:action=>:network_link3, :path =>"#{@path}", :only_path => false))
      xml.viewRefreshMode("onRequest")
      }
    }
  }
}
