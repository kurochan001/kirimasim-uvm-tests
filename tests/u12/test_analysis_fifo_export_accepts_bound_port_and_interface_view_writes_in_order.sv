/*
:name: test_analysis_fifo_export_accepts_bound_port_and_interface_view_writes_in_order
:description: analysis fifo export accepts bound port and interface view writes in order (IEEE 1800.2-2020 Section 12.2.8.3.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.3.1 12.2.8.3 12.2.8.3.2 12.2.4.2.12 12.2.10.1.4 12.2.8.1.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_analysis_fifo_export_accepts_bound_port_and_interface_view_writes_in_order.expected
*/
// What it checks:
// The analysis FIFO export accepts writes from connected ports and its public
// interface.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.2.8.3.1 (UVM-TLM1-REVIEW-ANALYSIS-FIFO-EXPORT-WRITE) gives
// the rule above. Setup: Write thirteen via a bound analysis port and
// forty-one via the export interface view. Expected: Both writes complete
// without time advance and are retrieved in arrival order.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Actual analysis and get ports bind the FIFO; a public interface view invokes
// the same write interface directly. Writes are nonblocking and preserve
// arrival
// order. No concrete imp type, zero-capacity is_full interpretation or
// physical
// bus traffic is asserted.
module test_analysis_fifo_export_accepts_bound_port_and_interface_view_writes_in_order;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_analysis_fifo#(int) subject;
    uvm_analysis_port#(int) writer;
    uvm_get_port#(int) reader;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); subject = new("subject",this);
      writer = new("writer",this); reader = new("reader",this);
    endfunction
    function void connect_phase(uvm_phase phase);
      writer.connect(subject.analysis_export); reader.connect(subject.get_peek_export);
    endfunction
    task run_phase(uvm_phase phase);
      automatic uvm_tlm_if_base#(int,int) interface_view = subject.analysis_export;
      time started;
      int first,second;
      phase.raise_objection(this); started = $time;
      writer.write(13); interface_view.write(41);
      $display("UT: analysis_fifo_writes view %0d immediate %0d size %0d used %0d",
               interface_view != null,$time == started,subject.size(),subject.used());
      reader.get(first); reader.get(second);
      $display("UT: analysis_fifo_read values %0d/%0d used %0d empty %0d",first,second,
               subject.used(),subject.is_empty());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1,"analysis FIFO watchdog expired"); end
endmodule
