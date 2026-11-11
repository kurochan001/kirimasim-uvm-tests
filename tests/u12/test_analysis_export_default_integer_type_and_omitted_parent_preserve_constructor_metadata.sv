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
// What it checks:
// 1. The analysis export defaults T to int and derives from the matching
//    interface port base.
// 2. The analysis export constructor permits an omitted static parent.
// 3. The analysis export constructor retains its supplied name and parent.
// 4. The analysis export uses export role with minimum one and unbounded
//    maximum.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.2.10.3.1 (UVM-TLM-DECL-ANALYSIS-EXPORT-DEFAULT-T) gives
//    rule 1 above. Setup: Construct default analysis exports with omitted
//    static and explicit actual component parents before binding. Expected:
//    The exact integer port-base view retains export identity.
// 2. 1800.2-2020 12.2.10.3.2 (UVM-TLM-DECL-ANALYSIS-EXPORT-STATIC-PARENT)
//    gives rule 2 above. Setup: Construct default analysis exports with
//    omitted static and explicit actual component parents before binding.
//    Expected: The standalone export constructs and retains its selected name.
// 3. 1800.2-2020 12.2.10.3.2 (UVM-TLM-DECL-ANALYSIS-EXPORT-NAME-PARENT) gives
//    rule 3 above. Setup: Construct default analysis exports with omitted
//    static and explicit actual component parents before binding. Expected:
//    The selected export returns the given local name and actual owner.
// 4. 1800.2-2020 12.2.10.3.2 (UVM-TLM-DECL-ANALYSIS-EXPORT-ROLE-BOUNDS) gives
//    rule 4 above. Setup: Construct default analysis exports with omitted
//    static and explicit actual component parents before binding. Expected:
//    Both exports report export role and one/minus-one bounds.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
