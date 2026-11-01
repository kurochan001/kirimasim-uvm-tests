/*
:name: test_reg_field_write_one_set_read_clear_prediction_preserves_peer_through_write_read_cycles
:description: W1SRC prediction applies repeated writes and reads while preserving an adjacent field (IEEE 1800.2-2020 Section 18.5.5.17)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.17 18.5.4.6 18.5.3.2 18.5.5.1 18.5.5.3 18.5.5.4 18.4.4.3 18.4.2.1 18.4.2.2 18.1.2.1 18.1.2.2 17.2.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_field_write_one_set_read_clear_prediction_preserves_peer_through_write_read_cycles.expected
*/
// Explicit prediction values represent selected bus observations. No physical
// bus transfer is performed. An adjacent field provides an isolation control.
module test_reg_field_write_one_set_read_clear_prediction_preserves_peer_through_write_read_cycles;
  import uvm_pkg::*;
  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(); super.new("r", 16, UVM_NO_COVERAGE); endfunction
  endclass
  initial begin
    automatic model_block blk = new();
    automatic model_reg rg = new();
    automatic uvm_reg_field selected = new("selected");
    automatic uvm_reg_field peer = new("peer");
    bit accepted;
    blk.configure(); rg.configure(blk);
    selected.configure(rg, 8, 0, "W1SRC", 0, 'ha5, 1, 0, 1);
    peer.configure(rg, 8, 8, "RW", 0, 'h69, 1, 0, 1);
    rg.reset();
    accepted = selected.predict('hf, -1, UVM_PREDICT_WRITE);
    $display("UT: 1 w ok %0d desired %0h mirror %0h peer %0h assembled %0h", accepted,
             selected.get(), selected.get_mirrored_value(), peer.get_mirrored_value(),
             rg.get_mirrored_value());
    accepted = selected.predict('h30, -1, UVM_PREDICT_WRITE);
    $display("UT: 2 w ok %0d desired %0h mirror %0h peer %0h assembled %0h", accepted,
             selected.get(), selected.get_mirrored_value(), peer.get_mirrored_value(),
             rg.get_mirrored_value());
    accepted = selected.predict('hbf, -1, UVM_PREDICT_READ);
    $display("UT: 3 r ok %0d desired %0h mirror %0h peer %0h assembled %0h", accepted,
             selected.get(), selected.get_mirrored_value(), peer.get_mirrored_value(),
             rg.get_mirrored_value());
    accepted = selected.predict('h81, -1, UVM_PREDICT_WRITE);
    $display("UT: 4 w ok %0d desired %0h mirror %0h peer %0h assembled %0h", accepted,
             selected.get(), selected.get_mirrored_value(), peer.get_mirrored_value(),
             rg.get_mirrored_value());
    accepted = selected.predict('h81, -1, UVM_PREDICT_READ);
    $display("UT: 5 r ok %0d desired %0h mirror %0h peer %0h assembled %0h", accepted,
             selected.get(), selected.get_mirrored_value(), peer.get_mirrored_value(),
             rg.get_mirrored_value());
    $finish;
  end
endmodule
