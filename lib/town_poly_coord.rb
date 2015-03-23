def town_poly_coord(town)
  boundries = Hash.new 
  boundries['Wilmette'] =   [ {'lng' => -87.7027509, 'lat' => 42.088743}, {'lng' => -87.670, 'lat' => 42.0691599}, {'lng' => -87.769861, 'lat' => 42.062612}, {'lng' => -87.787113, 'lat' => 42.094146 } ]  
  boundries['Northfield'] = [ {'lng' => -87.750, 'lat' => 42.115}, {'lng' => -87.750, 'lat' => 42.086}, {'lng' => -87.8, 'lat' => 42.086}, {'lng' => -87.8, 'lat' => 42.115} ]       
  boundries['Glencoe']  = [ {'lng' => -87.760, 'lat' => 42.1524}, {'lng' => -87.73, 'lat' => 42.119}, {'lng' => -87.77, 'lat' => 42.119}, {'lng' => -87.80, 'lat' => 42.1524} ]
  boundries['Winnetka'] = [ {'lng' => -87.730835, 'lat' => 42.128}, {'lng' => -87.708, 'lat' => 42.091802}, {'lng' => -87.757539, 'lat' => 42.083209}, {'lng' => -87.77, 'lat' => 42.128} ]
  boundries['Evanston'] = [ {'lng' => -87.670, 'lat' => 42.069}, {'lng' => -87.660, 'lat' => 42.018},  {'lng' => -87.72, 'lat' => 42.018 }, {'lng' => -87.725, 'lat' => 42.069 } ]
#  boundries['Kenilworth'] = [ {'lng' => -87.7082 , 'lat' => 42.095059}, {'lng' => -87.7082, 'lat' => 42.08635 }, {'lng' => -87.722589, 'lat' => 42.083354}, {'lng' => -87.726364 , 'lat' => 42.096361} ]
  boundries['Kenilworth'] = [ {'lng' => -87.603607 , 'lat' => 42.169511}, {'lng' => -87.455292, 'lat' => 41.623655 }, {'lng' => -87.857666, 'lat' => 41.624682}, {'lng' => -88.239441 , 'lat' => 42.181723 } ]
boundries['Arlington Heights'] = [ {'lng' => -87.9431 , 'lat' => 42.1552}, {'lng' => -87.9463, 'lat' => 41.0284 }, {'lng' => -88.0306, 'lat' => 42.0282}, {'lng' => -88.0349 , 'lat' => 42.1568 } ]

  boundries['Northbrook'] = [ {'lng' => -87.76 , 'lat' => 42.17}, {'lng' => -87.76, 'lat' => 42.08635 }, {'lng' => -87.9, 'lat' => 42.083354}, {'lng' => -87.9 , 'lat' => 42.17} ]
#  boundries['Glenview'] = [ {'lng' => -87.784195 , 'lat' => 42.1051}, {'lng' => -87.754669, 'lat' => 42.055411 }, {'lng' => -87.887878, 'lat' => 42.054391}, {'lng' => -87.877579 , 'lat' => 42.11758 } ]
boundries['Glenview'] = [ {'lng' => -87.603607 , 'lat' => 42.169511}, {'lng' => -87.455292, 'lat' => 41.623655 }, {'lng' => -87.857666, 'lat' => 41.624682}, {'lng' => -88.239441 , 'lat' => 42.181723 } ]
boundries['Skokie'] = [ {'lng' => -87.603607 , 'lat' => 42.169511}, {'lng' => -87.455292, 'lat' => 41.623655 }, {'lng' => -87.857666, 'lat' => 41.624682}, {'lng' => -88.239441 , 'lat' => 42.181723 } ]

# the following is custom...
boundries['Schaumburg'] = [ {'lng' => -87.603607 , 'lat' => 42.169511}, {'lng' => -87.455292, 'lat' => 41.623655 }, {'lng' => -87.857666, 'lat' => 41.624682}, {'lng' => -88.239441 , 'lat' => 42.181723 } ]

# Use this to unmask tight limits
  boundries['Cookcounty'] = [ {'lng' => -87.603607 , 'lat' => 42.169511}, {'lng' => -87.455292, 'lat' => 41.623655 }, {'lng' => -87.857666, 'lat' => 41.624682}, {'lng' => -88.239441 , 'lat' => 42.181723 } ]
  boundries['Hoffman Estates'] = [ {'lng' => -87.603607 , 'lat' => 42.169511}, {'lng' => -87.455292, 'lat' => 41.623655 }, {'lng' => -87.857666, 'lat' => 41.624682}, {'lng' => -88.239441 , 'lat' => 42.181723 } ]
  boundries['Golf'] = [ {'lng' => -87.603607 , 'lat' => 42.169511}, {'lng' => -87.455292, 'lat' => 41.623655 }, {'lng' => -87.857666, 'lat' => 41.624682}, {'lng' => -88.239441 , 'lat' => 42.181723 } ]

  if boundries[town] 
    return boundries[town]
  else
    return boundries['Cookcounty']
  end
  
end


#  http://itouchmap.com/latlong.html


def town_boundaries(town)
  poly = town_poly_coord(town) # upper, lower, right, left
    tb = [ poly[0]['lat'], poly[1]['lat'], poly[2]['lat'], poly[3]['lat'] ]
    lr = [ poly[0]['lng'], poly[1]['lng'], poly[2]['lng'], poly[3]['lng'] ]
    top = tb.max
    bottom = tb.min
    right = lr.max
    left = lr.min
    return [ top, bottom, right, left ]
end