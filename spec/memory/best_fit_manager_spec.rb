require 'spec_helper'

describe RubyOS::Memory::BestFitManager do
  describe "#assign_process_base_address" do
    context "Only one hole in memory" do
      it "should pick the 'hole' when it's large enough" do
        total_memory = 4000
        block_size = 100
        default_limit = block_size
        manager = described_class.new total_memory, block_size, default_limit

        # Fill memory
        manager.reserve!

        # Make only one hole in the middle
        manager.free_memory(1000, 350)

        pcb = RubyOS::PCB.new 1, memory_required: 100
        manager.assign_process_base_address(pcb)
        expect(pcb.base_address).to eq 1000
      end

      it "should return 'NoContiguousMemoryError' if the hole is not large enough" do
        total_memory = 4000
        block_size = 100
        default_limit = block_size
        manager = described_class.new total_memory, block_size, default_limit

        # Fill memory
        manager.reserve!

        # Make only one hole in the middle (which is too small)
        manager.free_memory(1000, 50)

        pcb = RubyOS::PCB.new 1, memory_required: 100
        expect { manager.assign_process_base_address(pcb) }.to raise_error RubyOS::Memory::NoContiguousMemoryError
      end
    end

    context "Two holes (none touching the top edge of the memory map)" do
      it "should pick the smallest, fitted hole" do
        total_memory = 4000
        block_size = 100
        default_limit = block_size
        manager = described_class.new total_memory, block_size, default_limit

        manager.reserve!

        # Make one hole that's farily large
        manager.free_memory(100, 350)

        # Make another hole that's closer to the size requestd
        manager.free_memory(800, 200)

        pcb = RubyOS::PCB.new 2, memory_required: 100
        manager.assign_process_base_address(pcb)
        expect(pcb.base_address).to eq 800
      end
    end

    context "With hole reaching the edge of the memory map" do
      it "should pick the only available hole in memory (even if it reaches the end)" do
        total_memory = 4000
        block_size = 100
        default_limit = block_size
        manager = described_class.new total_memory, block_size, default_limit

        # Make only hole very large, but reach to the end
        manager.reserve_memory(0x0, 200)

        pcb = RubyOS::PCB.new 2, memory_required: 100
        manager.assign_process_base_address(pcb)
        expect(pcb.base_address).to eq 200
      end
    end

    it %Q{should return NoContiguousMemoryError even if the only 'hole'
          available is at the very end of the memory map} do
      total_memory = 4000
      block_size = 100
      default_limit = block_size
      manager = described_class.new total_memory, block_size, default_limit

      # Fill all the memory
      manager.reserve!

      # Free the last 99 bytes
      manager.free_memory(3901, 99)

      pcb = RubyOS::PCB.new 1, memory_required: 100
      expect { manager.assign_process_base_address(pcb) }.to raise_error RubyOS::Memory::NoContiguousMemoryError

      # Now attempt the last hole with another hole in the middle
      manager.free_memory(3870, 20)

      expect { manager.assign_process_base_address(pcb) }.to raise_error RubyOS::Memory::NoContiguousMemoryError
    end

    it "should raise an OutOfMemoryError when there is no free space" do
      total_memory = 4000
      block_size = 100
      default_limit = block_size
      manager = described_class.new total_memory, block_size, default_limit

      # Fill memory
      manager.reserve!

      pcb = RubyOS::PCB.new 1, memory_required: 100
      expect { manager.assign_process_base_address pcb }.to raise_error RubyOS::Memory::OutOfMemoryError
    end

    it %Q{should raise a NoContiguousMemoryError when there is no 'hole' large
          enough for the given process} do
      total_memory = 4000
      block_size = 100
      default_limit = block_size
      manager = described_class.new total_memory, block_size, default_limit

      # Fill memory
      manager.reserve!

      # Create a hole that isn't quite big enough for the process
      manager.free_memory(0x111, 99)

      pcb = RubyOS::PCB.new 1, memory_required: 100
      expect { manager.assign_process_base_address pcb }.to raise_error RubyOS::Memory::NoContiguousMemoryError
    end

  end
end
