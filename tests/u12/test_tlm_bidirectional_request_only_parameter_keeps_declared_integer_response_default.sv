/*
:name: test_tlm_bidirectional_request_only_parameter_keeps_declared_integer_response_default
:description: tlm bidirectional request only parameter keeps declared integer response default (IEEE 1800.2-2020 Section 12.2.3.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.3.3 12.2.5.1 12.2.5.2 12.2.4.1 5.5.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_bidirectional_request_only_parameter_keeps_declared_integer_response_default.expected
*/
// What it checks:
// The declared RSP default stays int when only REQ is overridden.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.2.3.3 (UVM-TLM1-REVIEW-BIDIRECTIONAL-RSP-INDEPENDENT-DEFAULT)
// gives the rule above. Setup: Instantiate nine selected ports with string REQ
// and omit RSP, using exact string/int base arguments. Expected: The
// standard-declared specializations compile and retain constructor metadata.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Constructor/type inspection before binding resolution. Selected regular
// port families use their declared default types and 1/1 bounds; analysis
// ports
// have a separate constructor contract. The printed tlm_if_base alias and
// complete imp parameter list in the summary are not certified. No successful
// end-of-elaboration binding or transport execution is inferred from this
// probe.
module test_tlm_bidirectional_request_only_parameter_keeps_declared_integer_response_default;
  import uvm_pkg::*;
  class owner extends uvm_component;
    function new(); super.new("owner",null); endfunction
  endclass
  function automatic bit inspect(uvm_port_base#(uvm_tlm_if_base#(string,int)) selected,
                                 uvm_component parent_value,string name);
    return selected != null && selected.is_port() && selected.get_parent() == parent_value &&
           selected.get_name() == name && selected.min_size() == 1 && selected.max_size() == 1;
  endfunction
  initial begin
    automatic owner parent_value = new();
    automatic bit ok = 1;
    automatic uvm_transport_port#(string) p0 = new("p0",parent_value);
    automatic uvm_blocking_transport_port#(string) p1 = new("p1",parent_value);
    automatic uvm_nonblocking_transport_port#(string) p2 = new("p2",parent_value);
    automatic uvm_blocking_master_port#(string) p3 = new("p3",parent_value);
    automatic uvm_nonblocking_master_port#(string) p4 = new("p4",parent_value);
    automatic uvm_master_port#(string) p5 = new("p5",parent_value);
    automatic uvm_blocking_slave_port#(string) p6 = new("p6",parent_value);
    automatic uvm_nonblocking_slave_port#(string) p7 = new("p7",parent_value);
    automatic uvm_slave_port#(string) p8 = new("p8",parent_value);
    ok &= inspect(p0,parent_value,"p0");
    ok &= inspect(p1,parent_value,"p1");
    ok &= inspect(p2,parent_value,"p2");
    ok &= inspect(p3,parent_value,"p3");
    ok &= inspect(p4,parent_value,"p4");
    ok &= inspect(p5,parent_value,"p5");
    ok &= inspect(p6,parent_value,"p6");
    ok &= inspect(p7,parent_value,"p7");
    ok &= inspect(p8,parent_value,"p8");
    $display("UT: port_declarations count 9 defaults_and_metadata %0d",ok);
    $finish;
  end
endmodule
