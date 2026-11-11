/*
:name: test_enum_from_name_default_specialization_accepts_both_active_passive_names
:description: enum wrapper default specialization converts active-passive names (IEEE 1800.2-2020 Section F.3.4.2)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.3.4.2 F.3.4.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_enum_from_name_default_specialization_accepts_both_active_passive_names.expected
*/
// What it checks:
// The default enum wrapper specialization uses the active/passive enumeration.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.3.4.1 (UVM-ENUM-WRAPPER-DEFAULT-TYPE) gives the rule above.
// Setup: Omit the type parameter and convert both standard mode names plus an
// unrelated name. Expected: ACTIVE/PASSIVE succeed with exact identities and
// HOT is rejected.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe exact enum identity only after successful conversion.
// The output reference after failed conversion is not prescribed.
module test_enum_from_name_default_specialization_accepts_both_active_passive_names;
  import uvm_pkg::*;

  typedef enum int { COLD = -7, WARM = 4, HOT = 29 } temperature_e;
  typedef enum int { IDLE = 3, BUSY = 12 } activity_e;
  initial begin
    automatic temperature_e temperature = WARM;
    automatic activity_e activity = IDLE;
    automatic uvm_active_passive_enum mode = UVM_PASSIVE;
    automatic bit ok;

    ok = uvm_enum_wrapper#()::from_name("UVM_ACTIVE", mode);
    $display("UT: active success %0d exact %0d", ok, mode == UVM_ACTIVE);
    ok = uvm_enum_wrapper#()::from_name("UVM_PASSIVE", mode);
    $display("UT: passive success %0d exact %0d", ok, mode == UVM_PASSIVE);
    $display("UT: unrelated_name %0d", uvm_enum_wrapper#()::from_name("HOT", mode));

    $finish;
  end

endmodule
