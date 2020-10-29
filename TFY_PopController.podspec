
Pod::Spec.new do |spec|

  spec.name         = "TFY_PopController"

  spec.version      = "1.0.0"

  spec.summary      = "控制器弹出框"

  spec.description  = <<-DESC  
  控制器弹出框
                   DESC

  spec.homepage     = "https://github.com/13662049573/TFY_POPControllerKit"
  
  spec.license      = "MIT"
  
  spec.author       = { "田风有" => "420144542@qq.com" }
  
  spec.platform     = :ios, "10.0"

  spec.source       = { :git => "https://github.com/13662049573/TFY_POPControllerKit.git", :tag => spec.version }

  spec.source_files  = "TFY_POPControllerKit/TFY_PopController/**/*.{h,m}"
  
  spec.frameworks    = "Foundation","UIKit"

  spec.xcconfig      = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/AvailabilityMacros" }

  spec.requires_arc  = true
  

end
