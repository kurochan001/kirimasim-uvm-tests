/*
:name: test_field_utils_block_keeps_manual_create_type_name_and_factory_registration_separate
:description: A field-utils block implements data operations without generating factory or creation methods
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.1.1 B.2.2 B.2.2.1.1 5.3.13 5.3.5.1 5.3.5.2 5.3.8.1 1800-2023 6.21 8.20 8.21 7.4 7.8 7.9 8.19
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_field_utils_block_keeps_manual_create_type_name_and_factory_registration_separate.expected
*/
// What it checks:
// 1. A field-utils block leaves custom create behavior to the original class.
// 2. A field-utils block leaves the class type-name implementation to its
//    user.
// 3. A field-utils block does not register the original class with the
//    factory.
// 4. Field macros provide the selected data-operation implementation without a
//    user hook.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 B.2.1.1 (UVM-FIELD-MACRO-AUDIT-FIELD-UTILS-CUSTOM-CREATE)
//    gives rule 1 above. Setup: Use a manually named/created class with a
//    field-utils block, no object-utils registration and no
//    do-copy/do-execute-op override. Expected: Clone calls the original create
//    method once and returns a distinct object with the copied payload.
// 2. 1800.2-2020 B.2.1.1 (UVM-FIELD-MACRO-AUDIT-FIELD-UTILS-CUSTOM-TYPE) gives
//    rule 2 above. Setup: Use a manually named/created class with a
//    field-utils block, no object-utils registration and no
//    do-copy/do-execute-op override. Expected: The copied original class
//    retains its manually implemented type-name result.
// 3. 1800.2-2020 B.2.1.1 (UVM-FIELD-MACRO-AUDIT-FIELD-UTILS-NO-REGISTRATION)
//    gives rule 3 above. Setup: Use a manually named/created class with a
//    field-utils block, no object-utils registration and no
//    do-copy/do-execute-op override. Expected: The selected unique manual
//    class type name remains absent from factory registration.
// 4. 1800.2-2020 5.3.13 (UVM-FIELD-MACRO-AUDIT-FIELD-OP-DEFAULT) gives rule 4
//    above. Setup: Use a manually named/created class with a field-utils
//    block, no object-utils registration and no do-copy/do-execute-op
//    override. Expected: The manual-create clone copies payload
//    one-hundred-ninety-seven using only the field-utils block.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_field_utils_block_keeps_manual_create_type_name_and_factory_registration_separate;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class manual_packet extends uvm_object;
    int payload, creates=0;
    `uvm_field_utils_begin(manual_packet)
      `uvm_field_int(payload,UVM_COPY|UVM_COMPARE)
    `uvm_field_utils_end
    function new(string name="manual65"); super.new(name); endfunction
    virtual function string get_type_name(); return "manual_packet65"; endfunction
    virtual function uvm_object create(string name="");
      manual_packet result;
      creates++; result=new(name); return result;
    endfunction
  endclass
  initial begin
    automatic manual_packet source=new("source65");
    manual_packet cloned;
    uvm_object raw;
    source.payload=197; raw=source.clone();
    if (!$cast(cloned,raw) || cloned==null) $fatal(1,"manual65 clone type");
    $display("UT: field_utils type %0d create_calls %0d copied %0d independent %0d",
      cloned.get_type_name()=="manual_packet65",source.creates,cloned.payload==197,
      cloned!=source);
    $display("UT: field_utils unregistered %0d",
      !uvm_factory::get().is_type_name_registered("manual_packet65"));
    $finish;
  end
endmodule
