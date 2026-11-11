/*
:name: test_register_fifo_predict_updates_the_abstract_queue_for_selected_write_and_read_kinds
:description: register fifo predict updates the abstract queue for selected write and read kinds
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.8.5.7 18.8.2 18.8.5.3 18.8.5.4 18.4.4.15 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_fifo_predict_updates_the_abstract_queue_for_selected_write_and_read_kinds.expected
*/
// What it checks:
// 1. Selected write-kind predictions append values to the mirrored FIFO.
// 2. Selected read-kind prediction consumes the expected mirrored FIFO front.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.8.5.7 (UVM-MEM-FIFO-AUDIT-FIFO-PREDICT-WRITE) gives rule 1
//    above. Setup: Use the public predict API with explicit WRITE/READ kinds
//    and nonempty valid within-capacity state; apply the FIFO write/read
//    contract to these selected kinds. Expected: Two write predictions retain
//    ordered values 0x11 and 0x22.
// 2. 1800.2-2020 18.8.5.7 (UVM-MEM-FIFO-AUDIT-FIFO-PREDICT-READ) gives rule 2
//    above. Setup: Use the public predict API with explicit WRITE/READ kinds
//    and nonempty valid within-capacity state; apply the FIFO write/read
//    contract to these selected kinds. Expected: Predicting the first read
//    leaves only 0x22.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_register_fifo_predict_updates_the_abstract_queue_for_selected_write_and_read_kinds;
  import uvm_pkg::*;
  initial begin
    uvm_reg_fifo chosen;
    bit first_ok,second_ok,read_ok;
    chosen=new("chosen63",4,8,UVM_NO_COVERAGE);
    first_ok=chosen.predict('h11,.kind(UVM_PREDICT_WRITE));
    second_ok=chosen.predict('h22,.kind(UVM_PREDICT_WRITE));
    $display("UT: fifo_predict writes %0d ordered %0d",
      first_ok && second_ok,chosen.fifo.size()==2 && chosen.fifo[0]=='h11 && chosen.fifo[1]=='h22);
    read_ok=chosen.predict('h11,.kind(UVM_PREDICT_READ));
    $display("UT: fifo_predict read %0d remaining %0d",
      read_ok,chosen.fifo.size()==1 && chosen.fifo[0]=='h22);
    $finish;
  end
endmodule
