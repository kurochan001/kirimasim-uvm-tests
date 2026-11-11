/*
:name: test_reg_order_policy_getter_replacement_and_clear_are_map_local
:description: map transaction-order policy queries retain selection replacement and clearing (IEEE 1800.2-2020 Section 18.2.5.4)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.5.4 18.2.5.5 18.4.2.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_order_policy_getter_replacement_and_clear_are_map_local.expected
*/
// What it checks:
// 1. Map order-policy queries return the selected handle or explicit null.
// 2. Order-policy selection, replacement and clearing affect only the selected
//    map.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.2.5.4 (UVM-MAP-ORDER-POLICY-EXACT-QUERY) gives rule 1
//    above. Setup: Select first/second policies on two maps, replace one and
//    clear it. Expected: Every query returns the exact configured handle and
//    clearing returns null.
// 2. 1800.2-2020 18.2.5.5 (UVM-MAP-ORDER-POLICY-LOCAL-SELECTION) gives rule 2
//    above. Setup: Keep a peer map set to second while replacing/clearing
//    first. Expected: The selected map tracks changes while the peer retains
//    second.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Inspect configured policy handles before any bus access.
// Explicit null removes the selected policy; no default type is assumed.
module test_reg_order_policy_getter_replacement_and_clear_are_map_local;
  import uvm_pkg::*;

  `include "uvm_macros.svh"
  class address_order extends uvm_reg_transaction_order_policy;
    bit descending = 1;
    int calls = 0;
    int last_size = 0;
    bit widths_match = 1;
    bit kinds_match = 1;
    uvm_access_e expected_kind = UVM_WRITE;
    function new(string name="order"); super.new(name); endfunction
    virtual function void order(ref uvm_reg_bus_op q[$]);
      uvm_reg_bus_op temporary;
      calls++; last_size = q.size();
      foreach (q[i]) begin
        widths_match &= q[i].n_bits == 8;
        kinds_match &= q[i].kind == expected_kind;
      end
      for (int i=0; i<q.size(); i++) begin
        for (int j=i+1; j<q.size(); j++) begin
          if (descending ? q[i].addr < q[j].addr : q[i].addr > q[j].addr) begin
            temporary = q[i]; q[i] = q[j]; q[j] = temporary;
          end
        end
      end
    endfunction
  endclass
  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    uvm_reg_field field;
    function new(); super.new("r", 32, UVM_NO_COVERAGE); endfunction
    function void build();
      field = new("value"); field.configure(this, 32, 0, "RW", 0, 0, 1, 0, 1);
    endfunction
  endclass

  initial begin
    automatic model_block blk = new();
    automatic address_order first = new("first");
    automatic address_order second = new("second");
    uvm_reg_map mapping;
    uvm_reg_map peer;
    blk.configure(); mapping = blk.create_map("map", 0, 1, UVM_LITTLE_ENDIAN);
    peer = blk.create_map("peer", 0, 1, UVM_LITTLE_ENDIAN);
    mapping.set_transaction_order_policy(first); peer.set_transaction_order_policy(second);
    $display("UT: selected first %0d peer_second %0d",
    mapping.get_transaction_order_policy() == first, peer.get_transaction_order_policy() == second);
    mapping.set_transaction_order_policy(second);
    $display("UT: replaced exact %0d peer_stable %0d",
    mapping.get_transaction_order_policy() == second,
    peer.get_transaction_order_policy() == second);
    mapping.set_transaction_order_policy(null);
    $display("UT: cleared null %0d peer_stable %0d",
    mapping.get_transaction_order_policy() == null, peer.get_transaction_order_policy() == second);
    $finish;
  end

endmodule
