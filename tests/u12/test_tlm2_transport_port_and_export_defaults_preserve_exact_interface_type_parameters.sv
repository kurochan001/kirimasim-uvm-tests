/*
:name: test_tlm2_transport_port_and_export_defaults_preserve_exact_interface_type_parameters
:description: tlm2 transport port and export defaults preserve exact interface type parameters (IEEE 1800.2-2020 Section 12.3.6.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.6.1 12.3.6.2 12.3.6.3 12.3.7.1 12.3.7.2 12.3.7.3 5.5.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_transport_port_and_export_defaults_preserve_exact_interface_type_parameters.expected
*/
// Positive exact port-base compatibility before binding only. Default generic
// payload/standard phase, T-only and explicit T/P selections are independent
// probes. The apparent backward-path description under the forward-port title
// is not resolved here; real method forwarding has separate fixtures.
module test_tlm2_transport_port_and_export_defaults_preserve_exact_interface_type_parameters;
  import uvm_pkg::*;
  class owner extends uvm_component;
    function new(); super.new("owner",null); endfunction
  endclass
  class message extends uvm_object;
    function new(); super.new("message"); endfunction
  endclass
  typedef enum {LOCAL_BEGIN,LOCAL_END} local_phase;
  function automatic bit inspect_default(
      uvm_port_base#(uvm_tlm_if#(uvm_tlm_generic_payload,uvm_tlm_phase_e)) value);
    return value != null;
  endfunction
  function automatic bit inspect_request(uvm_port_base#(uvm_tlm_if#(message,
      uvm_tlm_phase_e)) value);
    return value != null;
  endfunction
  function automatic bit inspect_custom(uvm_port_base#(uvm_tlm_if#(message,local_phase)) value);
    return value != null;
  endfunction
  initial begin
    automatic owner parent_value = new();
    automatic uvm_tlm_b_transport_port#() bp = new("bp",parent_value);
    automatic uvm_tlm_nb_transport_fw_port#() fp = new("fp",parent_value);
    automatic uvm_tlm_nb_transport_bw_port#() wp = new("wp",parent_value);
    automatic uvm_tlm_b_transport_export#() be = new("be",parent_value);
    automatic uvm_tlm_nb_transport_fw_export#() fe = new("fe",parent_value);
    automatic uvm_tlm_nb_transport_bw_export#() we = new("we",parent_value);
    automatic uvm_tlm_b_transport_port#(message) cbp = new("cbp",parent_value);
    automatic uvm_tlm_nb_transport_fw_port#(message) cfp = new("cfp",parent_value);
    automatic uvm_tlm_nb_transport_bw_port#(message) cwp = new("cwp",parent_value);
    automatic uvm_tlm_b_transport_export#(message) cbe = new("cbe",parent_value);
    automatic uvm_tlm_nb_transport_fw_export#(message) cfe = new("cfe",parent_value);
    automatic uvm_tlm_nb_transport_bw_export#(message) cwe = new("cwe",parent_value);
    automatic uvm_tlm_nb_transport_fw_port#(message,local_phase) xfp = new("xfp",parent_value);
    automatic uvm_tlm_nb_transport_bw_port#(message,local_phase) xwp = new("xwp",parent_value);
    automatic uvm_tlm_nb_transport_fw_export#(message,local_phase) xfe = new("xfe",parent_value);
    automatic uvm_tlm_nb_transport_bw_export#(message,local_phase) xwe = new("xwe",parent_value);
    $display("UT: transport_defaults ports %0d exports %0d",inspect_default(bp) &&
             inspect_default(fp) && inspect_default(wp),inspect_default(be) &&
             inspect_default(fe) && inspect_default(we));
    $display("UT: transport_request_only ports %0d exports %0d",inspect_request(cbp) &&
             inspect_request(cfp) && inspect_request(cwp),inspect_request(cbe) &&
             inspect_request(cfe) && inspect_request(cwe));
    $display("UT: transport_custom_phase ports %0d exports %0d",inspect_custom(xfp) &&
             inspect_custom(xwp),inspect_custom(xfe) && inspect_custom(xwe));
    $finish;
  end
endmodule
