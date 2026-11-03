/*
:name: test_concrete_link_constructors_preserve_default_and_explicit_names
:description: all three concrete link constructors preserve their own defaults and explicit names (7.3.2.2.1)
:tags: u07 uvm
:type: simulation
:lrm: 1800.2-2020 7.3.2.2.1 7.3.3.2.1 7.3.4.2.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_concrete_link_constructors_preserve_default_and_explicit_names.expected
*/
module test_concrete_link_constructors_preserve_default_and_explicit_names;
  import uvm_pkg::*;
  initial begin
    automatic uvm_parent_child_link pc = new();
    automatic uvm_cause_effect_link ce = new();
    automatic uvm_related_link related = new();
    automatic uvm_parent_child_link named_pc = new("named_pc");
    automatic uvm_cause_effect_link named_ce = new("named_ce");
    automatic uvm_related_link named_related = new("named_related");
    $display("UT: defaults %s %s %s", pc.get_name(), ce.get_name(), related.get_name());
    $display("UT: explicit %s %s %s", named_pc.get_name(), named_ce.get_name(),
             named_related.get_name());
    $display("UT: distinct %0d %0d %0d", pc != named_pc, ce != named_ce,
             related != named_related);
    $finish;
  end
endmodule
