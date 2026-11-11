/*
:name: test_memory_direct_construction_defaults_and_explicit_rom_keep_distinct_configuration
:description: Direct concrete memory construction preserves mandatory dimensions and RW/no-coverage defaults
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.1 18.6.3.1 18.6.3.2 18.6.4.1 18.6.4.6 18.6.4.7 18.6.4.8 18.6.4.9 18.6.8.3 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_direct_construction_defaults_and_explicit_rom_keep_distinct_configuration.expected
*/
// What it checks:
// 1. uvm_mem can be directly constructed and used as uvm_object.
// 2. Memory construction retains the selected name, location count and
//    per-location width.
// 3. Omitting the memory access argument selects RW.
// 4. Omitting memory coverage does not supply the selected coverage models.
// 5. configure associates the selected memory with its parent block.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.6.1 (UVM-MEMORY-AUDIT-CONCRETE-OBJECT) gives rule 1 above.
//    Setup: Two concrete memories use mandatory name/size/width arguments; RAM
//    omits access/coverage and ROM supplies RO, then both are configured in
//    one block/map. Expected: Construction succeeds; the object view is the
//    same handle.
// 2. 1800.2-2020 18.6.3.1 (UVM-MEMORY-AUDIT-CONSTRUCTOR-DIMENSIONS) gives rule
//    2 above. Setup: Two concrete memories use mandatory name/size/width
//    arguments; RAM omits access/coverage and ROM supplies RO, then both are
//    configured in one block/map. Expected: The RAM is named ram56 with seven
//    13-bit/two-byte locations; ROM has nine 24-bit/three-byte locations.
// 3. 1800.2-2020 18.6.3.1 (UVM-MEMORY-AUDIT-DEFAULT-RW) gives rule 3 above.
//    Setup: Two concrete memories use mandatory name/size/width arguments; RAM
//    omits access/coverage and ROM supplies RO, then both are configured in
//    one block/map. Expected: The unrestricted RAM map query reports RW while
//    the explicit ROM reports RO.
// 4. 1800.2-2020 18.6.3.1 (UVM-MEMORY-AUDIT-DEFAULT-NO-COVERAGE) gives rule 4
//    above. Setup: Two concrete memories use mandatory name/size/width
//    arguments; RAM omits access/coverage and ROM supplies RO, then both are
//    configured in one block/map. Expected: ADDR_MAP, REG_BITS and FIELD_VALS
//    are each absent in the omitted-coverage RAM.
// 5. 1800.2-2020 18.6.3.2 (UVM-MEMORY-AUDIT-CONFIGURED-PARENT) gives rule 5
//    above. Setup: Two concrete memories use mandatory name/size/width
//    arguments; RAM omits access/coverage and ROM supplies RO, then both are
//    configured in one block/map. Expected: The parent query returns the
//    supplied owner.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_memory_direct_construction_defaults_and_explicit_rom_keep_distinct_configuration;
  import uvm_pkg::*;

  class block_type extends uvm_reg_block;
    function new(string name="owner56"); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass

  initial begin
    automatic block_type owner=new();
    automatic uvm_mem ram=new("ram56",7,13);
    automatic uvm_mem rom=new("rom56",9,24,"RO");
    automatic uvm_object object_view=ram;
    uvm_reg_map mapping;
    owner.configure(); ram.configure(owner); rom.configure(owner);
    mapping=owner.create_map("bus56",0,4,UVM_LITTLE_ENDIAN);
    mapping.add_mem(ram,'h20); mapping.add_mem(rom,'h80); owner.lock_model();
    $display("UT: concrete name %0d object %0d parent %0d",
      ram.get_name()=="ram56",object_view==ram,ram.get_parent()==owner);
    $display("UT: defaults locations %0d bits %0d bytes %0d rw %0d no_models %0d",
      ram.get_size(),ram.get_n_bits(),ram.get_n_bytes(),ram.get_access(mapping)=="RW",
      !ram.has_coverage(UVM_CVR_ADDR_MAP) && !ram.has_coverage(UVM_CVR_REG_BITS) &&
      !ram.has_coverage(UVM_CVR_FIELD_VALS));
    $display("UT: rom locations %0d bits %0d bytes %0d ro %0d separate %0d",
      rom.get_size(),rom.get_n_bits(),rom.get_n_bytes(),rom.get_access(mapping)=="RO",rom!=ram);
    $finish;
  end
endmodule
