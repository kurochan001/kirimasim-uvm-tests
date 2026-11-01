/*
:name: test_recording_links_dispatch_endpoint_hooks_and_preserve_prefilled_identities
:description: link endpoints dispatch through hooks and concrete prefills retain object identities (IEEE 1800.2-2020 Section 7.3.1.3.5)
:tags: u07 uvm
:type: simulation
:lrm: 1800.2-2020 7.3.1.3.5 7.3.1.3.1 7.3.1.3.2 7.3.1.3.3 7.3.1.3.4 7.3.1.4.1 7.3.1.4.2 7.3.1.4.3 7.3.1.4.4 7.3.2.2.2 7.3.3.2.2 7.3.4.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_recording_links_dispatch_endpoint_hooks_and_preserve_prefilled_identities.expected
*/
// Explicit link names avoid relying on default-name interpretation.
// A combined set invokes both hooks without prescribing their order.
module test_recording_links_dispatch_endpoint_hooks_and_preserve_prefilled_identities;
  import uvm_pkg::*;

  class endpoint extends uvm_object;
    function new(string name="endpoint"); super.new(name); endfunction
  endclass
  class hook_link extends uvm_link_base;
    uvm_object left_value;
    uvm_object right_value;
    int left_sets = 0;
    int right_sets = 0;
    int left_gets = 0;
    int right_gets = 0;
    function new(string name="hook_link"); super.new(name); endfunction
    virtual function void do_set_lhs(uvm_object lhs); left_sets++; left_value = lhs; endfunction
    virtual function void do_set_rhs(uvm_object rhs); right_sets++; right_value = rhs; endfunction
    virtual function uvm_object do_get_lhs(); left_gets++; return left_value; endfunction
    virtual function uvm_object do_get_rhs(); right_gets++; return right_value; endfunction
  endclass
  initial begin
    automatic hook_link probe = new("probe");
    automatic endpoint left_value = new("left");
    automatic endpoint right_value = new("right");
    uvm_link_base prefilled[3];
    probe.set(left_value, right_value);
    $display("UT: combined identity %0d %0d", probe.get_lhs() == left_value,
             probe.get_rhs() == right_value);
    probe.set_lhs(right_value); probe.set_rhs(left_value);
    $display("UT: replaced identity %0d %0d", probe.get_lhs() == right_value,
             probe.get_rhs() == left_value);
    $display("UT: hooks sets %0d/%0d gets %0d/%0d", probe.left_sets, probe.right_sets,
             probe.left_gets, probe.right_gets);
    prefilled[0] = uvm_parent_child_link::get_link(left_value, right_value, "parent_child");
    prefilled[1] = uvm_cause_effect_link::get_link(left_value, right_value, "cause_effect");
    prefilled[2] = uvm_related_link::get_link(left_value, right_value, "related");
    foreach (prefilled[i]) $display("UT: prefilled %0d identity %0d %0d name %s", i,
        prefilled[i].get_lhs() == left_value, prefilled[i].get_rhs() == right_value,
        prefilled[i].get_name());
    $finish;
  end

endmodule
