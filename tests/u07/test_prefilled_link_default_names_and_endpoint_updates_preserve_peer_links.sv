/*
:name: test_prefilled_link_default_names_and_endpoint_updates_preserve_peer_links
:description: prefilled link defaults retain exact endpoints independently across repeated creations (7.3.2.2.2)
:tags: u07 uvm
:type: simulation
:lrm: 1800.2-2020 7.3.2.2.2 7.3.3.2.2 7.3.4.2.2 7.3.1.3.1 7.3.1.3.2 7.3.1.3.3 7.3.1.3.4 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_prefilled_link_default_names_and_endpoint_updates_preserve_peer_links.expected
*/
// Clause 7.3.4.2.2 specifies ce_link in both signature and prose.
// This explicit default is retained independently of implementation spelling.
module test_prefilled_link_default_names_and_endpoint_updates_preserve_peer_links;
  import uvm_pkg::*;
  class endpoint extends uvm_object;
    function new(string name); super.new(name); endfunction
  endclass
  initial begin
    automatic endpoint left_value = new("left");
    automatic endpoint right_value = new("right");
    uvm_link_base first[3], peer[3];
    first[0] = uvm_parent_child_link::get_link(left_value, right_value);
    first[1] = uvm_cause_effect_link::get_link(left_value, right_value);
    first[2] = uvm_related_link::get_link(left_value, right_value);
    peer[0] = uvm_parent_child_link::get_link(right_value, left_value, "peer_pc");
    peer[1] = uvm_cause_effect_link::get_link(right_value, left_value, "peer_ce");
    peer[2] = uvm_related_link::get_link(right_value, left_value, "peer_related");
    $display("UT: default_names %s %s %s", first[0].get_name(), first[1].get_name(),
             first[2].get_name());
    foreach (first[i]) begin
      $display("UT: prefilled %0d exact %0d %0d distinct %0d", i,
               first[i].get_lhs() == left_value, first[i].get_rhs() == right_value,
               first[i] != peer[i]);
      first[i].set_lhs(null); first[i].set_rhs(left_value);
      $display("UT: updated %0d exact %0d %0d peer %0d %0d", i,
               first[i].get_lhs() == null, first[i].get_rhs() == left_value,
               peer[i].get_lhs() == right_value, peer[i].get_rhs() == left_value);
    end
    $finish;
  end
endmodule
