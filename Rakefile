require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

task :gem => :build

task :build do
  system 'gem build mongoid_listable.gemspec'
end

RSpec::Core::RakeTask.new :spec

task :default => :spec
