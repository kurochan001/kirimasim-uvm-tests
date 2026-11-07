/*
:name: test_random_stability_split_0_97
:description: Selected UVM calls without user hooks preserve relative caller and selected receiver RNG streams
:tags: u01 uvm
:type: simulation
:lrm: 1800.2-2020 1.4.6 F.3.3.2 1800-2023 6.21 9.7 18.6.1 18.13.1 18.13.4 18.13.5 18.14
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers97/rng_stability97.svh
:expected_exit: 0
:expected_stdout: @test_random_stability_split_0_97.expected
*/
module test_random_stability_split_0_97;
  import uvm_pkg::*;
  localparam int FAMILY97=0;
  localparam int VARIANT97=0;
  localparam string FAMILY_NAME97="split";
  localparam string LABEL97="beacon97";
  `include "rng_stability97.svh"
endmodule
