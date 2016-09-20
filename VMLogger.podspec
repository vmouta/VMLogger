Pod::Spec.new do |s|
    s.name             = "VMLogger"
    s.version          = "0.3.2"
    s.summary          = "A simple debug log BackLog kind Logger."
    s.description      = <<-DESC
                        Provides an extensible Swift-based logging API that is simple, lightweight and performant.
                        Based on CleanroomLogger and XCGLogger
                       DESC

    s.homepage         = "https://github.com/vmouta/VMLogger"
    s.license          = { :type => "MIT", :file => "LICENSE" }
    s.author           = { "Vasco Mouta" => "vasco.mouta@gmail.com" }
    s.source           = { :git => "https://github.com/vmouta/VMLogger.git", :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/vmouta'

    s.platform     = :ios, '8.0'
    s.requires_arc = true

    s.source_files = 'Pod/Classes/**/*'

    s.framework  = "Foundation"
    s.dependency 'Alamofire'
end
pod repo push vmouta-specs VMLogger.podspec
2310  git tag -d '0.3.0'
2311  git push origin :refs/tags/0.3.0
2312  git add -A && git commit -m "assignment to _"
2313  git push
2314  git tag '0.3.0'
2315  git push --tags
2316  pod repo push zucred VMLogger.podspec
2317  pod repo push zucred VMLogger.podspec
2318  pod repo push vmouta-specs VMLogger.podspec