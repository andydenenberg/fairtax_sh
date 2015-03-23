
def haversine_distance( lat1, lon1, lat2, lon2 )

  rad_per_deg = 0.017453293  #  PI/180
  # the great circle distance d will be in whatever units R is in
  rmiles = 3956           # radius of the great circle in miles

  dlon = lon2 - lon1
  dlat = lat2 - lat1
 
  dlon_rad = dlon * rad_per_deg
  dlat_rad = dlat * rad_per_deg
 
  lat1_rad = lat1 * rad_per_deg
  lon1_rad = lon1 * rad_per_deg
 
  lat2_rad = lat2 * rad_per_deg
  lon2_rad = lon2 * rad_per_deg
 
  # puts "dlon: #{dlon}, dlon_rad: #{dlon_rad}, dlat: #{dlat}, dlat_rad: #{dlat_rad}"
 
  a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
  c = 2 * Math.asin( Math.sqrt(a))
 
  dMi = rmiles * c          # delta between the two points in miles
 
  return dMi

end
