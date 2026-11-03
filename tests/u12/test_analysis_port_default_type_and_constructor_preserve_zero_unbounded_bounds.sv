/*
:name: test_analysis_port_default_type_and_constructor_preserve_zero_unbounded_bounds
:description: analysis port default integer type and constructor metadata preserve zero unbounded bounds (IEEE 1800.2-2020 Section 12.2.10.1.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.10.1.1 12.2.10.1.3 5.5.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_analysis_port_default_type_and_constructor_preserve_zero_unbounded_bounds.expected
*/
// Default type and pre-binding constructor metadata only. The unbounded
// maximum is the declared minus one; no subscriber count is inferred.
module test_analysis_port_default_type_and_constructor_preserve_zero_unbounded_bounds;
  import uvm_pkg::*;
  class owner extends uvm_component;
    function new(); super.new("owner",null); endfunction
  endclass
  initial begin
    automatic owner parent_value = new();
    automatic uvm_analysis_port#() selected = new("selected",parent_value);
    automatic uvm_port_base#(uvm_tlm_if_base#(int,int)) exact = selected;
    $display("UT: analysis_port default_type %0d name %0d parent %0d role %0d bounds %0d/%0d",
             exact == selected,selected.get_name() == "selected",
             selected.get_parent() == parent_value,selected.is_port(),
             selected.min_size(),selected.max_size());
    $finish;
  end
endmodule
