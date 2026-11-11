/*
:name: test_memory_relocation_map_units_1_0_104
:description: Memory relocation preserves map address units location offsets and independent interface mappings
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.3.3 18.6.4.15 18.6.4.16 18.6.3.1 18.6.3.2 18.2.3.4 18.2.4.4 18.2.4.6 18.2.4.16 18.2.4.18 18.1.2.3 18.1.2.4 18.1.2.5 18.1.2.6 1800-2023 6.21 8.13 8.16
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers104_relocation/relocation104.svh
:expected_exit: 0
:expected_stdout: @test_memory_relocation_map_units_1_0_104.expected
*/
// What it checks:
// 1. A memory location offset reflects the selected location index within its
//    map.
// 2. Memory set_offset interprets the new offset in the selected map address
//    units.
// 3. Relocating a memory in one address map preserves its other interface and
//    unrelated peer until each is explicitly changed.
//
// Variant: Profile 1 uses a 4-byte bus and a 64-bit memory of 5 locations.
// Input 0 makes the second map byte-addressed and creates it first; input 1
// makes the first map byte-addressed and creates it first; the expected
// address step of the first map follows its addressing unit.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.6.4.15 (UVM-MEMORY-LOCATION-OFFSET) gives rule 1 above.
//    Setup: A 16-bit memory starts at offset 0x20 on a byte-addressed map with
//    base 0x100. Retain that original case,and additionally use locked shared
//    16/64-bit memories in flat byte/word maps with nonzero root bases and
//    completed selected-map/peer relocation and restoration;observe locations
//    0,1,and the last configured index. Expected: Selected locations yield
//    offsets 0x20, 0x22, 0x26 and addresses 0x120, 0x122, 0x126. In the
//    additional profiles,each local location offset equals its current map
//    start plus index times the integral location stride in that map's
//    units;external addresses add the declared root base. Original and new
//    expectations remain when a combination differs.
// 2. 1800.2-2020 18.6.3.3 (UVM-MEMORY-RELOCATION-ADDRESS-UNITS-104) gives rule
//    2 above. Setup: Relocate a locked shared memory through first,next,last
//    and restored local starts in one flat byte- or word-addressed interface
//    with nonzero root base. Use 16-bit/two-byte and 64-bit/four-byte bus
//    profiles with first,middle,last locations. Expected: The selected
//    base-offset query follows the supplied map-unit start,and external
//    location addresses equal the declared root base plus that start and the
//    location stride in those units. Both map unit getters retain their
//    configured flat byte/word units.
// 3. 1800.2-2020 18.6.3.3
//    (UVM-MEMORY-RELOCATION-INTERFACE-AND-PEER-ISOLATION-104) gives rule 3
//    above. Setup: Configure chosen and peer memories in two owned root maps
//    with different address units and distinct offsets. Move chosen only in
//    the selected map,move the peer into the vacated range,move chosen
//    again,then restore both selected starts. Expected: The alternate
//    interface retains its base and all observed location addresses
//    throughout;the selected peer start changes only on its own set_offset
//    call. Restoring selected starts recovers their original address relations
//    without rewriting the other interface.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_memory_relocation_map_units_1_0_104;
  import uvm_pkg::*;
  localparam int SHAPE104=1,BUS104=4,WIDTH104=64,SIZE104=5;
  localparam bit BYTEA104=0;
  localparam int STRIDEA104=2;
  localparam uvm_reg_addr_t BASEA104='h500;
  localparam uvm_reg_addr_t BASEB104='h900;
  localparam uvm_reg_addr_t FIRST104='h50;
  localparam uvm_reg_addr_t NEXT104='h110;
  localparam uvm_reg_addr_t LAST104='h210;
  localparam uvm_reg_addr_t HOME104='h410;
  localparam uvm_reg_addr_t ALT104='h620;
  localparam uvm_reg_addr_t ALTHOME104='h820;
  `include "relocation104.svh"
endmodule
