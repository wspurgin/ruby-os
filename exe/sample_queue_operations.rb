#!/usr/bin/env ruby

begin
  require 'ruby-os'
rescue LoadError
  lib = File.expand_path('../../lib', __FILE__)
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
  retry
end

class SampleRunner
  attr_accessor :ready_queue, :waiting_queue

  def self.run
    self.new.run
  end

  def initialize
    @ready_queue = RubyOS::Queue.new
    @waiting_queue = RubyOS::Queue.new
  end

  def run
    procs = if ARGV.count > 0
              file = ARGV[0]
              read_input_file(file)
            else
              []
            end

    puts "Initializing testing Queues"
    print_queues

    procs.each_with_index do |pcb, i|
      case pcb.state
      when "ready"
        ready_queue.push pcb
      when "waiting"
        waiting_queue.push pcb
      else
        puts "Unrecognized state: '#{pcb.state}'. Using 'ready' by default"
        pcb.update_state('ready')
        ready_queue.push pcb
      end
      if i % 2
        print_queues
      end
    end

    puts "This is a sample program for adding and removing process from queues."
    loop do
      res = ask_user_input
      break if !handle(res)
    end
  end

  def read_input_file(file)
    procs = []
    File.open(file, 'r') do |input|
      pcb_strings = input.readlines
      procs = pcb_strings.map do |pcb_string|
        pcb_pieces = pcb_string.split(',')
        if pcb_pieces.count < 3
          puts "File PCB input was unrecognized, expected format: pid,execution_address,state[,options], see docs for details."
          next
        end
        pid, pc, state, *option_args = pcb_pieces
        options = {}
        option_args.each do |option_pair|
          option, value = option_pair.split(":")
          if value.nil? || option.nil?
            puts "Option format unrecognized, for #{pcb_string}. See docs for expected format"
            next
          end
          options[option] = value
        end
        options.merge!({ state: state })
        RubyOS::PCB.new(pid, pc, options)
      end
    end
    procs
  rescue IOError => e
    puts e
    return []
  end

  def ask_user_input
    puts "Enter Commands (enter help for usage)"
    $stdout << ">"
    $stdin.gets.chomp
  end

  def handle(cmd)
    case cmd
    when "help"
      print_usage
    when "add_proc"
      add_proc_interactively
    when "delete_proc"
      delete_proc_interactively
    when "show_queues"
      print_queues
    when "exit", "quit"
      return false
    else
      puts "Unknown Command"
      print_usage
    end
  end

  def print_queues
    puts "Ready Queue: #{ready_queue}"
    puts "Waiting Queue: #{waiting_queue}"
    true
  end

  def print_usage
    puts "The following are the accepted commands:"
    puts "help        - prints this usuage guide"
    puts "add_proc    - interactively adds a process to a queue"
    puts "delete_proc - interactively remove a process from a queue"
    puts "show_queues - prints queues to STDOUT"
    puts "exit        - quits the program"
    puts "quit        - alias for exit"
    true
  end

  def add_proc_interactively
    pid = 0
    addr = 0x0
    state = "ready"
    queue = nil

    puts "Enter process id"
    begin
      print ">"
      pid = Integer($stdin.gets.chomp)
    rescue ArgumentError
      puts "Value entered is not an integer, please enter integer value"
      retry
    end

    puts "Enter starting address (e.g. 0x2) (hit enter to use default)"
    begin
      print ">"
      ans = $stdin.gets.chomp
      addr = Integer(ans) if !ans.empty?
    rescue ArgumentError
      puts "Value entered is not an integer, please enter integer value"
      retry
    end

    puts "Which queue do you want to add the process to? ('waiting', or 'ready')"
    begin
      print ">"
      state = $stdin.gets.chomp
      case state
      when /w(aiting)?/i
        state = "waiting"
        queue = waiting_queue
      when /r(eady)?/i
        state = "ready"
        queue = ready_queue
      else
        raise ArgumentError.new "state must be either 'ready' or 'waiting'"
      end
    rescue
      puts "Unrecognized queue '#{state}', please enter a valid queue (ready,waiting)"
      retry
    end

    pcb = RubyOS::PCB.new(pid, addr, state: state)
    puts "Enter the position you wish to insert the process (hit enter to use the default location)"
    begin
      print ">"
      pos = $stdin.gets.chomp
      pos = if pos.empty?
              nil
            else
              Integer(pos)
            end
      queue.push(pcb, pos)
    rescue ArgumentError
      puts "Value entered is not an integer, please enter integer value"
      retry
    end

    print_queues
    true
  end

  def delete_proc_interactively
    queue = nil

    puts "Which queue do you want to add the process to? ('waiting', or 'ready')"
    begin
      print ">"
      state = $stdin.gets.chomp
      case state
      when /w(aiting)?/i
        state = "waiting"
        queue = waiting_queue
      when /r(eady)?/i
        state = "ready"
        queue = ready_queue
      else
        raise ArgumentError.new "state must be either 'ready' or 'waiting'"
      end
    rescue
      puts "Unrecognized queue '#{state}', please enter a valid queue (ready,waiting)"
      retry
    end

    # pcb = nil
    puts "Enter the PID of the process you wish to remove (hit enter to use the default location)"
    begin
      print ">"
      pos = $stdin.gets.chomp
      pos = if pos.empty?
              nil
            else
              Integer(pos)
            end
      pcb = queue.pop(pos)
    rescue ArgumentError
      puts "Value entered is not an integer, please enter integer value"
      retry
    end

    if pcb.nil?
      puts "No process was removed (possible gave a PID that didn't exist?)"
    else
      puts "Remove process: #{pcb}"
    end

    print_queues
    true
  end

end

SampleRunner.run
