/*
:name: test_map_populated_word_addressing_separates_effective_bus_width_from_local_address_units
:description: populated word map separates effective bus width from local address units
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.4.6 18.2.4.5 18.2.3.5 18.1.2.3 18.1.2.6 18.1.2.2 18.2.3.3 18.4.2.2 18.5.3.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_map_populated_word_addressing_separates_effective_bus_width_from_local_address_units.expected
*/
// Qualified word-unit reading: get_n_bytes has a declared HIER default.
// The populated control separately requires the narrowest physical bus width.
module test_map_populated_word_addressing_separates_effective_bus_width_from_local_address_units;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name);super.new(name,UVM_NO_COVERAGE);endfunction
  endclass
  class register_type extends uvm_reg;
    function new();super.new("r51",64,UVM_NO_COVERAGE);endfunction
  endclass
  initial begin
    automatic block_type root=new("root51");
    automatic block_type child=new("child51");
    automatic register_type rg=new();
    automatic uvm_reg_field bits_value=new("bits51");
    uvm_reg_map outer,inner;
    root.configure();child.configure(root);rg.configure(child);
    bits_value.configure(rg,64,0,"RW",0,0,1,0,0);
    outer=root.create_map("outer51",0,2,UVM_LITTLE_ENDIAN,1);
    inner=child.create_map("inner51",0,8,UVM_LITTLE_ENDIAN,0);
    inner.add_reg(rg,0);outer.add_submap(inner,'h40);root.lock_model();
    $display("UT: populated_unit local_width %0d effective_width %0d parent_width %0d",
      inner.get_n_bytes(UVM_NO_HIER),inner.get_n_bytes(),outer.get_n_bytes());
    $display("UT: populated_unit printed_get_n_bytes_relation %0d word_unit %0d",
      inner.get_addr_unit_bytes()==inner.get_n_bytes(),inner.get_addr_unit_bytes());
    $finish;
  end
endmodule
