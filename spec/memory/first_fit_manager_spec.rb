require 'spec_helper'

describe RubyOS::Memory::FirstFitManager do
  describe "#assign_process_base_address" do
    it "should pick the first available 'hole' in memory" do
      total_memory = 4000
      block_size = 100
      default_limit = block_size
      manager = described_class.new total_memory, block_size, default_limit

      pcb = RubyOS::PCB.new 1, memory_required: 100
      manager.assign_process_base_address(pcb)
      expect(pcb.base_address).to eq 0x0

      # Reserve memory to create a singular
      manager.reserve_memory(450, 1000)

      next_pcb = RubyOS::PCB.new 2, memory_required: 350
      manager.assign_process_base_address(next_pcb)
      expect(next_pcb.base_address).to eq 100

      # The next 'hole' is at 1450, but to test how it handles the search forward
      # we'll make it just too small for the process. But the one after it
      # should be just fine.
      manager.reserve_memory(1450 + 99, 150)

      last_pcb = RubyOS::PCB.new 3, memory_required: 100
      manager.assign_process_base_address(last_pcb)

      # We expect that the first 'hole' will be skipped since it was not large
      # enough.
      expect(last_pcb.base_address).to eq (1450 + 99 + 150)
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
