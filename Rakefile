require "bundler/gem_tasks"
require 'rubygems'
require 'rspec'
require 'rake'
require "rake/clean"
require "rubygems/package_task"
require "rdoc/task"
require 'code_statistics'
require 'rspec/core/rake_task'
require 'yard'
require 'yard/rake/yardoc_task.rb'
require "rake/tasklib"
require "roodi"
require "roodi_task"


RoodiTask.new() do | t |
t.patterns = %w(lib/**/*.rb)
end


CLEAN.include('*.tmp','*.old')
CLOBBER.include('*.tmp', 'build/*','#*#')


content = File::readlines(File.join(File.dirname(__FILE__), 'rack-auth-ldap.gemspec')).join
spec = eval(content)

RSpec::Core::RakeTask.new('spec')

YARD::Rake::YardocTask.new do |t|
  t.files   = [ 'lib/**/*.rb', '-', 'doc/**/*','spec/**/*_spec.rb']
  t.options += ['--title', "Gem Documentation"]
  t.options += ['-o', "yardoc"]
end

YARD::Config.load_plugin('yard-rspec')

namespace :yardoc do
  task :clobber do
    rm_r "yardoc" rescue nil
    rm_r ".yardoc" rescue nil
  end
end
task :clobber => "yardoc:clobber"


Gem::PackageTask.new(spec) do |pkg|
  pkg.need_tar = true
  pkg.need_zip = true
end

Rake::RDocTask.new('rdoc') do |d|
  d.rdoc_files.include('doc/**/*','bin/*')
  d.title = 'Dorsal : Yard'
  d.options << '--line-numbers' << '--diagram' << '-SHN'
end

task :default => [:gem]