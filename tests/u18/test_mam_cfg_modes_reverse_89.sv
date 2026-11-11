/*
:name: test_mam_cfg_modes_reverse_89
:description: mam cfg modes reverse observes independently derived enum effects and preserved controls
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.9.2.5 18.12.2.1 18.12.2.2 18.12.9.2.4 18.12.9.2.5 18.12.4.1 18.12.4.2 18.12.5.1 18.12.5.2 18.12.5.3 18.12.6.2 18.12.7.2.1 18.12.7.2.2 18.12.7.2.3 18.12.7.2.4 18.12.8.1 18.12.8.2.2 1800-2023 6.21 8.20 18.5
:uvm: 2020.3.1
:files: helpers89/mam_modes_fixture89.svh
:incdirs: helpers89
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mam_cfg_modes_reverse_89.expected
*/
// What it checks:
// 1. The allocation-mode type supplies GREEDY and THRIFTY as distinct named
//    selections.
// 2. The locality type supplies BROAD and NEARBY as distinct named selections.
// 3. The configuration mode field retains and replaces the selected typed
//    allocation mode independently of its peer.
// 4. The configuration locality field retains and replaces the selected typed
//    region-locality mode independently of its peer.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.12.2.1 (UVM-MAM-ALLOC-MODE-DESIGNATORS-89) gives rule 1
//    above. Setup: Two configuration instances use typed allocation/locality
//    fields and opposite GREEDY/BROAD versus THRIFTY/NEARBY starting pairs.
//    Compatible reconfiguration keeps bounds and one-byte locations
//    unchanged,returns previous/current handles and preserves the peer and the
//    exact active-region endpoints. No mode/locality behavior is inferred from
//    readback alone. Expected: Both enum pairs are distinct named
//    designators;typed selected/replaced values and original/peer
//    configuration identities match,with the existing region unchanged.
// 2. 1800.2-2020 18.12.2.2 (UVM-MAM-LOCALITY-DESIGNATORS-89) gives rule 2
//    above. Setup: Two configuration instances use typed allocation/locality
//    fields and opposite GREEDY/BROAD versus THRIFTY/NEARBY starting pairs.
//    Compatible reconfiguration keeps bounds and one-byte locations
//    unchanged,returns previous/current handles and preserves the peer and the
//    exact active-region endpoints. No mode/locality behavior is inferred from
//    readback alone. Expected: Both enum pairs are distinct named
//    designators;typed selected/replaced values and original/peer
//    configuration identities match,with the existing region unchanged.
// 3. 1800.2-2020 18.12.9.2.4 (UVM-MAM-CONFIG-MODE-89) gives rule 3 above.
//    Setup: Two configuration instances use typed allocation/locality fields
//    and opposite GREEDY/BROAD versus THRIFTY/NEARBY starting pairs.
//    Compatible reconfiguration keeps bounds and one-byte locations
//    unchanged,returns previous/current handles and preserves the peer and the
//    exact active-region endpoints. No mode/locality behavior is inferred from
//    readback alone. Expected: Both enum pairs are distinct named
//    designators;typed selected/replaced values and original/peer
//    configuration identities match,with the existing region unchanged.
// 4. 1800.2-2020 18.12.9.2.5 (UVM-MAM-CONFIG-LOCALITY-89) gives rule 4 above.
//    Setup: Two configuration instances use typed allocation/locality fields
//    and opposite GREEDY/BROAD versus THRIFTY/NEARBY starting pairs.
//    Compatible reconfiguration keeps bounds and one-byte locations
//    unchanged,returns previous/current handles and preserves the peer and the
//    exact active-region endpoints. No mode/locality behavior is inferred from
//    readback alone. Expected: Both enum pairs are distinct named
//    designators;typed selected/replaced values and original/peer
//    configuration identities match,with the existing region unchanged.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_mam_cfg_modes_reverse_89;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=1;
  localparam string CASE_NAME="mam_cfg_modes_reverse";
  `include "mam_modes_fixture89.svh"
  initial begin #5000; $fatal(1,"allocation or ordering89 watchdog"); end
endmodule
