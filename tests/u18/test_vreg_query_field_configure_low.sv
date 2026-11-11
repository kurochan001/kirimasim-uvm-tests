/*
:name: test_vreg_query_field_configure_low
:description: Virtual-field configuration records its parent, bit width and least-significant position.
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.10.2.2 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.4 18.6.3.1 18.6.3.2 18.9.1.1.1 18.9.1.1.2 18.10.2.1 18.10.3.1 18.10.3.2 18.10.3.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_query_field_configure_low.expected
:files: helpers70/vreg_query_fixture70.svh
*/
// What it checks:
// 1. Virtual-field configuration records its selected virtual-register parent.
// 2. Virtual-field configuration records its selected width in bits.
// 3. Virtual-field configuration records its selected least-significant bit
//    position.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.10.2.2 (UVM-VREG-QUERY-FIELD-CONFIGURE-PARENT) gives rule
//    1 above. Setup: Factory-create a field and configure width 5, LSB 0 in a
//    40-bit virtual register. Factory-create a field and configure width 11,
//    LSB 7 in a 40-bit virtual register. Expected: Only the separately
//    anchored parent observation is bound to this duty.
// 2. 1800.2-2020 18.10.2.2 (UVM-VREG-QUERY-FIELD-CONFIGURE-WIDTH) gives rule 2
//    above. Setup: Factory-create a field and configure width 5, LSB 0 in a
//    40-bit virtual register. Factory-create a field and configure width 11,
//    LSB 7 in a 40-bit virtual register. Also configure a five-bit field at
//    LSB seven in a sixteen-bit virtual register. Expected: Only the width
//    value in each linked observation is bound to this duty.
// 3. 1800.2-2020 18.10.2.2 (UVM-VREG-QUERY-FIELD-CONFIGURE-LSB) gives rule 3
//    above. Setup: Factory-create a field and configure width 5, LSB 0 in a
//    40-bit virtual register. Factory-create a field and configure width 11,
//    LSB 7 in a 40-bit virtual register. Also configure a five-bit field at
//    LSB seven in a sixteen-bit virtual register. Expected: Only the lsb value
//    in each linked observation is bound to this duty.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Independently derived model observations; original testbench setup.
module
  test_vreg_query_field_configure_low;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "vreg_query_fixture70.svh"
initial begin
    automatic model70 m=new();
    automatic uvm_vreg_field field=uvm_vreg_field::type_id::create("field70");
    field.configure(m.vr,5,0);m.owner.lock_model();
    $display("UT: configured_low parent %0d",field.get_parent()==m.vr);
    $display("UT: configured_low width %0d",field.get_n_bits());
    $display("UT: configured_low lsb %0d",field.get_lsb_pos_in_register());
    $finish;
  end
endmodule
