# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'motive_model/version'

Gem::Specification.new do |spec|
  spec.name          = 'motive_model'
  spec.version       = MotiveModel::VERSION
  spec.authors       = ['kayhide']
  spec.email         = ['kayhide@gmail.com']

  spec.summary       = 'ActiveModel for RubyMotion.'
  spec.description   = 'ActiveModel for RubyMotion. Directly importing original implementations using MotionBlender.'
  spec.homepage      = 'https://github.com/kayhide/motive_model'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'motion_blender'
  spec.add_runtime_dependency 'motive_support'
  spec.add_runtime_dependency 'activemodel', '~> 4.2'
  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-doc'
  spec.add_development_dependency 'motion-redgreen'
  spec.add_development_dependency 'motion-stump'
end
