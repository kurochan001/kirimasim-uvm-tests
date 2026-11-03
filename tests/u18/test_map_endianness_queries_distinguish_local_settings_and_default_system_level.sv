/*
:name: test_map_endianness_queries_distinguish_local_settings_and_default_system_level
:description: map endianness queries distinguish local settings and default system level
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.4.7 18.2.3.5 18.1.2.3 18.1.2.2 18.1.2.6 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_map_endianness_queries_distinguish_local_settings_and_default_system_level.expected
*/
// Getter metadata only; this fixture does not certify physical beat ordering.
module test_map_endianness_queries_distinguish_local_settings_and_default_system_level;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass

  initial begin
    automatic block_type root=new("root51");
    automatic block_type child=new("child51");
    automatic block_type deep=new("deep51");
    uvm_reg_map outer,inner,leaf;
    root.configure();child.configure(root);deep.configure(child);
    outer=root.create_map("outer51",0,4,UVM_LITTLE_ENDIAN);
    inner=child.create_map("inner51",0,4,UVM_BIG_ENDIAN);
    leaf=deep.create_map("leaf51",0,4,UVM_BIG_FIFO);
    outer.add_submap(inner,'h40);inner.add_submap(leaf,'h20);root.lock_model();
    $display("UT: map_endian local_root %0d local_child %0d local_leaf %0d",
      outer.get_endian(UVM_NO_HIER)==UVM_LITTLE_ENDIAN,
      inner.get_endian(UVM_NO_HIER)==UVM_BIG_ENDIAN,
      leaf.get_endian(UVM_NO_HIER)==UVM_BIG_FIFO);
    $display("UT: map_endian inherited %0d explicit_hier %0d root_stable %0d",
      inner.get_endian()==UVM_LITTLE_ENDIAN && leaf.get_endian()==UVM_LITTLE_ENDIAN,
      leaf.get_endian(UVM_HIER)==UVM_LITTLE_ENDIAN,outer.get_endian()==UVM_LITTLE_ENDIAN);
    $finish;
  end
endmodule
