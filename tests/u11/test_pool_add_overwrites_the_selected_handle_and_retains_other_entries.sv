/*
:name: test_pool_add_overwrites_the_selected_handle_and_retains_other_entries
:description: pool add replaces one keyed handle without mutating replaced or unrelated objects (11.2.2.5)
:tags: u11 uvm
:type: simulation
:lrm: 1800.2-2020 11.2.2.5 11.2.2.4 11.2.2.6 11.2.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pool_add_overwrites_the_selected_handle_and_retains_other_entries.expected
*/
module test_pool_add_overwrites_the_selected_handle_and_retains_other_entries;
  import uvm_pkg::*;
  class item extends uvm_object;
    int value;
    function new(string name, int number); super.new(name); value = number; endfunction
  endclass
  initial begin
    automatic uvm_pool#(string, item) pool = new("pool");
    automatic item original = new("original", 11);
    automatic item replacement = new("replacement", 22);
    automatic item peer = new("peer", 33);
    item found;
    pool.add("selected", original);
    pool.add("peer", peer);
    pool.add("selected", replacement);
    found = pool.get("selected");
    $display("UT: replacement exact %0d peer %0d count %0d old_value %0d",
             found == replacement, pool.get("peer") == peer, pool.num(), original.value);
    found.value = 91;
    $display("UT: shared_handle value %0d peer_value %0d original_value %0d",
             replacement.value, peer.value, original.value);
    $finish;
  end
endmodule
