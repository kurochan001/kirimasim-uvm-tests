/*
:name: test_tlm_fifo_exports_expose_combined_methods_through_public_interface_views
:description: tlm fifo exports expose combined methods through public interface views (IEEE 1800.2-2020 Section 12.2.8.1.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.1.3 12.2.8.1.4 12.2.4.1 12.2.4.2.1 12.2.4.2.2 12.2.4.2.3 12.2.4.2.4 12.2.4.2.5 12.2.4.2.6 12.2.4.2.7 12.2.4.2.8 12.2.4.2.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_exports_expose_combined_methods_through_public_interface_views.expected
*/
// What it checks:
// 1. The public FIFO put export provides blocking and nonblocking put methods.
// 2. The public FIFO get/peek export provides its combined
//    blocking/nonblocking methods.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.2.8.1.3 (UVM-TLM1-REVIEW-FIFO-PUT-EXPORT-METHODS) gives
//    rule 1 above. Setup: Use its interface-base view for actual put, try_put
//    and can_put operations. Expected: Both insertions reach storage and
//    capacity availability changes accordingly.
// 2. 1800.2-2020 12.2.8.1.4 (UVM-TLM1-REVIEW-FIFO-GET-PEEK-EXPORT-METHODS)
//    gives rule 2 above. Setup: Use a public interface view for get/peek,
//    try_get/try_peek and their availability queries on held entries.
//    Expected: Peeks retain thirteen; gets consume thirteen then twenty-seven;
//    used reaches zero.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use public FIFO export members as interface-base views, exercising actual
// blocking and nonblocking method delegation. Both data types are explicitly
// int. Do not assert implementation class names, failed outputs, analysis
// notification counts or private FIFO storage.
module test_tlm_fifo_exports_expose_combined_methods_through_public_interface_views;
  import uvm_pkg::*;
  initial begin
    automatic uvm_tlm_fifo#(int) subject = new("subject",null,2);
    automatic uvm_tlm_if_base#(int,int) put_view = subject.put_export;
    automatic uvm_tlm_if_base#(int,int) get_view = subject.get_peek_export;
    bit accepted,peeked,removed;
    int first,second,value;
    put_view.put(13); accepted = put_view.try_put(27);
    $display("UT: fifo_export_put nonnull %0d accepted %0d full_capacity %0d used %0d",
             put_view != null,accepted,!put_view.can_put(),subject.used());
    get_view.peek(first); peeked = get_view.try_peek(second);
    $display(
      "UT: fifo_export_peek nonnull %0d values %0d/%0d success %0d get %0d peek %0d used %0d",
             get_view != null,first,second,peeked,get_view.can_get(),get_view.can_peek(),
             subject.used());
    get_view.get(first); removed = get_view.try_get(value);
    $display("UT: fifo_export_get values %0d/%0d success %0d used %0d can_put %0d",
             first,value,removed,subject.used(),put_view.can_put());
    $finish;
  end
endmodule
