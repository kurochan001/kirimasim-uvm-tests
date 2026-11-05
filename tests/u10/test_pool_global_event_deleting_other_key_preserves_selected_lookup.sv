/*
:name: test_pool_global_event_deleting_other_key_preserves_selected_lookup
:description: Deleting another global key leaves the selected existing key lookup intact.
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.4.1.2.3 10.4.1.1 10.4.1.2.1 10.4.1.2.2 10.4.1.2.4 11.2.1 11.2.2.3 11.2.2.5 11.2.2.7 11.2.2.8 5.3.4.1 5.3.4.2 10.1.1.2.7 10.1.1.2.8 10.1.1.2.10 10.1.2.2.4 10.3.2.1 10.3.2.2 10.3.2.5 10.3.2.6 10.3.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pool_global_event_deleting_other_key_preserves_selected_lookup.expected
*/
// Original observations; printed pool/item return premises stay separate.
module
  test_pool_global_event_deleting_other_key_preserves_selected_lookup;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
initial begin
    automatic uvm_event_pool global_pool=uvm_event_pool::get_global_pool();
    automatic uvm_event subject=new("subject71");
    automatic uvm_event selected;
    automatic uvm_event peer=new("peer71");
    global_pool.add("selected71",subject);global_pool.add("peer71",peer);
    global_pool.delete("peer71");selected=uvm_event_pool::get_global("selected71");
    $display("UT: event_delete_peer identity %0d peer_absent %0d",
      selected==subject,!global_pool.exists("peer71"));
    $finish;
  end
endmodule
