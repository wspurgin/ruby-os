require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new("test:spec") do |t|
      t.pattern = 'spec/**/*_spec.rb'
end

desc 'Run full test suite'
task :default => [ 'test:spec' ]

desc "Creates a csv of `n` test processes to run in ruby-os"
task "test_procs.csv", [:n] do |t, args|
  args.with_defaults(n: 25)
  states = ["ready", "waiting"]
  priority_range = (1..4).to_a
  remaining_processing_time_range = (1..50).to_a
  arrival_time_range = (1..90).to_a
  next_pid = 1
  File.open(t.name, "w") do |data|
    Integer(args.n).times do
      state = states.sample
      priority = priority_range.sample
      remaining_processing_time = remaining_processing_time_range.sample
      arrival_time = arrival_time_range.sample
      memory_required = rand(400)
      data.puts "#{next_pid}, #{state}, priority:#{priority}, remaining_processing_time:#{remaining_processing_time}, arrival_time:#{arrival_time}, memory_required:#{memory_required}"
      next_pid += 1
    end
  end
  puts "Generate file #{t.name}"
end
