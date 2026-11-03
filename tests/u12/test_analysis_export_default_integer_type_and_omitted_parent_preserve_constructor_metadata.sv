/*
:name: test_analysis_export_default_integer_type_and_omitted_parent_preserve_constructor_metadata
:description: analysis export default integer type and omitted parent preserve constructor metadata (IEEE 1800.2-2020 Section 12.2.10.3.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.10.3.2 12.2.10.3.1 5.5.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_analysis_export_default_integer_type_and_omitted_parent_preserve_constructor_metadata.expected
*/
// Constructor-only default integer interface probes precede binding
// resolution.
// An omitted static parent is legal; actual hierarchy/fanout is checked apart.
module test_analysis_export_default_integer_type_and_omitted_parent_preserve_constructor_metadata;
  import uvm_pkg::*;
  class owner extends uvm_component;
    function new(); super.new("owner",null); endfunction
  endclass
  initial begin
    automatic owner parent_value = new();
    automatic uvm_analysis_export#() standalone = new("standalone");
    automatic uvm_analysis_export#() child = new("child",parent_value);
    automatic uvm_port_base#(uvm_tlm_if_base#(int,int)) exact = child;
    $display("UT: analysis_export default_type %0d name %0d parent %0d role %0d bounds %0d/%0d",
             exact == child,child.get_name() == "child",child.get_parent() == parent_value,
             child.is_export(),child.min_size(),child.max_size());
    $display("UT: analysis_export_static name %0d role %0d bounds %0d/%0d",
             standalone.get_name() == "standalone",standalone.is_export(),
             standalone.min_size(),standalone.max_size());
    $finish;
  end
endmodule
