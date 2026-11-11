/*
:name: test_tlm_fifo_base_constructor_parent_and_default_type_preserve_component_identity
:description: tlm fifo base constructor parent and default type preserve component identity (IEEE 1800.2-2020 Section 12.2.8.1.7)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.1.7 12.2.8.1.1 13.1.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_base_constructor_parent_and_default_type_preserve_component_identity.expected
*/
// What it checks:
// 1. The FIFO base defaults its stored transaction type to int.
// 2. The FIFO base derives from the component base.
// 3. The FIFO-base constructor permits an omitted parent for static use.
// 4. FIFO-base construction associates the supplied component name and parent.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.2.8.1.1 (UVM-TLM1-REVIEW-FIFO-BASE-DEFAULT-TYPE) gives
//    rule 1 above. Setup: Upcast a concrete default-base probe to the exact
//    int specialization. Expected: The exact view retains identity.
// 2. 1800.2-2020 12.2.8.1.1 (UVM-TLM1-REVIEW-FIFO-BASE-COMPONENT) gives rule 2
//    above. Setup: Assign a named concrete FIFO-base child to a component
//    handle. Expected: The component view retains identity.
// 3. 1800.2-2020 12.2.8.1.7 (UVM-TLM1-REVIEW-FIFO-BASE-OMITTED-PARENT) gives
//    rule 3 above. Setup: An original concrete subtype calls the base
//    constructor with only its selected name. Expected: Construction succeeds
//    and retains the selected local name.
// 4. 1800.2-2020 12.2.8.1.7 (UVM-TLM1-REVIEW-FIFO-BASE-NAME-PARENT) gives rule
//    4 above. Setup: Construct a concrete child under an actual owner
//    component. Expected: Local/full name, parent and component identity
//    match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Concrete original probes call the declared base constructor with an omitted
// parent or an explicit actual component parent. Default T is checked through
// an exact base view. No base default method algorithm, abstract construction,
// factory behavior or unspecified empty component name is inferred.
module test_tlm_fifo_base_constructor_parent_and_default_type_preserve_component_identity;
  import uvm_pkg::*;
  class owner extends uvm_component;
    function new(); super.new("owner",null); endfunction
  endclass
  class static_probe extends uvm_tlm_fifo_base#();
    function new(); super.new("static_fifo"); endfunction
  endclass
  class child_probe extends uvm_tlm_fifo_base#(int);
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  initial begin
    automatic owner parent_value = new();
    automatic static_probe standalone = new();
    automatic child_probe child = new("child_fifo",parent_value);
    automatic uvm_tlm_fifo_base#(int) exact_default = standalone;
    automatic uvm_component component_view = child;
    $display("UT: fifo_base_static name %0d default_type %0d",
             standalone.get_name() == "static_fifo",exact_default == standalone);
    $display("UT: fifo_base_child name %0d parent %0d full_name %0d component %0d",
             child.get_name() == "child_fifo",child.get_parent() == parent_value,
             child.get_full_name() == "owner.child_fifo",component_view == child);
    $finish;
  end
endmodule
