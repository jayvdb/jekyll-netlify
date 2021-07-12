lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jekyll/netlify/version'

Gem::Specification.new do |spec|
  spec.name          = 'jekyll-netlify'
  spec.version       = Jekyll::Netlify::VERSION
  spec.authors       = ['John Vandenberg']
  spec.email         = ['jayvdb@gmail.com']
  spec.summary       = 'Netlify metadata for Jekyll.'
  spec.description   = 'Access Netlify environment values in Jekyll templates'
  spec.homepage      = 'https://github.com/jayvdb/jekyll-netlify'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'jekyll', '~> 3.0'

  spec.add_development_dependency 'bundler', '>= 2.2.10'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop', '~> 0.41'
  spec.add_development_dependency 'shoulda'
end
