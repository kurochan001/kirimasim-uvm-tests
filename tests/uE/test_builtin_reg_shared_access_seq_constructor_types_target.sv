/*
:name: test_builtin_reg_shared_access_seq_constructor_types_target
:description: Builtin uvm_reg_shared_access_seq names, declared sequence ancestry and selected target property
:tags: uE uvm
:type: simulation
:lrm: 1800.2-2020 E.4.1.3 E.4.1.1 E.4.1.2 19.4.1.1 14.3.1 5.3.4.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_builtin_reg_shared_access_seq_constructor_types_target.expected
*/
// Constructor calls are made on the actual builtin class, with real omission,
// explicit nonempty and explicit empty names. No factory/type_id is required.
// The target-property checks certify storage/type/aliasing, not execution.
module test_builtin_reg_shared_access_seq_constructor_types_target;
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
    uvm_reg_shared_access_seq omitted,named,empty_name;
    uvm_reg_sequence#(uvm_sequence#(uvm_reg_item)) typed_view;
    uvm_sequence#(uvm_reg_item) sequence_view;
    uvm_sequence_base base_view;
    uvm_object object_view;
    register_type first_target,second_target,third_target;
    uvm_reg exact_receiver;
    omitted=new(); named=new("named60"); empty_name=new("");
    typed_view=named; sequence_view=typed_view; base_view=sequence_view; object_view=base_view;
    $display("UT: builtin_names default %0d explicit %0d empty %0d",
      omitted.get_name()=="uvm_reg_shared_access_seq",named.get_name()=="named60",
      empty_name.get_name()=="");
    $display("UT: builtin_ancestry typed %0d sequence %0d object %0d distinct %0d",
      typed_view==named,sequence_view==named,object_view==named,
      omitted!=named && named!=empty_name && omitted!=empty_name);
    first_target=new("first60"); second_target=new("second60");
    third_target=new("third60");
    omitted.rg=first_target; named.rg=second_target;
    exact_receiver=named.rg;
    $display("UT: target initial %0d peer %0d",exact_receiver==second_target,
      omitted.rg==first_target);
    named.rg=third_target; empty_name.rg=null;
    $display("UT: target replaced %0d peer_unchanged %0d null_storage %0d",
      named.rg==third_target,omitted.rg==first_target,empty_name.rg==null);
    $finish;
  end
endmodule
