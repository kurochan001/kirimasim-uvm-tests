/*
:name: test_string_split_byte_profile_0_100
:description: Current string split preserves byte-delimited fields and replaces caller-owned queues across repeated edge cases
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.3.3.2 1800-2023 6.16 6.16.2 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_string_split_byte_profile_0_100.expected
:files: helpers100/split100.svh
*/
module test_string_split_byte_profile_0_100;
  import uvm_pkg::*;
  localparam int PROFILE100=0;
  localparam byte SEPARATOR100=8'h3a;
  `include "split100.svh"
endmodule
