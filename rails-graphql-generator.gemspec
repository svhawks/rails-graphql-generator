$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.licenses    = ['MIT']
  s.name        = 'rails-graphql-generator'
  s.version     = '0.0.2'
  s.authors     = ['Muhammet']
  s.email       = ['dilekmuhammet@gmail.com']
  s.homepage    = 'https://github.com/movielala/rails-graphql-generator'
  s.summary     = %q{A rails generator for GrapphQL.}
  s.description = %q{This generator will put the graphql files input your app folder}
  s.files = Dir.glob('{lib}/**/*')
  s.require_path = 'lib'
  s.add_development_dependency 'rails', '~> 3.2'
end
