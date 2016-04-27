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

  describe "#assign_process_base_address" do
    it "should ensure the argument is a RubyOS::PCB" do
      size = 10
      manager = described_class.new(size, 1, 1)
      expect { manager.assign_process_base_address(:not_a_process) }.to raise_error(ArgumentError)
    end

    it "should ensure that the given process does not already have a base_address set" do
      size = 10
      manager = described_class.new(size, 1, 1)
      pcb = RubyOS::PCB.new 1, base_address: 0x10, memory_required: 0xF
      expect { manager.assign_process_base_address pcb }.to raise_error RubyOS::Memory::Error
    end
  end

  describe "#reserve!" do
    it "should change the memory map to mark all addresses as reserved" do
      size = 10
      manager = described_class.new(size, 1, 1)
      expect(manager).to respond_to(:reserve!)
      manager.reserve!
      expect(manager.memory_map.values).to contain_exactly( *([described_class::RESERVED]*size) )
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
      expect(manager.memory_map.values).to contain_exactly( *([described_class::FREE]*size) )
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

  describe "#find_hole" do
    it "should find the first hole above the given address" do
      total_memory = 4096
      block_size = 256
      default_proc_memory_limit = 256

      manager = described_class.new(total_memory, block_size, default_proc_memory_limit)

      manager.reserve! # reserve all addresses

      # make two holes, one below, and one above
      manager.free_memory(0, 20)
      manager.free_memory(150, 400)

      hole = manager.find_hole(100)
      expect(hole).not_to be_nil
      expect(hole).to have_key(:base_address)
      expect(hole).to have_key(:end_address)
      expect(hole).to have_key(:mem_available)

      expect(hole[:base_address]).to eq 150
      expect(hole[:mem_available]).to eq 400
      expect(hole[:end_address]).to eq 550
    end

    context "No memory is reserved" do
      it "should pick the starting address" do
        total_memory = 4096
        block_size = 256
        default_proc_memory_limit = 256

        manager = described_class.new(total_memory, block_size, default_proc_memory_limit)

        hole = manager.find_hole
        expect(hole).not_to be_nil
        expect(hole).to have_key(:base_address)
        expect(hole).to have_key(:end_address)
        expect(hole).to have_key(:mem_available)

        expect(hole[:base_address]).to eq 0
        expect(hole[:mem_available]).to eq 4096
        expect(hole[:end_address]).to eq 4096
      end
    end
  end

  describe "#external_fragmentation_total" do
    it "should equal the total available memory if there are two or more holes" do
      total_memory = 4096
      block_size = 256
      default_proc_memory_limit = 256

      manager = described_class.new(total_memory, block_size, default_proc_memory_limit)

      manager.reserve!

      # make two holes, one below, and one above
      manager.free_memory(0, 20)
      manager.free_memory(150, 400)
      expect(manager.external_fragmentation_total).to eq 420
      expect(manager.external_fragmentation_total).to eq manager.total_available_memory
    end

    it "should equal 0 if there's only one hole in memory" do
      total_memory = 4096
      block_size = 256
      default_proc_memory_limit = 256

      manager = described_class.new(total_memory, block_size, default_proc_memory_limit)

      manager.reserve!

      # make two holes, one below, and one above
      manager.free_memory(150, 400)
      expect(manager.external_fragmentation_total).to eq 0
      expect(manager.external_fragmentation_total).not_to eq manager.total_available_memory
    end
  end

end
