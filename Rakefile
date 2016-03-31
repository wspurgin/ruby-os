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
  next_pid = 1
  File.open(t.name, "w") do |data|
    args.n.times do
      address = rand(100).to_s(16)
      state = states.sample
      priority = priority_range.sample
      remaining_processing_time = remaining_processing_time_range.sample
      data.puts "#{next_pid}, 0x#{address}, #{state}, priority:#{priority}, remaining_processing_time:#{remaining_processing_time}"
      next_pid += 1
    end
  end
  puts "Generate file #{t.name}"
end
