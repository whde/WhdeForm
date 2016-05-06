Pod::Spec.new do |s|
s.name          = "WhdeForm"
s.version       = "1.0.0"
s.summary       = "iOS Form 表格."
s.homepage      = "https://github.com/whde/WhdeForm"
s.license       = 'MIT'
s.author        = { "Whde" => "460290973@qq.com" }
s.platform      = :ios, "7.0"
s.source        = { :git => "https://github.com/whde/WhdeForm.git", :tag => s.version.to_s }
s.source_files  = 'WhdeForm/WhdeForm/Class/*'
s.frameworks    = 'Foundation'
s.requires_arc  = true
s.description   = <<-DESC
It is a Form used on iOS, which implement by Objective-C, use Reusable System to save your App Memory.
DESC
end

