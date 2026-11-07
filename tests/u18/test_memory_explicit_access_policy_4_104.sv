/*
:name: test_memory_explicit_access_policy_4_104
:description: Explicit memory access reflects selected map restrictions or intrinsic ROM policy independently of parent default
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.4.6 18.6.4.5 18.6.4.2 18.6.3.1 18.6.3.2 18.2.3.4 18.1.2.3 18.1.2.4 18.1.2.5 18.1.2.6 1800-2023 6.21 8.13 8.16
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers104_access/access104.svh
:expected_exit: 0
:expected_stdout: @test_memory_explicit_access_policy_4_104.expected
*/
module test_memory_explicit_access_policy_4_104;
  import uvm_pkg::*;
  localparam int CASE104=4,WIDTH104=16,SIZE104=3;
  localparam bit SHARED104=0,ROM104=1;
  `include "access104.svh"
endmodule
