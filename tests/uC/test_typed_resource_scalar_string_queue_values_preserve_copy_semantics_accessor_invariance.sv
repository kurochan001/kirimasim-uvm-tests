/*
:name: test_typed_resource_scalar_string_queue_values_preserve_copy_semantics_accessor_invariance
:description: Typed resources preserve scalar/string/queue values without accessor-dependent behavior
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.5.4.1 C.2.5.4.2 C.2.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_typed_resource_scalar_string_queue_values_preserve_copy_semantics_accessor_invariance.expected
*/
// What it checks:
// 1. Typed reads recover selected scalar, string and queue values
//    independently of accessor.
// 2. Typed writes store selected values with normal queue value-copy behavior.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 C.2.5.4.1 (UVM-RESOURCE-AUDIT-VALUE-READ) gives rule 1 above.
//    Setup: Original concrete accessor objects and initialized
//    scalar/string/two-element queue data are used. Expected: Stored values
//    match and repeated scalar reads with two accessor handles agree.
// 2. 1800.2-2020 C.2.5.4.2 (UVM-RESOURCE-AUDIT-VALUE-WRITE) gives rule 2
//    above. Setup: Original concrete accessor objects and initialized
//    scalar/string/two-element queue data are used. Expected: Mutating the
//    caller queue or a returned queue does not change the resource queue;
//    scalar and string values remain exact.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module
  test_typed_resource_scalar_string_queue_values_preserve_copy_semantics_accessor_invariance;
  import uvm_pkg::*;
  class accessor_type extends uvm_object;
    function new(string name); super.new(name); endfunction
  endclass
  typedef int queue_type[$];
  initial begin
    automatic uvm_resource#(int) scalar=new("scalar58");
    automatic uvm_resource#(string) text_value=new("text58");
    automatic uvm_resource#(queue_type) queue_value=new("queue58");
    automatic accessor_type first_accessor=new("first58");
    automatic accessor_type second_accessor=new("second58");
    automatic queue_type input_values='{3,5};
    queue_type observed,again;
    scalar.write(-58,first_accessor); text_value.write("payload58",second_accessor);
    queue_value.write(input_values,first_accessor); input_values.push_back(9);
    observed=queue_value.read(second_accessor); observed[0]=99;
    again=queue_value.read();
    $display("UT: typed_values scalar %0d text %0d queue_copy %0d accessor_invariant %0d",
      scalar.read()==-58,text_value.read(first_accessor)=="payload58",
      again.size()==2 && again[0]==3 && again[1]==5,
      scalar.read(first_accessor)==scalar.read(second_accessor));
    $finish;
  end
endmodule
