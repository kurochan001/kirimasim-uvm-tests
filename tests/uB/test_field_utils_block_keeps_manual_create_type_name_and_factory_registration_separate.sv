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
