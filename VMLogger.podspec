Pod::Spec.new do |s|
    s.name             = "VMLogger"
    s.version          = "0.5.2"
    s.summary          = "A simple debug log, BackLog kind Logger."
    s.description      = <<-DESC
                        Provides an extensible Swift-based logging API that is simple, lightweight and performant.
                        Based on CleanroomLogger and XCGLogger
                       DESC

    s.homepage         = "https://github.com/vmouta/VMLogger"
    s.license          = { :type => "MIT", :file => "LICENSE" }
    s.author           = { "Vasco Mouta" => "vasco.mouta@gmail.com" }
    s.source           = { :git => "https://github.com/vmouta/VMLogger.git", :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/vmouta'

    s.ios.deployment_target     = '8.0'
    s.osx.deployment_target     = '10.10'
    s.watchos.deployment_target = '2.0'
    s.tvos.deployment_target    = '9.0'

    s.requires_arc = true

    s.source_files = 'Pod/Classes/**/*'

    s.framework  = "Foundation"
    s.dependency 'Alamofire' , '~> 4.2.0'
end
