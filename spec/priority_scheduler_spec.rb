require 'spec_helper'

describe RubyOS::PriorityScheduler do
  describe "#new" do
    it "takes an optional array of arguments to specify sort order" do
      manager = RubyOS::QueueManager.new
      options = { priority_sort_order: :desc }
      scheduler = described_class.new manager, options
      expect(scheduler.options).to eq options
    end
  end

  describe "#next_proc" do
    before do
      @manager = RubyOS::QueueManager.new
      @manager.add_queue(:ready)
      [1,2,3,4,5,6].each do |pid|
        priority = rand(4) + 1
        @manager[:ready].push RubyOS::PCB.new pid, priority: priority
      end
      @scheduler = described_class.new @manager
    end

    it "should return the next PCB with highest priority" do
      # NOTE by default, the higher priority are lower numbers (i.e. ascending)

      # Find lowest priority value (e.g. the highest priority PCB)
      expected_priority = @manager[:ready].min_by(&:priority).priority
      # There might be multiple PIDs with this priority, so depending on the
      # tie breaker, a different, but valid, PID might be returned. So collect
      # all the valid PIDs to expect.
      expected_pids = @manager[:ready]
        .select { |pcb| pcb.priority == expected_priority }
        .map(&:pid)
      actual_proc = @scheduler.next_proc :ready
      expect(actual_proc).to be_a(RubyOS::PCB)
      expect(actual_proc.priority).to eq expected_priority
      expect(expected_pids).to include(actual_proc.pid)
    end

    context "the given `current_proc` has a higher (or equal) priority" do
      it "should return the curent PCB" do
        current_proc = RubyOS::PCB.new 18493, priority: 1
        expect(@scheduler.next_proc :ready, current_proc).to eq current_proc
      end
    end

    context "the identified queue is empty" do
      it "should return the current proc input" do
        current_proc = RubyOS::PCB.new 18493, priority: 1
        # add a new empty queue.
        @manager.add_queue(:test)
        expect(@scheduler.next_proc :test, current_proc).to eq current_proc
      end

      it "should return nil if no current_proc is given" do
        # add a new empty queue.
        @manager.add_queue(:test)
        expect(@scheduler.next_proc :test).to be_nil
      end
    end
  end
end
