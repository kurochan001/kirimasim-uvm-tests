/*
:name: test_tlm_interface_base_defaults_and_distinct_type_parameters_dispatch_virtual_transport
:description: tlm interface base defaults and distinct type parameters dispatch virtual transport (IEEE 1800.2-2020 Section 12.2.4.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.4.1 12.2.4.2.10 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_interface_base_defaults_and_distinct_type_parameters_dispatch_virtual_transport.expected
*/
// Original concrete interface extensions expose default T1/T2 and
// independently
// defaulted T2 when T1 changes. Original response algorithms are setup; only
// positive type compatibility and virtual dispatch are checked here. Actual
// standard port/imp transport forwarding has separate fixtures.
module test_tlm_interface_base_defaults_and_distinct_type_parameters_dispatch_virtual_transport;
  import uvm_pkg::*;
  class default_interface extends uvm_tlm_if_base#();
    virtual task transport(input int request,output int response);
      #1; response = request * 2;
    endtask
  endclass
  class request_interface extends uvm_tlm_if_base#(string);
    virtual task transport(input string request,output int response);
      #1; response = request.len();
    endtask
  endclass
  class distinct_interface extends uvm_tlm_if_base#(int,string);
    virtual task transport(input int request,output string response);
      #1; response = $sformatf("rsp:%0d",request);
    endtask
  endclass
  initial begin
    automatic default_interface first = new();
    automatic request_interface second = new();
    automatic distinct_interface third = new();
    automatic uvm_tlm_if_base#(int,int) default_view = first;
    automatic uvm_tlm_if_base#(string,int) request_view = second;
    automatic uvm_tlm_if_base#(int,string) distinct_view = third;
    int number;
    string text;
    default_view.transport(13,number);
    $display("UT: interface_default identity %0d response %0d",default_view == first,number);
    request_view.transport("hello",number);
    $display("UT: interface_request_only identity %0d response %0d",request_view == second,number);
    distinct_view.transport(27,text);
    $display("UT: interface_distinct identity %0d response %0d",distinct_view == third,
             text == "rsp:27");
    $finish;
  end
endmodule
