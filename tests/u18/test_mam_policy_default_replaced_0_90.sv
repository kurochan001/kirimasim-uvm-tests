/*
:name: test_mam_policy_default_replaced_0_90
:description: mam policy default replaced 0 checks independently derived manager or printed backdoor contracts
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.3 18.12.5.2 18.12.8 18.12.8.1 18.12.8.2.1 18.12.8.2.2 18.12.8.2.3 18.12.8.2.4 18.12.8.2.5 18.12.4.1 18.12.5.1 18.12.5.4 18.12.6.2 18.12.7.2.1 18.12.7.2.2 18.12.7.2.3 18.12.7.2.4 1800-2023 6.21 8.20 18.5 18.6
:uvm: 2020.3.1
:files: helpers90_policy/policy_fixture90.svh
:incdirs: helpers90_policy
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mam_policy_default_replaced_0_90.expected
*/
// What it checks:
// 1. Replacing default_alloc selects the replacement policy for subsequent
//    omitted-policy requests.
// 2. The selected policy receives the request length in complete memory
//    locations.
// 3. The policy minimum offset describes the configured managed-space minimum
//    before randomization.
// 4. The policy maximum offset describes the configured managed-space maximum
//    before randomization.
// 5. The policy in_use queue identifies the regions already allocated when
//    that request is randomized.
//
// Variant: Input 0 uses one byte per location at offset 0; input 1 uses two
// bytes per location at offset 64 and requests one byte less than three
// locations.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.12.3 (UVM-MAM-DEFAULT-POLICY-REPLACEMENT-90) gives rule 1
//    above. Setup: Use original constrained policies on two layouts:64
//    locations at base0/64 with1/2bytes per location. A live reservation
//    remains while three requests observe selected pre/post randomization
//    hooks without an exact retry count. Hook snapshots compare rounded
//    request length,configured bounds and unordered prior-region membership.
//    Fixed starts remove sampling assumptions;previous endpoints and an
//    independent peer are checked. Expected: Every replacement receives the
//    selected request context and is randomized to its fixed start while
//    earlier reservations remain available.
// 2. 1800.2-2020 18.12.8.2.1 (UVM-MAM-POLICY-ROUNDED-LEN-90) gives rule 2
//    above. Setup: Use original constrained policies on two layouts:64
//    locations at base0/64 with1/2bytes per location. A live reservation
//    remains while three requests observe selected pre/post randomization
//    hooks without an exact retry count. Hook snapshots compare rounded
//    request length,configured bounds and unordered prior-region membership.
//    Fixed starts remove sampling assumptions;previous endpoints and an
//    independent peer are checked. Expected: Pre-randomize snapshots see three
//    locations for three bytes on one-byte locations and five requested bytes
//    on two-byte locations.
// 3. 1800.2-2020 18.12.8.2.3 (UVM-MAM-POLICY-MINIMUM-CONTEXT-90) gives rule 3
//    above. Setup: Use original constrained policies on two layouts:64
//    locations at base0/64 with1/2bytes per location. A live reservation
//    remains while three requests observe selected pre/post randomization
//    hooks without an exact retry count. Hook snapshots compare rounded
//    request length,configured bounds and unordered prior-region membership.
//    Fixed starts remove sampling assumptions;previous endpoints and an
//    independent peer are checked. Expected: Each selected callback sees the
//    layout minimum0 or64,including repeated,replaced,explicit and
//    contradictory-policy requests.
// 4. 1800.2-2020 18.12.8.2.4 (UVM-MAM-POLICY-MAXIMUM-CONTEXT-90) gives rule 4
//    above. Setup: Use original constrained policies on two layouts:64
//    locations at base0/64 with1/2bytes per location. A live reservation
//    remains while three requests observe selected pre/post randomization
//    hooks without an exact retry count. Hook snapshots compare rounded
//    request length,configured bounds and unordered prior-region membership.
//    Fixed starts remove sampling assumptions;previous endpoints and an
//    independent peer are checked. Expected: Each selected callback sees
//    base+63 rather than an unrelated peer range or a stale configuration.
// 5. 1800.2-2020 18.12.8.2.5 (UVM-MAM-POLICY-IN-USE-CONTEXT-90) gives rule 5
//    above. Setup: Use original constrained policies on two layouts:64
//    locations at base0/64 with1/2bytes per location. A live reservation
//    remains while three requests observe selected pre/post randomization
//    hooks without an exact retry count. Hook snapshots compare rounded
//    request length,configured bounds and unordered prior-region membership.
//    Fixed starts remove sampling assumptions;previous endpoints and an
//    independent peer are checked. Expected: Pre-randomize snapshots match
//    prior live handles by membership and cardinality without fixing queue
//    order,and failed allocation adds no live handle.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original constrained-policy hooks observe selected policy, contextual inputs
// and region preservation; no private algorithm or exact retry count.
module test_mam_policy_default_replaced_0_90;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  localparam int MODE=1;
  localparam int LAYOUT=0;
  localparam string CASE_NAME="mam_policy_default_replaced_0";
  `include "policy_fixture90.svh"
  initial begin #5000; $fatal(1,"manager/backdoor90 watchdog"); end
endmodule
