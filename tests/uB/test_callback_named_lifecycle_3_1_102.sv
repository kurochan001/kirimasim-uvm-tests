/*
:name: test_callback_named_lifecycle_3_1_102
:description: Named callback registration, disabled deletion and re-registration preserve per-object macro dispatch and reference arguments
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.4 B.4.1 B.4.3 B.4.4 10.7.1.1 10.7.1.2.1 10.7.1.2.2 10.7.1.2.3 10.7.2.1 10.7.2.2.1 10.7.2.2.2 10.7.2.3.1 10.7.2.3.2 10.7.2.3.4 13.1.2.1 13.1.3.2 F.7.4.1 F.3.3.1 1.4 1800-2023 6.21 8.13 8.16 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers102_named/named102.svh
:expected_exit: 0
:expected_stdout: @test_callback_named_lifecycle_3_1_102.expected
*/
module test_callback_named_lifecycle_3_1_102;
  import uvm_pkg::*;
  localparam int SCENARIO102=3,VARIANT102=1;
  `include "named102.svh"
endmodule
