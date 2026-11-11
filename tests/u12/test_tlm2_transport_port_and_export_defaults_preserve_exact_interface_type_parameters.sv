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
// What it checks:
// 1. The blocking port defaults to the generic payload interface type.
// 2. The blocking port supports the selected explicit transaction type.
// 3. The blocking export defaults to the generic payload interface type.
// 4. The blocking export supports the selected explicit transaction type.
// 5. The nonblocking forward port defaults to the generic payload interface
//    type.
// 6. The nonblocking forward port supports the selected explicit transaction
//    type.
// 7. The nonblocking port defaults its phase type independently of T.
// 8. The nonblocking port supports the selected explicit phase type.
// 9. The nonblocking forward export defaults to the generic payload interface
//    type.
// 10. The nonblocking forward export supports the selected explicit
//     transaction type.
// 11. The nonblocking export defaults its phase type independently of T.
// 12. The nonblocking export supports the selected explicit phase type.
// 13. The nonblocking backward port defaults to the generic payload interface
//     type.
// 14. The nonblocking backward port supports the selected explicit transaction
//     type.
// 15. The nonblocking port defaults its phase type independently of T.
// 16. The nonblocking port supports the selected explicit phase type.
// 17. The nonblocking backward export defaults to the generic payload
//     interface type.
// 18. The nonblocking backward export supports the selected explicit
//     transaction type.
// 19. The nonblocking export defaults its phase type independently of T.
// 20. The nonblocking export supports the selected explicit phase type.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.6.1 (UVM-TLM2-TYPES-PORT-1-DEFAULT-T) gives rule 1
//    above. Setup: Construct all three ordinary port and export families with
//    default, T-only and applicable explicit T/P specializations. Expected:
//    Its default view fits the exact generic-payload/standard-phase port base.
// 2. 1800.2-2020 12.3.6.1 (UVM-TLM2-TYPES-PORT-1-CUSTOM-T) gives rule 2 above.
//    Setup: Construct all three ordinary port and export families with
//    default, T-only and applicable explicit T/P specializations. Expected:
//    The T-only family fits the exact custom-transaction/standard-phase base.
// 3. 1800.2-2020 12.3.7.1 (UVM-TLM2-TYPES-EXPORT-1-DEFAULT-T) gives rule 3
//    above. Setup: Construct all three ordinary port and export families with
//    default, T-only and applicable explicit T/P specializations. Expected:
//    Its default view fits the exact generic-payload/standard-phase port base.
// 4. 1800.2-2020 12.3.7.1 (UVM-TLM2-TYPES-EXPORT-1-CUSTOM-T) gives rule 4
//    above. Setup: Construct all three ordinary port and export families with
//    default, T-only and applicable explicit T/P specializations. Expected:
//    The T-only family fits the exact custom-transaction/standard-phase base.
// 5. 1800.2-2020 12.3.6.2 (UVM-TLM2-TYPES-PORT-2-DEFAULT-T) gives rule 5
//    above. Setup: Construct all three ordinary port and export families with
//    default, T-only and applicable explicit T/P specializations. Expected:
//    Its default view fits the exact generic-payload/standard-phase port base.
// 6. 1800.2-2020 12.3.6.2 (UVM-TLM2-TYPES-PORT-2-CUSTOM-T) gives rule 6 above.
//    Setup: Construct all three ordinary port and export families with
//    default, T-only and applicable explicit T/P specializations. Expected:
//    The T-only family fits the exact custom-transaction/standard-phase base.
// 7. 1800.2-2020 12.3.6.2 (UVM-TLM2-TYPES-PORT-2-DEFAULT-P) gives rule 7
//    above. Setup: Construct all three ordinary port and export families with
//    default, T-only and applicable explicit T/P specializations. Expected:
//    Default and T-only instances fit standard-phase views.
// 8. 1800.2-2020 12.3.6.2 (UVM-TLM2-TYPES-PORT-2-CUSTOM-P) gives rule 8 above.
//    Setup: Construct all three ordinary port and export families with
//    default, T-only and applicable explicit T/P specializations. Expected:
//    Exact custom-T/P views accept the selected nonblocking families.
// 9. 1800.2-2020 12.3.7.2 (UVM-TLM2-TYPES-EXPORT-2-DEFAULT-T) gives rule 9
//    above. Setup: Construct all three ordinary port and export families with
//    default, T-only and applicable explicit T/P specializations. Expected:
//    Its default view fits the exact generic-payload/standard-phase port base.
// 10. 1800.2-2020 12.3.7.2 (UVM-TLM2-TYPES-EXPORT-2-CUSTOM-T) gives rule 10
//     above. Setup: Construct all three ordinary port and export families with
//     default, T-only and applicable explicit T/P specializations. Expected:
//     The T-only family fits the exact custom-transaction/standard-phase base.
// 11. 1800.2-2020 12.3.7.2 (UVM-TLM2-TYPES-EXPORT-2-DEFAULT-P) gives rule 11
//     above. Setup: Construct all three ordinary port and export families with
//     default, T-only and applicable explicit T/P specializations. Expected:
//     Default and T-only instances fit standard-phase views.
// 12. 1800.2-2020 12.3.7.2 (UVM-TLM2-TYPES-EXPORT-2-CUSTOM-P) gives rule 12
//     above. Setup: Construct all three ordinary port and export families with
//     default, T-only and applicable explicit T/P specializations. Expected:
//     Exact custom-T/P views accept the selected nonblocking families.
// 13. 1800.2-2020 12.3.6.3 (UVM-TLM2-TYPES-PORT-3-DEFAULT-T) gives rule 13
//     above. Setup: Construct all three ordinary port and export families with
//     default, T-only and applicable explicit T/P specializations. Expected:
//     Its default view fits the exact generic-payload/standard-phase port
//     base.
// 14. 1800.2-2020 12.3.6.3 (UVM-TLM2-TYPES-PORT-3-CUSTOM-T) gives rule 14
//     above. Setup: Construct all three ordinary port and export families with
//     default, T-only and applicable explicit T/P specializations. Expected:
//     The T-only family fits the exact custom-transaction/standard-phase base.
// 15. 1800.2-2020 12.3.6.3 (UVM-TLM2-TYPES-PORT-3-DEFAULT-P) gives rule 15
//     above. Setup: Construct all three ordinary port and export families with
//     default, T-only and applicable explicit T/P specializations. Expected:
//     Default and T-only instances fit standard-phase views.
// 16. 1800.2-2020 12.3.6.3 (UVM-TLM2-TYPES-PORT-3-CUSTOM-P) gives rule 16
//     above. Setup: Construct all three ordinary port and export families with
//     default, T-only and applicable explicit T/P specializations. Expected:
//     Exact custom-T/P views accept the selected nonblocking families.
// 17. 1800.2-2020 12.3.7.3 (UVM-TLM2-TYPES-EXPORT-3-DEFAULT-T) gives rule 17
//     above. Setup: Construct all three ordinary port and export families with
//     default, T-only and applicable explicit T/P specializations. Expected:
//     Its default view fits the exact generic-payload/standard-phase port
//     base.
// 18. 1800.2-2020 12.3.7.3 (UVM-TLM2-TYPES-EXPORT-3-CUSTOM-T) gives rule 18
//     above. Setup: Construct all three ordinary port and export families with
//     default, T-only and applicable explicit T/P specializations. Expected:
//     The T-only family fits the exact custom-transaction/standard-phase base.
// 19. 1800.2-2020 12.3.7.3 (UVM-TLM2-TYPES-EXPORT-3-DEFAULT-P) gives rule 19
//     above. Setup: Construct all three ordinary port and export families with
//     default, T-only and applicable explicit T/P specializations. Expected:
//     Default and T-only instances fit standard-phase views.
// 20. 1800.2-2020 12.3.7.3 (UVM-TLM2-TYPES-EXPORT-3-CUSTOM-P) gives rule 20
//     above. Setup: Construct all three ordinary port and export families with
//     default, T-only and applicable explicit T/P specializations. Expected:
//     Exact custom-T/P views accept the selected nonblocking families.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
