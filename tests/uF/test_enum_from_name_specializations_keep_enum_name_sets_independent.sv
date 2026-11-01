/*
:name: test_enum_from_name_specializations_keep_enum_name_sets_independent
:description: enum wrapper specializations accept only their own enumerator names (IEEE 1800.2-2020 Section F.3.4.2)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.3.4.2 F.3.4.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_enum_from_name_specializations_keep_enum_name_sets_independent.expected
*/
// Observe exact enum identity only after successful conversion.
// The output reference after failed conversion is not prescribed.
module test_enum_from_name_specializations_keep_enum_name_sets_independent;
  import uvm_pkg::*;

  typedef enum int { COLD = -7, WARM = 4, HOT = 29 } temperature_e;
  typedef enum int { IDLE = 3, BUSY = 12 } activity_e;
  initial begin
    automatic temperature_e temperature = WARM;
    automatic activity_e activity = IDLE;
    automatic uvm_active_passive_enum mode = UVM_PASSIVE;
    automatic bit ok;

    ok = uvm_enum_wrapper#(temperature_e)::from_name("HOT", temperature);
    $display("UT: temperature success %0d exact %0d", ok, temperature == HOT);
    ok = uvm_enum_wrapper#(activity_e)::from_name("BUSY", activity);
    $display("UT: activity success %0d exact %0d", ok, activity == BUSY);
    $display("UT: foreign temperature %0d activity %0d",
    uvm_enum_wrapper#(temperature_e)::from_name("BUSY", temperature),
    uvm_enum_wrapper#(activity_e)::from_name("HOT", activity));
    ok = uvm_enum_wrapper#(temperature_e)::from_name("COLD", temperature);
    $display("UT: repeated success %0d exact %0d", ok, temperature == COLD);

    $finish;
  end

endmodule
