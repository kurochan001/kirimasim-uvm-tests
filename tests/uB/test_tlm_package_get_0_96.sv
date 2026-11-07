/*
:name: test_tlm_package_get_0_96
:description: Identical suffix arguments in separate packages create distinct generated TLM classes and route actual resolved calls independently
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.5 B.5.5 12.2.4.2.6 12.2.4.2.7 12.2.7.1 12.2.5.1 5.5.2.4 5.5.2.16 B.2.1.3 F.7.3.1 1800-2023 6.21 6.22.1 6.24.2 8.16 8.20 8.21 13.5.2 26.3
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers96_declarations/declaration_packages96.sv helpers96_get/get_fixture96.svh
:expected_exit: 0
:expected_stdout: @test_tlm_package_get_0_96.expected
*/
module test_tlm_package_get_0_96;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT96=0;
  `include "get_fixture96.svh"
endmodule
