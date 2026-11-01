/*
:name: test_tlm_fifo_failed_try_peek_preserves_object_handle_before_success
:description: failed nonblocking peek preserves a caller sentinel before a successful control (IEEE 1800.2-2020 Section 12.2.4.2.8)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.4.2.8 12.2.4.2.6 12.2.8.2.3 12.2.8.2.4 12.2.4.2.4 1800-2023 13.5
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_failed_try_peek_preserves_object_handle_before_success.expected
*/
// Preserve the standard's unchanged-output requirement despite the method's
// output formal. A successful call separately establishes a live FIFO.
module test_tlm_fifo_failed_try_peek_preserves_object_handle_before_success;
  import uvm_pkg::*;
  class item extends uvm_object;
    function new(string name="item"); super.new(name); endfunction
  endclass
  initial begin
    uvm_tlm_fifo#(item) fifo;
    item sentinel;
    item queued;
    item value;
    bit available;
    bit accepted;
    fifo = new("fifo", null, 2);
    sentinel = new("sentinel");
    queued = new("queued");
    value = sentinel;
    available = fifo.try_peek(value);
    $display("UT: failed %0d preserved %0d used %0d", !available, value == sentinel,
             fifo.used());
    accepted = fifo.try_put(queued);
    value = sentinel;
    available = fifo.try_peek(value);
    $display("UT: accepted %0d succeeded %0d returned %0d used %0d", accepted, available,
             value == queued, fifo.used());
    $finish;
  end
endmodule
