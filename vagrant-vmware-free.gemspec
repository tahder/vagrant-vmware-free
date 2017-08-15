Gem::Specification.new do |g|
  g.name = 'vagrant-vmware-free'
  g.version = '0.1.0'
  g.platform = Gem::Platform::RUBY
  g.license = 'MIT'
  g.authors = 'Ori Shavit'
  g.email = 'ori@orishavit.com'
  g.homepage = 'http://orishavit.com'
  g.summary = 'A free VMWare Workstaion/Fusion Vagrant provider'
  g.description = 'A free VMWare Workstaion/Fusion Vagrant provider'

  g.add_runtime_dependency 'CFPropertyList', '~> 2.0'
  g.add_runtime_dependency 'ffi',  '~> 1.9', '>= 1.9.3'
  g.add_development_dependency 'rake', '~> 0'
  g.add_development_dependency 'pry', '~> 0'
  g.add_development_dependency 'debugger', '~> 0'

  g.files = `git ls-files`.split("\n")
  g.require_path = 'lib'

end
