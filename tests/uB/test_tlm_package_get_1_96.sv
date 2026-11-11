/*
:name: test_tlm_package_get_1_96
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
:expected_stdout: @test_tlm_package_get_1_96.expected
*/
// What it checks:
// 1. The declaration macro supplies a suffix-specific implementation type for
//    nonblocking get.
// 2. Selected implementation-declaration macro invocations in separate
//    packages create distinct generated class types even with identical suffix
//    arguments.
//
// Variant: Inputs 0 and 1 create the two owners in opposite orders and make
// the calls in opposite orders; input 0 takes the interface views with
// get_if() and uses values from 13, input 1 takes them with get_if(0) and adds
// 100 to every value.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 B.5.5 (UVM-TLM-NONBLOCKING-GET-IMP-DECL) gives rule 1 above.
//    Setup: Instantiate two suffixes with independent modeled handlers and
//    exercise their declared interface methods. Expected: Recorded arguments,
//    successful outputs and readiness/acceptance results where applicable
//    belong to the selected suffix.
// 2. 1800.2-2020 B.5 (UVM-TLM-IMP-DECL-PACKAGE-NOMINAL-ISOLATION-96) gives
//    rule 2 above. Setup: Use two original lexical packages, each declaring
//    blocking-put and nonblocking-get classes for both _shared96 and plain96
//    suffixes. Actual connected ordinary ports resolve generated imps owned by
//    two original components; reverse owner-component construction and
//    selected call order, use default/indexed interface views and int/class
//    transaction types. Expected: The exact generated class names are usable
//    with supplied suffix spelling; interface views retain selected imp/parent
//    identity, and cross-package or cross-suffix downcasts fail. Independently
//    selected handlers retain actual argument/output histories.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_tlm_package_get_1_96;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT96=1;
  `include "get_fixture96.svh"
endmodule
