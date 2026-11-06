/*
:name: test_enum_state_severity_name_inverse_84
:description: The enum wrapper inverts each declared severity name without fixing numeric encodings
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.3.4 F.3.4.1 F.3.4.2 F.2.2.1 1800-2023 6.21 6.19.5 8.20 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_enum_state_severity_name_inverse_84.expected
*/
// Standard-derived observations; no enum bit positions or report layout fixed.
module test_enum_state_severity_name_inverse_84;
  import uvm_pkg::*;
  initial begin
    automatic uvm_severity kinds[4]='{UVM_INFO,UVM_WARNING,UVM_ERROR,UVM_FATAL};
    automatic string names[4]='{"UVM_INFO","UVM_WARNING","UVM_ERROR","UVM_FATAL"};
    automatic bit exact=1,named=1;
    uvm_severity value;
    foreach(kinds[i]) begin
      exact &= uvm_enum_wrapper#(uvm_severity)::from_name(names[i],value) && value==kinds[i];
      named &= kinds[i].name()==names[i];
    end
    $display("UT: severity84 inverse exact %0d named %0d",exact,named);
    $display("UT: severity84 inverse case_rejected %0d",
      !uvm_enum_wrapper#(uvm_severity)::from_name("uvm_info",value));
    $finish;
  end
endmodule
