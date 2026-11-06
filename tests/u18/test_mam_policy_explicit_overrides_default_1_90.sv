/*
:name: test_mam_policy_explicit_overrides_default_1_90
:description: mam policy explicit overrides default 1 checks independently derived manager or printed backdoor contracts
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.5.2 18.12.3 18.12.8 18.12.8.1 18.12.8.2.1 18.12.8.2.2 18.12.8.2.3 18.12.8.2.4 18.12.8.2.5 18.12.4.1 18.12.5.1 18.12.5.4 18.12.6.2 18.12.7.2.1 18.12.7.2.2 18.12.7.2.3 18.12.7.2.4 1800-2023 6.21 8.20 18.5 18.6
:uvm: 2020.3.1
:files: helpers90_policy/policy_fixture90.svh
:incdirs: helpers90_policy
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mam_policy_explicit_overrides_default_1_90.expected
*/
// Original constrained-policy hooks observe selected policy, contextual inputs
// and region preservation; no private algorithm or exact retry count.
module test_mam_policy_explicit_overrides_default_1_90;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  localparam int MODE=2;
  localparam int LAYOUT=1;
  localparam string CASE_NAME="mam_policy_explicit_overrides_default_1";
  `include "policy_fixture90.svh"
  initial begin #5000; $fatal(1,"manager/backdoor90 watchdog"); end
endmodule
