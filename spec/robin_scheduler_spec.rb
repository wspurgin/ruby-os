require 'spec_helper'

describe RubyOS::RobinScheduler do
  describe "#next_proc" do
    before do
      @manager = RubyOS::QueueManager.new
      @manager.add_queue(:ready)
      [1,2,3,4,5,6].each do |pid|
        @manager[:ready].push RubyOS::PCB.new pid
      end
      @q = 2
      @scheduler = described_class.new @manager, @q
    end

    it "should return the current_proc if the time share is not over" do
      current_proc = RubyOS::PCB.new 2931
      expect(@scheduler.next_proc :ready, current_proc).to eq current_proc
    end

    context "there is no current_proc" do
      it "should return the next proc in the queue and reset the timer" do
        expected_proc =  @manager[:ready].first
        expect(@scheduler.next_proc :ready).to eq expected_proc
        expect(@scheduler.timer).to eq @q
      end
    end

    context "the current_proc is still in the CPU and the timer share runs out" do
      it "should return the next proc and reset the timer" do
        current_proc = RubyOS::PCB.new 2931
        expected_proc =  @manager[:ready].first

        # run the scheduler once to get the run the timer down
        @scheduler.next_proc :ready, current_proc
        expect(@scheduler.next_proc :ready, current_proc).to eq expected_proc
      end
    end
  end
end
