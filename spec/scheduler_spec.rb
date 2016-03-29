require 'spec_helper'

describe RubyOS::Scheduler do
  describe "#new" do
    it "should raise an ArgumentError like error if the input is not a RubyOS::QueueManager" do
      expect { described_class.new Array.new }.to raise_error(ArgumentError)
    end
  end
end
