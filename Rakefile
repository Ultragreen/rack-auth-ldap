require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'version'
require 'rake/version_task'
require 'code_statistics'
require 'yard'
require 'yard/rake/yardoc_task'
require 'rubocop/rake_task'

require 'rubocop/rake_task'

RuboCop::RakeTask.new

Rake::VersionTask.new

CLEAN.include('*.tmp', '*.old')
CLOBBER.include('*.tmp', 'build/*', '#*#')

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb', '-', 'doc/**/*', 'spec/**/*_spec.rb']
  t.options += ['-o', 'yardoc']
end

YARD::Config.load_plugin('yard-rspec')

namespace :yardoc do
  task :clobber do
    begin
      rm_r 'yardoc'
    rescue StandardError
      nil
    end
    begin
      rm_r '.yardoc'
    rescue StandardError
      nil
    end
  end
end
task clobber: 'yardoc:clobber'

task default: [:spec]

task :stage do
  Rake::Task['clean'].invoke
  Rake::Task['clobber'].invoke
  Rake::Task['install'].invoke
end

desc 'Run CVE security audit over bundle'
task :audit do
  system('bundle audit')
end

desc 'Run dead line of code detection'
task :debride do
  system('debride -w .debride-whitelist .')
end

desc 'Run SBOM CycloneDX Xml format file'
task :sbom do
  system('cyclonedx-ruby -p .')
end
