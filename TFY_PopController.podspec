
Pod::Spec.new do |spec|

  spec.name         = "TFY_PopController"

  spec.version      = "1.0.5"

  spec.summary      = "控制器弹出框"

  spec.description  = <<-DESC  
  控制器弹出框
                   DESC

  spec.homepage     = "https://github.com/13662049573/TFY_POPControllerKit"
  
  spec.license      = "MIT"
  
  spec.author       = { "田风有" => "420144542@qq.com" }
  
  spec.platform     = :ios, "12.0"

  spec.source       = { :git => "https://github.com/13662049573/TFY_POPControllerKit.git", :tag => spec.version }

  spec.source_files  = "TFY_POPControllerKit/TFY_PopController/TFY_PopControllerKit.h"
   
  spec.subspec 'PopController' do |ss|
     ss.source_files  = "TFY_POPControllerKit/TFY_PopController/PopController/**/*.{h,m}"
  end
  
  spec.subspec 'PopView' do |ss|
     ss.source_files  = "TFY_POPControllerKit/TFY_PopController/PopView/**/*.{h,m}"
  end

  spec.frameworks    = "Foundation","UIKit"

  spec.requires_arc  = true
  

end
