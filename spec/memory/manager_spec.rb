require 'spec_helper'

describe RubyOS::Memory::Manager do
  describe "#initialize" do
    it "should require 3 arguements" do
      intialize_method = described_class.instance_method(:initialize)
      expect(intialize_method.arity).to eq(3) # i.e. has 3 rquired args
    end

    it "should set the instance attributes for memory metrics" do
      total_memory = 4096
      block_size = 256
      default_proc_memory_limit = 256

      manager = described_class.new(total_memory, block_size, default_proc_memory_limit)
      expect(manager).to respond_to(:total_memory)
      expect(manager).to respond_to(:block_size)
      expect(manager).to respond_to(:default_proc_memory_limit)
      expect(manager).to respond_to(:highest_address)
      expect(manager).to respond_to(:memory_map)
      expect(manager.total_memory).to eq total_memory
      expect(manager.block_size).to eq block_size
      expect(manager.default_proc_memory_limit).to eq default_proc_memory_limit
      expect(manager.highest_address).to eq total_memory - 1
      (0..manager.highest_address).each do |addr|
        expect(manager.memory_map).to have_key(addr)
      end
    end
  end

  describe "#reserve!" do
    it "should change the memory map to mark all addresses as reserved" do
      size = 10
      manager = described_class.new(size, 1, 1)
      expect(manager).to respond_to(:reserve!)
      manager.reserve!
      expect(manager.memory_map.values).to contain_exactly( *([described_class::RESERVED]*10) )
    end
  end

  describe "#free!" do
    it "should change the memory map to mark all addresses as reserved" do
      size = 10
      manager = described_class.new(size, 1, 1)
      expect(manager).to respond_to(:reserve!) # for this test
      expect(manager).to respond_to(:free!)
      manager.reserve! # make everything reserved first

      manager.free!
      expect(manager.memory_map.values).to contain_exactly( *([described_class::FREE]*10) )
    end
  end

  describe "#free_memory" do
    it "should check that the base address is an addressable bound" do
      total_memory = 4096
      block_size = 256
      default_proc_memory_limit = 256

      manager = described_class.new(total_memory, block_size, default_proc_memory_limit)
      expect { manager.free_memory(-1, 30) }.to raise_error(RubyOS::Memory::OutOfBoundsAssignment)
      expect { manager.free_memory(5000, 10) }.to raise_error(RubyOS::Memory::OutOfBoundsAssignment)
      expect { manager.free_memory(4000, 100) }.to raise_error(RubyOS::Memory::OutOfBoundsAssignment)
    end

    it "should 'free' the memory associated with that address space" do
      total_memory = 4096
      block_size = 256
      default_proc_memory_limit = 256

      manager = described_class.new(total_memory, block_size, default_proc_memory_limit)
      manager.reserve!
      expect { manager.free_memory(0, 1) }.to change { manager.memory_map[0] }
        .from(described_class::RESERVED).to(described_class::FREE)

      manager.free_memory(100, 450)
      memory = manager.memory_map.select { |addr, _| (100..549).include? addr }
      expect(memory.values).to contain_exactly( *([described_class::FREE]*450) )
    end
  end

  describe "#reserve_memory" do
    it "should check that the base address is an addressable bound" do
      total_memory = 4096
      block_size = 256
      default_proc_memory_limit = 256

      manager = described_class.new(total_memory, block_size, default_proc_memory_limit)
      expect { manager.reserve_memory(-1, 30) }.to raise_error(RubyOS::Memory::OutOfBoundsAssignment)
      expect { manager.reserve_memory(5000, 10) }.to raise_error(RubyOS::Memory::OutOfBoundsAssignment)
      expect { manager.reserve_memory(4000, 100) }.to raise_error(RubyOS::Memory::OutOfBoundsAssignment)
    end

    it "should ensure that the memory being reserved is not already reserved" do
      total_memory = 4096
      block_size = 256
      default_proc_memory_limit = 256

      manager = described_class.new(total_memory, block_size, default_proc_memory_limit)
      manager.reserve!
      expect { manager.reserve_memory(0, 10) }.to raise_error(RubyOS::Memory::AssignmentError)
    end

    it "should 'reserve' the memory associated with that address space" do
      total_memory = 4096
      block_size = 256
      default_proc_memory_limit = 256

      manager = described_class.new(total_memory, block_size, default_proc_memory_limit)
      manager.free! # ensure all addresses are free

      expect { manager.reserve_memory(0, 1) }.to change { manager.memory_map[0] }
        .from(described_class::FREE).to(described_class::RESERVED)

      manager.reserve_memory(100, 450)
      memory = manager.memory_map.select { |addr, _| (100..549).include? addr }
      expect(memory.values).to contain_exactly( *([described_class::RESERVED]*450) )
    end
  end

end
