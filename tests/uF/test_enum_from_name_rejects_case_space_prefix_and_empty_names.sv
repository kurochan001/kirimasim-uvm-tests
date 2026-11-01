/*
:name: test_enum_from_name_rejects_case_space_prefix_and_empty_names
:description: enum wrapper requires exact case-sensitive names (IEEE 1800.2-2020 Section F.3.4.2)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.3.4.2 F.3.4.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_enum_from_name_rejects_case_space_prefix_and_empty_names.expected
*/
// Observe exact enum identity only after successful conversion.
// The output reference after failed conversion is not prescribed.
module test_enum_from_name_rejects_case_space_prefix_and_empty_names;
  import uvm_pkg::*;

  typedef enum int { COLD = -7, WARM = 4, HOT = 29 } temperature_e;
  typedef enum int { IDLE = 3, BUSY = 12 } activity_e;
  initial begin
    automatic temperature_e temperature = WARM;
    automatic activity_e activity = IDLE;
    automatic uvm_active_passive_enum mode = UVM_PASSIVE;
    automatic bit ok;

    $display("UT: invalid lower %0d padded %0d prefix %0d empty %0d",
    uvm_enum_wrapper#(temperature_e)::from_name("cold", temperature),
    uvm_enum_wrapper#(temperature_e)::from_name(" COLD ", temperature),
    uvm_enum_wrapper#(temperature_e)::from_name("COLD_MORE", temperature),
    uvm_enum_wrapper#(temperature_e)::from_name("", temperature));
    ok = uvm_enum_wrapper#(temperature_e)::from_name("HOT", temperature);
    $display("UT: valid_after_rejections success %0d exact %0d", ok, temperature == HOT);

    $finish;
  end

endmodule
