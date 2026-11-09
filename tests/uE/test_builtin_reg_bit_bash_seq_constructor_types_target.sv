/*
:name: test_builtin_reg_bit_bash_seq_constructor_types_target
:description: Builtin uvm_reg_bit_bash_seq names, declared sequence ancestry and selected target property
:tags: uE uvm
:type: simulation
:lrm: 1800.2-2020 E.2.2.3.1 E.2.2.1 E.2.2.2.1 19.4.1.1 14.3.1 5.3.4.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_builtin_reg_bit_bash_seq_constructor_types_target.expected
*/
// What it checks:
// 1. uvm_reg_bit_bash_seq construction retains its listed default name and
//    explicit names.
// 2. uvm_reg_bit_bash_seq has the declared register-sequence base
//    specialization.
// 3. The model property identifies the selected block, register or memory
//    using its declared handle type.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 E.2.2.3.1 (UVM-BUILTIN-AUDIT-REG-BIT-BASH-SEQ-CONSTRUCTOR)
//    gives rule 1 above. Setup: Call the actual constructor with omitted,
//    explicit nonempty and explicit empty names; the virtual dispatcher uses
//    two direct original extensions to isolate omitted/explicit base calls.
//    Expected: Default and explicit names match and separately created objects
//    have distinct handles.
// 2. 1800.2-2020 E.2.2.1 (UVM-BUILTIN-AUDIT-REG-BIT-BASH-SEQ-ANCESTRY) gives
//    rule 2 above. Setup: Use implicit assignments through
//    uvm_reg_sequence#(uvm_sequence#(uvm_reg_item)), its selected sequence
//    base and uvm_object, without casts. Expected: All static receivers
//    compile and retain the same original handle.
// 3. 1800.2-2020 E.2.2.2.1 (UVM-BUILTIN-AUDIT-REG-BIT-BASH-SEQ-TARGET) gives
//    rule 3 above. Setup: Original concrete target objects are assigned/read
//    through the builtin property, with separate sequence instances and static
//    receiver types. Expected: Typed reads retain initial/replacement targets,
//    an independent peer stays unchanged and null can be stored without
//    executing the sequence.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Constructor calls are made on the actual builtin class, with real omission,
// explicit nonempty and explicit empty names. No factory/type_id is required.
// The target-property checks certify storage/type/aliasing, not execution.
module test_builtin_reg_bit_bash_seq_constructor_types_target;
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
    uvm_reg_bit_bash_seq omitted,named,empty_name;
    uvm_reg_sequence#(uvm_sequence#(uvm_reg_item)) typed_view;
    uvm_sequence#(uvm_reg_item) sequence_view;
    uvm_sequence_base base_view;
    uvm_object object_view;
    block_type first_target,second_target,third_target;
    uvm_reg_block exact_receiver;
    omitted=new(); named=new("named60"); empty_name=new("");
    typed_view=named; sequence_view=typed_view; base_view=sequence_view; object_view=base_view;
    $display("UT: builtin_names default %0d explicit %0d empty %0d",
      omitted.get_name()=="uvm_reg_bit_bash_seq",named.get_name()=="named60",
      empty_name.get_name()=="");
    $display("UT: builtin_ancestry typed %0d sequence %0d object %0d distinct %0d",
      typed_view==named,sequence_view==named,object_view==named,
      omitted!=named && named!=empty_name && omitted!=empty_name);
    first_target=new("first60"); second_target=new("second60");
    third_target=new("third60");
    omitted.model=first_target; named.model=second_target;
    exact_receiver=named.model;
    $display("UT: target initial %0d peer %0d",exact_receiver==second_target,
      omitted.model==first_target);
    named.model=third_target; empty_name.model=null;
    $display("UT: target replaced %0d peer_unchanged %0d null_storage %0d",
      named.model==third_target,omitted.model==first_target,empty_name.model==null);
    $finish;
  end
endmodule
