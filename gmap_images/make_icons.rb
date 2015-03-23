URL = 'http://chart.googleapis.com/chart?chst=d_map_pin_letter&chld=26%7c3ADF00%7c000000&.png%3f'
# http://thydzik.com/thydzikGoogleMap/markerlink.php?text=1&color=5680FC

# http://chart.googleapis.com/chart?chst=d_map_pin_letter&chld=1%7c#40FF00%7c000000&.png%3f
require 'net/http'

(1..105).each do |i|
Net::HTTP.start( 'chart.googleapis.com' ) { |http|
  resp = http.get( '/chart?chst=d_map_pin_letter&chld=' + i.to_s + '%7c74DF00%7c000000&.png%3f' )
  open( 'block_mem' + i.to_s + '.png', 'wb' ) { |file|
    file.write(resp.body)
  }
}
puts i
end

#Nokogiri::HTML(open(URL)).xpath("//img/@src").each do |src|
#  uri = make_absolute(src,URL) 
#  File.open(File.basename(uri),'wb'){ |f| f.write(open(uri).read) }
#end

