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
