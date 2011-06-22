server = url_for :controller => 'gearth',  :only_path => false
xml.instruct!
xml.kml(:xmlns => "http://earth.google.com/kml/2.2") {
xml.Document {

    @dirs.each do |dir|

    xml.NetworkLink {
    xml.name( "#{dir[:dir]}")
    xml.open(0)
    xml.visibility(0)
    xml.flyToView(0)
    xml.Link {
      xml.href(url_for(:action=>:thermals, :dir => dir[:dir], :spread => dir[:spread],:escape => false,:only_path => false))
      xml.viewRefreshMode("onRequest")
      }
    }
end

  }
}
