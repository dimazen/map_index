Pod::Spec.new do |s|
  s.name         = "MapIndex"
  s.version      = "0.0.2"
  s.summary      = "Fast map clusterization build on top of Region QuadTree."
  s.homepage     = "https://github.com/poteryaysya/map_index"
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = "Shemet Dmitriy"
  s.source       = { :git => "https://github.com/poteryaysya/map_index.git", :tag => "0.0.2"}

  s.platform     = :ios, '6.0'
  s.source_files = 'Classes', 'MapIndex/**/*.{h,m}'

  s.frameworks  = 'MapKit'
  s.requires_arc = true
end
