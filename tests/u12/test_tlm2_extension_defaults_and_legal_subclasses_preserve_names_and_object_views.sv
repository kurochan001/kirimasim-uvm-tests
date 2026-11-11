/*
:name: test_tlm2_extension_defaults_and_legal_subclasses_preserve_names_and_object_views
:description: tlm2 extension default type and legal subclasses preserve constructor names and object views (IEEE 1800.2-2020 Section 12.3.4.5.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.5.3 12.3.4.5 12.3.4.5.1 12.3.4.4 12.3.4.4.1 12.3.4.4.3 5.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_extension_defaults_and_legal_subclasses_preserve_names_and_object_views.expected
*/
// What it checks:
// 1. A selected user extension derives through the parameterized extension
//    class rather than directly from its nonparameterized base.
// 2. The extension base derives from uvm_object.
// 3. The legal extension constructor chain passes the selected name to the
//    object base.
// 4. A user extension can select its own derived type as the extension
//    parameter.
// 5. The parameterized extension defaults T to int.
// 6. The parameterized extension derives from the nonparameterized extension
//    base.
// 7. The extension constructor defaults its instance name to empty.
// 8. The extension constructor accepts and preserves a selected instance name.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.4.4 (UVM-TLM2-TYPES-USER-EXTENSION-CHAIN) gives rule 1
//    above. Setup: Construct default-T and legal self-typed extension objects
//    with omitted/explicit names, then use exact extension/base/object views.
//    Expected: The legal original derived object fits both extension-base and
//    object views.
// 2. 1800.2-2020 12.3.4.4.1 (UVM-TLM2-TYPES-EXTENSION-OBJECT-BASE) gives rule
//    2 above. Setup: Construct default-T and legal self-typed extension
//    objects with omitted/explicit names, then use exact extension/base/object
//    views. Expected: The object view retains extension identity and sees its
//    renamed instance.
// 3. 1800.2-2020 12.3.4.4.3 (UVM-TLM2-TYPES-EXTENSION-BASE-CONSTRUCTOR-NAME)
//    gives rule 3 above. Setup: Construct default-T and legal self-typed
//    extension objects with omitted/explicit names, then use exact
//    extension/base/object views. Expected: Omitted names remain empty and an
//    explicit name reaches the object view.
// 4. 1800.2-2020 12.3.4.5 (UVM-TLM2-TYPES-SELF-TYPED-EXTENSION) gives rule 4
//    above. Setup: Construct default-T and legal self-typed extension objects
//    with omitted/explicit names, then use exact extension/base/object views.
//    Expected: The original self-typed class constructs distinct legal
//    objects.
// 5. 1800.2-2020 12.3.4.5.1 (UVM-TLM2-TYPES-EXTENSION-DEFAULT-T) gives rule 5
//    above. Setup: Construct default-T and legal self-typed extension objects
//    with omitted/explicit names, then use exact extension/base/object views.
//    Expected: The omitted-T instance fits the exact integer extension view.
// 6. 1800.2-2020 12.3.4.5.1 (UVM-TLM2-TYPES-EXTENSION-BASE-IDENTITY) gives
//    rule 6 above. Setup: Construct default-T and legal self-typed extension
//    objects with omitted/explicit names, then use exact extension/base/object
//    views. Expected: The base view retains the legal concrete extension
//    identity.
// 7. 1800.2-2020 12.3.4.5.3 (UVM-TLM2-TYPES-EXTENSION-EMPTY-DEFAULT-NAME)
//    gives rule 7 above. Setup: Construct default-T and legal self-typed
//    extension objects with omitted/explicit names, then use exact
//    extension/base/object views. Expected: Both omitted-name extension
//    objects report empty names.
// 8. 1800.2-2020 12.3.4.5.3 (UVM-TLM2-TYPES-EXTENSION-EXPLICIT-NAME) gives
//    rule 8 above. Setup: Construct default-T and legal self-typed extension
//    objects with omitted/explicit names, then use exact extension/base/object
//    views. Expected: The named object starts selected and its independent
//    peer remains unnamed.
// It also supports, as a control, the setup or conditions of
// UVM-ABSTRACT-TLM-EXTENSION-BASE-DIRECT-CONSTRUCTION.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// User subclasses derive via the standard parameterized extension class.
// Default T and constructor-name pass-through are positive compile/runtime
// checks. The abstract nonparameterized base is used only as a handle. Illegal
// base construction/direct user extension and default IMP are not certified.
module test_tlm2_extension_defaults_and_legal_subclasses_preserve_names_and_object_views;
  import uvm_pkg::*;
  class legal_extension extends uvm_tlm_extension#(legal_extension);
    function new(string name=""); super.new(name); endfunction
  endclass
  initial begin
    automatic uvm_tlm_extension#() default_value = new();
    automatic uvm_tlm_extension#(int) exact = default_value;
    automatic legal_extension unnamed = new();
    automatic legal_extension named = new("selected");
    automatic uvm_tlm_extension_base base = named;
    automatic uvm_object object_view = base;
    $display("UT: extension_default type %0d empty_name %0d",exact == default_value,
             default_value.get_name() == "");
    $display("UT: extension_legal names %0d/%0d base %0d object %0d distinct %0d",
             unnamed.get_name() == "",named.get_name() == "selected",base == named,
             object_view == named,unnamed != named);
    named.set_name("renamed");
    $display("UT: extension_alias name %0d peer_empty %0d",object_view.get_name() == "renamed",
             unnamed.get_name() == "");
    $finish;
  end
endmodule
