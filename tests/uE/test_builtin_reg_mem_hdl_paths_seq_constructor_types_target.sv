/*
:name: test_builtin_reg_mem_hdl_paths_seq_constructor_types_target
:description: Builtin uvm_reg_mem_hdl_paths_seq names, declared sequence ancestry and selected target property
:tags: uE uvm
:type: simulation
:lrm: 1800.2-2020 E.7.3 E.7.1 E.7.2 19.4.1.1 14.3.1 5.3.4.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_builtin_reg_mem_hdl_paths_seq_constructor_types_target.expected
*/
// Constructor calls are made on the actual builtin class, with real omission,
// explicit nonempty and explicit empty names. No factory/type_id is required.
// The target-property checks certify storage/type/aliasing, not execution.
module test_builtin_reg_mem_hdl_paths_seq_constructor_types_target;
  import uvm_pkg::*;

  class block_type extends uvm_reg_block;
    function new(string name); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass
  class register_type extends uvm_reg;
    function new(string name); super.new(name,8,UVM_NO_COVERAGE); endfunction
  endclass
  class memory_type extends uvm_mem;
    function new(string name); super.new(name,4,8,"RW",UVM_NO_COVERAGE); endfunction
  endclass
  initial begin
    uvm_reg_mem_hdl_paths_seq omitted,named,empty_name;
    uvm_reg_sequence#(uvm_sequence#(uvm_reg_item)) typed_view;
    uvm_sequence#(uvm_reg_item) sequence_view;
    uvm_sequence_base base_view;
    uvm_object object_view;
    omitted=new(); named=new("named60"); empty_name=new("");
    typed_view=named; sequence_view=typed_view; base_view=sequence_view; object_view=base_view;
    $display("UT: builtin_names default %0d explicit %0d empty %0d",
      omitted.get_name()=="uvm_reg_mem_hdl_paths_seq",named.get_name()=="named60",
      empty_name.get_name()=="");
    $display("UT: builtin_ancestry typed %0d sequence %0d object %0d distinct %0d",
      typed_view==named,sequence_view==named,object_view==named,
      omitted!=named && named!=empty_name && omitted!=empty_name);
    named.abstractions.push_back("RTL60"); named.abstractions.push_back("GATE60");
    omitted.abstractions.push_back("PEER60");
    $display("UT: abstractions queue_order %0d peer %0d",
      named.abstractions.size()==2 && named.abstractions[0]=="RTL60" &&
      named.abstractions[1]=="GATE60",
      omitted.abstractions.size()==1 && omitted.abstractions[0]=="PEER60");
    $finish;
  end
endmodule
