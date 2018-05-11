Pod::Spec.new do |s|

  s.name         = "MGCrashManagerSwift"
  s.version      = "0.0.1"
  s.summary      = "Crash日誌蒐集"

  s.description  = <<-DESC
                   管理Crash日誌(蒐集/讀取/刪除)
                   DESC

  s.homepage     = "https://github.com/CrazyDavis/MGCrashManagerSwift"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "water" => "crazydennies@gmail.com" }

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/CrazyDavis/MGCrashManagerSwift.git", :tag => "#{s.version}" }

  s.source_files  = "MGCrashManagerSwift/MGCrashManagerSwift/Classes/*"

  # s.framework  = "SomeFramework"

  s.dependency 'MGUtilsSwift'

end
