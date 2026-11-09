/*
:name: test_builtin_dispatcher_concrete_extensions_preserve_constructor_target_mask
:description: Concrete builtin dispatcher extensions isolate constructor, inherited model and 64-bit field
:tags: uE uvm
:type: simulation
:lrm: 1800.2-2020 E.8.3.1 E.8.1 E.8.2.1 E.8.2.2 19.4.1.1 14.3.1 5.3.4.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_builtin_dispatcher_concrete_extensions_preserve_constructor_target_mask.expected
*/
// What it checks:
// 1. uvm_reg_mem_built_in_seq construction retains its listed default name and
//    explicit names.
// 2. uvm_reg_mem_built_in_seq has the declared register-sequence base
//    specialization.
// 3. The model property identifies the selected block, register or memory
//    using its declared handle type.
// 4. The dispatcher tests field has the declared sixty-four-bit storage width.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 E.8.3.1 (UVM-BUILTIN-AUDIT-REG-MEM-BUILT-IN-SEQ-CONSTRUCTOR)
//    gives rule 1 above. Setup: Call the actual constructor with omitted,
//    explicit nonempty and explicit empty names; the virtual dispatcher uses
//    two direct original extensions to isolate omitted/explicit base calls.
//    Expected: Default and explicit names match and separately created objects
//    have distinct handles.
// 2. 1800.2-2020 E.8.1 (UVM-BUILTIN-AUDIT-REG-MEM-BUILT-IN-SEQ-ANCESTRY) gives
//    rule 2 above. Setup: Use implicit assignments through
//    uvm_reg_sequence#(uvm_sequence#(uvm_reg_item)), its selected sequence
//    base and uvm_object, without casts. Expected: All static receivers
//    compile and retain the same original handle.
// 3. 1800.2-2020 E.8.2.1 (UVM-BUILTIN-AUDIT-REG-MEM-BUILT-IN-SEQ-TARGET) gives
//    rule 3 above. Setup: Original concrete target objects are assigned/read
//    through the builtin property, with separate sequence instances and static
//    receiver types. Expected: The exact typed receiver and inherited base
//    view share the selected model; the peer retains its separately assigned
//    model.
// 4. 1800.2-2020 E.8.2.2 (UVM-BUILTIN-AUDIT-DISPATCHER-MASK-WIDTH) gives rule
//    4 above. Setup: A legal concrete extension writes a value with both
//    highest and lowest bits set while a peer retains its prior mask.
//    Expected: The field width is sixty-four, the full value is retained and
//    the peer is unchanged.
// It also supports, as a control, the setup or conditions of
// UVM-BUILTIN-AUDIT-DISPATCHER-VIRTUAL.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Two direct concrete extensions isolate the omitted and explicit base new.
// The virtual builtin itself is never directly constructed by this control.
module test_builtin_dispatcher_concrete_extensions_preserve_constructor_target_mask;
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

  class omitted_extension extends uvm_reg_mem_built_in_seq;
    function new(); super.new(); endfunction
  endclass
  class named_extension extends uvm_reg_mem_built_in_seq;
    function new(string name); super.new(name); endfunction
  endclass
  initial begin
    omitted_extension omitted;
    named_extension named,empty_name;
    uvm_reg_mem_built_in_seq builtin_view,omitted_view,empty_view;
    uvm_reg_sequence#(uvm_sequence#(uvm_reg_item)) typed_view;
    uvm_sequence#(uvm_reg_item) sequence_view;
    uvm_object object_view;
    block_type first_target,second_target;
    uvm_reg_block exact_receiver;
    bit [63:0] peer_mask;
    omitted=new(); named=new("chosen60"); empty_name=new("");
    builtin_view=named; omitted_view=omitted; empty_view=empty_name;
    typed_view=builtin_view; sequence_view=typed_view;
    object_view=sequence_view;
    $display("UT: builtin_names default %0d explicit %0d empty %0d",
      omitted.get_name()=="uvm_reg_mem_built_in_seq",named.get_name()=="chosen60",
      empty_name.get_name()=="");
    $display("UT: builtin_ancestry typed %0d sequence %0d object %0d distinct %0d",
      typed_view==named,sequence_view==named,object_view==named,
      omitted_view!=builtin_view && builtin_view!=empty_view && omitted_view!=empty_view);
    first_target=new("first60"); second_target=new("second60");
    omitted.model=first_target; builtin_view.model=second_target; exact_receiver=named.model;
    $display("UT: target exact %0d inherited_alias %0d peer_unchanged %0d",
      exact_receiver==second_target,typed_view.model==second_target,omitted.model==first_target);
    peer_mask=omitted.tests; named.tests=64'h8000000000000001;
    $display("UT: test_mask width %0d high_bit_retained %0d peer_unchanged %0d",
      $bits(named.tests)==64,named.tests==64'h8000000000000001,omitted.tests==peer_mask);
    $finish;
  end
endmodule
