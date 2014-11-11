Gem::Specification.new do |spec|
  spec.name        = 'trello-pipes'
  spec.version     = '1.0.3'
  spec.summary     = "Pipes and filters for trello board data"
  spec.authors     = ["iainjmitchell"]
  spec.email       = 'iainjmitchell@gmail.com'
  spec.files       = Dir.glob("lib/**/*")
  spec.homepage    = 'https://github.com/iainjmitchell/trello-pipes'
  spec.license       = 'MIT'
  spec.add_runtime_dependency 'ruby-trello' 
  spec.add_runtime_dependency 'trello-factory'
end