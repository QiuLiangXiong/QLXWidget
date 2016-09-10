Pod::Spec.new do |s|
s.name = 'QLXWidget'
s.version = '1.1.0'
s.license = 'MIT'
s.summary = 'UICollectionView插件化'
s.homepage = 'https://github.com/QiuLiangXiong/QLXWidget'
s.authors = { 'QiuLiangXiong' => '820686089@qq.com' }
s.source = { :git => 'https://github.com/QiuLiangXiong/QLXWidget.git', :tag => "1.1.0" }
s.requires_arc = true
s.ios.deployment_target = '7.0'

s.source_files = 'UICollectionView+QLXWidgetDemo/UICollectionView+QLXWidget/*.{h,m}'

s.dependency  'UICollectionView-QLX'

end
