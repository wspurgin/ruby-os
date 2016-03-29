require 'spec_helper'

describe RubyOS::QueueManager do
  describe "#new" do
    it "should accept a Hash of keys to RubyOS::Queue values" do
      mapped_queues = { ready: RubyOS::Queue.new, waiting: RubyOS::Queue.new }
      manager = described_class.new mapped_queues
      expect(manager.mapped_queues).to eq(mapped_queues)
    end

    it "should raise ArgumentError like errors when the input is not a Hash of queues" do
      expect { described_class.new([1, 382, 10293, 392])}.to raise_error(ArgumentError)
      expect { described_class.new({ ready: "queue", waiting: "not a q" })}.to raise_error(ArgumentError)
    end
  end

  describe "#add_queue" do
    it "should add a new empty queue mapped to the given queue identifier" do
      manager = described_class.new
      state = :ready
      manager.add_queue(state)
      expect(manager.mapped_queues).to have_key(state)
      expect(manager.mapped_queues[state]).to be_a(RubyOS::Queue)
      expect(manager.mapped_queues[state]).to be_empty
    end

    it "should add the given queue mapped to the given queue identifier" do
      manager = described_class.new
      state = :ready
      queue = RubyOS::Queue.new [1, 2, 3, 4]
      manager.add_queue(state, queue)
      expect(manager.mapped_queues[state]).to eq queue
    end

    it "should raise an ArgumentError like error if the given queue is not a RubyOS::Queue" do
      manager = described_class.new
      expect { manager.add_queue(:ready, []) }.to raise_error(ArgumentError)
    end
  end

  describe "#[]" do
    it "should delegate the accessor operator to internal Hash" do
      manager = described_class.new
      state = :ready
      queue = RubyOS::Queue.new [1, 2, 3, 4]
      manager.add_queue(state, queue)
      expect(manager).to respond_to(:[])
      expect(manager[state]).to eq queue
    end
  end
end
