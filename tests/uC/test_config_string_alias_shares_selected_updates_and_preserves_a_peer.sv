/*
:name: test_config_string_alias_shares_selected_updates_and_preserves_a_peer
:description: config string alias shares selected updates and preserves a peer
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.3.2 C.4.2.2.1 C.4.2.2.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_string_alias_shares_selected_updates_and_preserves_a_peer.expected
*/
module test_config_string_alias_shares_selected_updates_and_preserves_a_peer;
  import uvm_pkg::*;
  initial begin
    string first,second,peer;
    bit found_first,found_second,found_peer;
    uvm_config_string::set(null,"scope62","slot62","first value62");
    uvm_config_db#(string)::set(null,"peer62","slot62","peer value62");
    found_first=uvm_config_db#(string)::get(null,"scope62","slot62",first);
    uvm_config_db#(string)::set(null,"scope62","slot62","");
    found_second=uvm_config_string::get(null,"scope62","slot62",second);
    found_peer=uvm_config_string::get(null,"peer62","slot62",peer);
    $display("UT: config_string exact_type %0d shared_empty %0d peer %0d",
      $typename(uvm_config_string)==$typename(uvm_config_db#(string)),
      found_first && first=="first value62" && found_second && second=="",
      found_peer && peer=="peer value62");
    $finish;
  end
endmodule
