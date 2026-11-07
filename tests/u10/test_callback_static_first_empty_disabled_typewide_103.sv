/*
:name: test_callback_static_first_empty_disabled_typewide_103
:description: Static callback endpoints handle empty,disabled,foreign-family and selected-context boundaries
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.2.4.1 10.7.2.4.2 10.7.2.4.3 10.7.2.4.4 10.7.2.3.1 10.7.2.3.3 10.7.1.1 10.7.1.2.1 10.7.1.2.2 10.7.2.2.1 10.7.2.2.2 B.4.1 1800-2023 6.21 8.13 8.16
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers103_static/static103.svh
:expected_exit: 0
:expected_stdout: @test_callback_static_first_empty_disabled_typewide_103.expected
*/
module test_callback_static_first_empty_disabled_typewide_103;
  import uvm_pkg::*;
  localparam int MODE103=0,TYPEWIDE103=1;
  `include "static103.svh"
endmodule
