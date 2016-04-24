require 'spec_helper'

describe RubyOS::Queue do
  describe "push" do
    it "adds elements to the queue by default at the tail" do
      # create existing queue
      q = described_class.new([1,2,3])
      q.push 4
      expect(q).to match_array([1,2,3,4])
    end

    it "adds elements to a given index" do
      q = described_class.new([1,2,3])
      q.push(4, 1)
      expect(q).to match_array([1,4,2,3])
    end
  end

  describe "pop" do
    it "removes and retruns elements from the queue by default at the head" do
      q = described_class.new([1,2,3])
      res = q.pop
      expect(q).to match_array([2,3])
      expect(res).to eq(1)
    end

    it "removes and returns an element with the matching the given pid" do
      procs = [ RubyOS::PCB.new(1), RubyOS::PCB.new(2), RubyOS::PCB.new(3)]
      # duplicate procs so that it does not change the existing object
      q = described_class.new(procs.dup)
      res = q.pop(2)
      expect(q).to match_array([procs[0], procs[2]]) # [1, 3]
      expect(res).to eq(procs[1]) # should be <PCB @pid = 2>
    end
  end

  describe "==" do
    it "should delegate it to the internal array" do
      input = [1,2,3,4]
      expect(described_class.new(input)).to eq [1,2,3,4]
      expect(described_class.new(input)).to eq described_class.new(input.dup)
    end
  end
end
