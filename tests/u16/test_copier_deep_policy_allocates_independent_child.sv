/*
:name: test_copier_deep_policy_allocates_independent_child
:description: deep copying an object field creates an independent child value (IEEE 1800.2-2020 Section 16.6.3)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.6.3 16.6.4.1 B.2.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_copier_deep_policy_allocates_independent_child.expected
*/
// Set recursion after constructing the copier and call its copy method
// directly. Deep copy preserves the child payload without sharing a handle.

module test_copier_deep_policy_allocates_independent_child;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class leaf extends uvm_object;
    `uvm_object_utils(leaf)
    int payload = 0;
    function new(string name="leaf"); super.new(name); endfunction
    function void do_copy(uvm_object rhs);
      leaf source;
      super.do_copy(rhs);
      if (!$cast(source, rhs)) $fatal(1, "unexpected copy type");
      payload = source.payload;
    endfunction
  endclass
  class box extends uvm_object;
    leaf child;
    `uvm_object_utils_begin(box)
      `uvm_field_object(child, UVM_DEFAULT)
    `uvm_object_utils_end
    function new(string name="box"); super.new(name); endfunction
  endclass

  initial begin
    box source = new("source");
    box target = new("target");
    uvm_copier copier = new;
    source.child = new("child");
    source.child.payload = 55;
    copier.set_recursion_policy(UVM_DEEP);
    copier.copy_object(target, source);
    if (target.child == null) $fatal(1, "missing copied child");
    $display("UT: separate child %0d payload %0d", target.child != source.child,
             target.child.payload);
    target.child.payload = 82;
    $display("UT: source unchanged %0d", source.child.payload);
    $finish;
  end
endmodule
