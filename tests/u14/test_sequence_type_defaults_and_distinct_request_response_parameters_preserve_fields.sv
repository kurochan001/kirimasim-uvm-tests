/*
:name: test_sequence_type_defaults_and_distinct_request_response_parameters_preserve_fields
:description: sequence type defaults and distinct request response parameters preserve fields (IEEE 1800.2-2020 Section 14.3.1)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.3.1 14.3 14.3.2.1 14.3.2.2 14.2.1 1800-2023 6.21 18.5 18.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_type_defaults_and_distinct_request_response_parameters_preserve_fields.expected
*/
// Exact generic base assignments check REQ and RSP defaults at compile time;
// public fields check supplied handle identity. No transfer protocol, invalid
// parameter rejection or fixed random values are inferred.
module test_sequence_type_defaults_and_distinct_request_response_parameters_preserve_fields;
  import uvm_pkg::*;
  class request_packet extends uvm_sequence_item;
    function new(); super.new("request"); endfunction
  endclass
  class response_packet extends uvm_sequence_item;
    function new(); super.new("response"); endfunction
  endclass
  class all_defaults extends uvm_sequence#(); task body(); endtask endclass
  class same_response extends uvm_sequence#(request_packet); task body(); endtask endclass
  class distinct_response extends uvm_sequence#(request_packet, response_packet);
    task body(); endtask
  endclass
  initial begin
    automatic all_defaults first = new();
    automatic same_response second = new();
    automatic distinct_response third = new();
    automatic request_packet request = new();
    automatic request_packet other_request = new();
    automatic response_packet response = new();
    automatic uvm_sequence#(uvm_sequence_item,uvm_sequence_item) default_view = first;
    automatic uvm_sequence#(request_packet,request_packet) same_view = second;
    automatic uvm_sequence_base base_view = third;
    first.req = request; first.rsp = response;
    second.req = request; second.rsp = other_request;
    third.req = request; third.rsp = response;
    $display("UT: default_types identity %0d req %0d rsp %0d", default_view == first,
             default_view.req == request, default_view.rsp == response);
    $display("UT: default_response identity %0d req %0d rsp %0d", same_view == second,
             same_view.req == request, same_view.rsp == other_request);
    $display("UT: distinct_types base %0d req %0d rsp %0d", base_view == third,
             third.req == request, third.rsp == response);
    $finish;
  end
endmodule
