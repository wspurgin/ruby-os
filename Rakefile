require "bundler/gem_tasks"
require 'rspec/core/rake_task'

task :default => :rspec

RSpec::Core::RakeTask.new(":spec") do |t|
      t.pattern = 'spec/**/*_spec.rb'
end

desc 'Run full test suite'
task :rspec => :spec
