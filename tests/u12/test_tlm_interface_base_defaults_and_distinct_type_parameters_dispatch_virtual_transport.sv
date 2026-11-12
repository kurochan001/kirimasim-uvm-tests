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
// What it checks:
// 1. The omitted interface T1 parameter defaults to int.
// 2. The omitted interface T2 parameter defaults to int.
// 3. The omitted T2 remains int when only T1 is explicitly changed.
// 4. Distinct request and response parameters are supported by the virtual
//    interface.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.2.4.1 (UVM-TLM1-REVIEW-INTERFACE-DEFAULT-T1) gives rule 1
//    above. Setup: Use an original concrete default interface through the
//    exact int/int base. Expected: The base retains identity and dispatches
//    the selected integer request.
// 2. 1800.2-2020 12.2.4.1 (UVM-TLM1-REVIEW-INTERFACE-DEFAULT-T2) gives rule 2
//    above. Setup: Call an original default specialization through an exact
//    integer response interface. Expected: The declared integer response is
//    received through the base.
// 3. 1800.2-2020 12.2.4.1 (UVM-TLM1-REVIEW-INTERFACE-T2-INDEPENDENT-DEFAULT)
//    gives rule 3 above. Setup: An original concrete interface selects string
//    requests and omits T2. Expected: The exact string/int base accepts the
//    instance and returns an integer.
// 4. 1800.2-2020 12.2.4.1 (UVM-TLM1-REVIEW-INTERFACE-DISTINCT-PARAMETERS)
//    gives rule 4 above. Setup: Call an original int/string extension through
//    its exact base specialization. Expected: Identity and the original string
//    response are preserved through virtual dispatch.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original concrete interface extensions expose default T1/T2 and
// independently
// defaulted T2 when T1 changes. Original response algorithms are setup; only
// positive type compatibility and virtual dispatch are checked here. Actual
// standard port/imp transport forwarding has separate fixtures.
module test_tlm_interface_base_defaults_and_distinct_type_parameters_dispatch_virtual_transport;
  import uvm_pkg::*;
  class default_interface extends uvm_tlm_if_base#();
    virtual task transport(input int req,output int rsp);
      #1; rsp = req * 2;
    endtask
  endclass
  class request_interface extends uvm_tlm_if_base#(string);
    virtual task transport(input string req,output int rsp);
      #1; rsp = req.len();
    endtask
  endclass
  class distinct_interface extends uvm_tlm_if_base#(int,string);
    virtual task transport(input int req,output string rsp);
      #1; rsp = $sformatf("rsp:%0d",req);
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
