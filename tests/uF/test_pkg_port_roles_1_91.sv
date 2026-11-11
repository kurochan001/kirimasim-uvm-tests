/*
:name: test_pkg_port_roles_1_91
:description: pkg port roles 1 observes named selections through original public-API fixtures
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.3 5.5.1 5.5.2.1 5.5.2.9 5.5.2.10 5.5.2.11 5.5.2.12 12.2.10.1.1 12.2.10.1.3 12.2.10.1.4 12.2.10.2.1 12.2.10.2.2 12.2.10.3.1 1800-2023 6.21 8.20 8.21 9.2 9.4 11.4
:uvm: 2020.3.1
:files: helpers91_ports/port_fixture91.svh
:incdirs: helpers91_ports
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pkg_port_roles_1_91.expected
*/
// What it checks:
// 1. UVM_PORT designates a port requiring its typed interface.
// 2. UVM_EXPORT designates interface provision through a connected export or
//    implementation.
// 3. UVM_IMPLEMENTATION designates an interface bound to its implementing
//    component.
//
// Variant: Inputs 0 and 1 swap which port is selected and which is the peer;
// input 0 sends 23 and -17, input 1 sends 467 and -39.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.2.3 (UVM-PKG-PORT-ROLE-PORT-91) gives rule 1 above. Setup:
//    Two original inputs pass all three typed role designators to a concrete
//    port-base constructor probe and inspect role predicates. Original empty
//    connection-query bodies only complete that subtype. Actual analysis
//    port/export/imp objects separately forward two ordered integer values
//    through opposite selected child providers,with an untouched peer and
//    resolved size checks. Expected: The typed constructor selection reports
//    only is_port and the actual analysis port delivers both values to its
//    connected provider.
// 2. 1800.2-2020 F.2.3 (UVM-PKG-PORT-ROLE-EXPORT-91) gives rule 2 above.
//    Setup: Two original inputs pass all three typed role designators to a
//    concrete port-base constructor probe and inspect role predicates.
//    Original empty connection-query bodies only complete that subtype. Actual
//    analysis port/export/imp objects separately forward two ordered integer
//    values through opposite selected child providers,with an untouched peer
//    and resolved size checks. Expected: The typed constructor selection
//    reports only is_export and the actual export forwards both values to its
//    child implementation.
// 3. 1800.2-2020 F.2.3 (UVM-PKG-PORT-ROLE-IMPLEMENTATION-91) gives rule 3
//    above. Setup: Two original inputs pass all three typed role designators
//    to a concrete port-base constructor probe and inspect role predicates.
//    Original empty connection-query bodies only complete that subtype. Actual
//    analysis port/export/imp objects separately forward two ordered integer
//    values through opposite selected child providers,with an untouched peer
//    and resolved size checks. Expected: The typed constructor selection
//    reports only is_imp and the selected actual implementation calls its
//    original component write method,leaving the peer unchanged.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Typed constructor selections and original analysis forwarding inspect named
// roles. Dummy query bodies only make the constructor probe concrete;actual
// traffic uses standard analysis classes. No enum numeric encoding or generic
// type-name contract is inferred.
module test_pkg_port_roles_1_91;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=1;
  localparam string CASE_NAME="pkg_port_roles_1";
  `include "port_fixture91.svh"
  initial begin #5000; $fatal(1,"typed role/event/topology91 watchdog"); end
endmodule
