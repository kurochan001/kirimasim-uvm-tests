/*
:name: test_tlm2_nonblocking_socket_declarations_preserve_default_and_custom_phase_base_types
:description: tlm2 nonblocking socket declarations preserve default and custom phase base types (IEEE 1800.2-2020 Section 12.3.5.3.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.5.3.1 12.3.5.3 12.3.5.3.3 12.3.5.4 12.3.5.4.1 12.3.5.4.3 12.3.5.5 12.3.5.5.1 12.3.5.5.3 12.3.5.6 12.3.5.6.1 12.3.5.6.3 5.5.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_nonblocking_socket_declarations_preserve_default_and_custom_phase_base_types.expected
*/
// What it checks:
// 1. The selected nonblocking target socket exposes the forward implementation
//    role.
// 2. The nonblocking target socket defaults its transaction type to generic
//    payload.
// 3. The nonblocking target socket supports the selected explicit transaction
//    type through its declared port base.
// 4. The nonblocking socket phase parameter defaults independently to
//    uvm_tlm_phase_e.
// 5. The nonblocking socket supports an explicitly selected custom phase type.
// 6. The selected nonblocking initiator socket exposes the forward port role.
// 7. The nonblocking initiator socket defaults its transaction type to generic
//    payload.
// 8. The nonblocking initiator socket supports the selected explicit
//    transaction type through its declared port base.
// 9. The nonblocking socket phase parameter defaults independently to
//    uvm_tlm_phase_e.
// 10. The nonblocking socket supports an explicitly selected custom phase
//     type.
// 11. The selected nonblocking initiator relay socket exposes the forward port
//     role.
// 12. The nonblocking initiator relay socket defaults its transaction type to
//     generic payload.
// 13. The nonblocking initiator relay socket supports the selected explicit
//     transaction type through its declared port base.
// 14. The nonblocking socket phase parameter defaults independently to
//     uvm_tlm_phase_e.
// 15. The nonblocking socket supports an explicitly selected custom phase
//     type.
// 16. The selected nonblocking target relay socket exposes the forward export
//     role.
// 17. The nonblocking target relay socket defaults its transaction type to
//     generic payload.
// 18. The nonblocking target relay socket supports the selected explicit
//     transaction type through its declared port base.
// 19. The nonblocking socket phase parameter defaults independently to
//     uvm_tlm_phase_e.
// 20. The nonblocking socket supports an explicitly selected custom phase
//     type.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.5.3 (UVM-TLM2-TYPES-SOCKET-3-FORWARD-ROLE) gives rule 1
//    above. Setup: Construct four selected nonblocking socket families with
//    default T/P, custom T only and explicit custom T/P; inspect exact views
//    before binding. Expected: The exact socket view reports its specified
//    role with matching constructor metadata.
// 2. 1800.2-2020 12.3.5.3.1 (UVM-TLM2-TYPES-SOCKET-3-DEFAULT-T) gives rule 2
//    above. Setup: Construct four selected nonblocking socket families with
//    default T/P, custom T only and explicit custom T/P; inspect exact views
//    before binding. Expected: The default family fits the exact
//    generic-payload/standard-phase base.
// 3. 1800.2-2020 12.3.5.3.1 (UVM-TLM2-TYPES-SOCKET-3-CUSTOM-T-BASE) gives rule
//    3 above. Setup: Construct four selected nonblocking socket families with
//    default T/P, custom T only and explicit custom T/P; inspect exact views
//    before binding. Expected: The explicit custom transaction view retains
//    exact type compatibility and selected metadata.
// 4. 1800.2-2020 12.3.5.3.1 (UVM-TLM2-TYPES-SOCKET-3-DEFAULT-P) gives rule 4
//    above. Setup: Construct four selected nonblocking socket families with
//    default T/P, custom T only and explicit custom T/P; inspect exact views
//    before binding. Expected: Both default and T-only selections fit exact
//    standard-phase views.
// 5. 1800.2-2020 12.3.5.3.1 (UVM-TLM2-TYPES-SOCKET-3-CUSTOM-P) gives rule 5
//    above. Setup: Construct four selected nonblocking socket families with
//    default T/P, custom T only and explicit custom T/P; inspect exact views
//    before binding. Expected: Exact custom transaction/phase base arguments
//    accept all four selected socket families.
// 6. 1800.2-2020 12.3.5.4 (UVM-TLM2-TYPES-SOCKET-4-FORWARD-ROLE) gives rule 6
//    above. Setup: Construct four selected nonblocking socket families with
//    default T/P, custom T only and explicit custom T/P; inspect exact views
//    before binding. Expected: The exact socket view reports its specified
//    role with matching constructor metadata.
// 7. 1800.2-2020 12.3.5.4.1 (UVM-TLM2-TYPES-SOCKET-4-DEFAULT-T) gives rule 7
//    above. Setup: Construct four selected nonblocking socket families with
//    default T/P, custom T only and explicit custom T/P; inspect exact views
//    before binding. Expected: The default family fits the exact
//    generic-payload/standard-phase base.
// 8. 1800.2-2020 12.3.5.4.1 (UVM-TLM2-TYPES-SOCKET-4-CUSTOM-T-BASE) gives rule
//    8 above. Setup: Construct four selected nonblocking socket families with
//    default T/P, custom T only and explicit custom T/P; inspect exact views
//    before binding. Expected: The explicit custom transaction view retains
//    exact type compatibility and selected metadata.
// 9. 1800.2-2020 12.3.5.4.1 (UVM-TLM2-TYPES-SOCKET-4-DEFAULT-P) gives rule 9
//    above. Setup: Construct four selected nonblocking socket families with
//    default T/P, custom T only and explicit custom T/P; inspect exact views
//    before binding. Expected: Both default and T-only selections fit exact
//    standard-phase views.
// 10. 1800.2-2020 12.3.5.4.1 (UVM-TLM2-TYPES-SOCKET-4-CUSTOM-P) gives rule 10
//     above. Setup: Construct four selected nonblocking socket families with
//     default T/P, custom T only and explicit custom T/P; inspect exact views
//     before binding. Expected: Exact custom transaction/phase base arguments
//     accept all four selected socket families.
// 11. 1800.2-2020 12.3.5.5 (UVM-TLM2-TYPES-SOCKET-5-FORWARD-ROLE) gives rule
//     11 above. Setup: Construct four selected nonblocking socket families
//     with default T/P, custom T only and explicit custom T/P; inspect exact
//     views before binding. Expected: The exact socket view reports its
//     specified role with matching constructor metadata.
// 12. 1800.2-2020 12.3.5.5.1 (UVM-TLM2-TYPES-SOCKET-5-DEFAULT-T) gives rule 12
//     above. Setup: Construct four selected nonblocking socket families with
//     default T/P, custom T only and explicit custom T/P; inspect exact views
//     before binding. Expected: The default family fits the exact
//     generic-payload/standard-phase base.
// 13. 1800.2-2020 12.3.5.5.1 (UVM-TLM2-TYPES-SOCKET-5-CUSTOM-T-BASE) gives
//     rule 13 above. Setup: Construct four selected nonblocking socket
//     families with default T/P, custom T only and explicit custom T/P;
//     inspect exact views before binding. Expected: The explicit custom
//     transaction view retains exact type compatibility and selected metadata.
// 14. 1800.2-2020 12.3.5.5.1 (UVM-TLM2-TYPES-SOCKET-5-DEFAULT-P) gives rule 14
//     above. Setup: Construct four selected nonblocking socket families with
//     default T/P, custom T only and explicit custom T/P; inspect exact views
//     before binding. Expected: Both default and T-only selections fit exact
//     standard-phase views.
// 15. 1800.2-2020 12.3.5.5.1 (UVM-TLM2-TYPES-SOCKET-5-CUSTOM-P) gives rule 15
//     above. Setup: Construct four selected nonblocking socket families with
//     default T/P, custom T only and explicit custom T/P; inspect exact views
//     before binding. Expected: Exact custom transaction/phase base arguments
//     accept all four selected socket families.
// 16. 1800.2-2020 12.3.5.6 (UVM-TLM2-TYPES-SOCKET-6-FORWARD-ROLE) gives rule
//     16 above. Setup: Construct four selected nonblocking socket families
//     with default T/P, custom T only and explicit custom T/P; inspect exact
//     views before binding. Expected: The exact socket view reports its
//     specified role with matching constructor metadata.
// 17. 1800.2-2020 12.3.5.6.1 (UVM-TLM2-TYPES-SOCKET-6-DEFAULT-T) gives rule 17
//     above. Setup: Construct four selected nonblocking socket families with
//     default T/P, custom T only and explicit custom T/P; inspect exact views
//     before binding. Expected: The default family fits the exact
//     generic-payload/standard-phase base.
// 18. 1800.2-2020 12.3.5.6.1 (UVM-TLM2-TYPES-SOCKET-6-CUSTOM-T-BASE) gives
//     rule 18 above. Setup: Construct four selected nonblocking socket
//     families with default T/P, custom T only and explicit custom T/P;
//     inspect exact views before binding. Expected: The explicit custom
//     transaction view retains exact type compatibility and selected metadata.
// 19. 1800.2-2020 12.3.5.6.1 (UVM-TLM2-TYPES-SOCKET-6-DEFAULT-P) gives rule 19
//     above. Setup: Construct four selected nonblocking socket families with
//     default T/P, custom T only and explicit custom T/P; inspect exact views
//     before binding. Expected: Both default and T-only selections fit exact
//     standard-phase views.
// 20. 1800.2-2020 12.3.5.6.1 (UVM-TLM2-TYPES-SOCKET-6-CUSTOM-P) gives rule 20
//     above. Setup: Construct four selected nonblocking socket families with
//     default T/P, custom T only and explicit custom T/P; inspect exact views
//     before binding. Expected: Exact custom transaction/phase base arguments
//     accept all four selected socket families.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Construct selected default and explicit typed sockets before resolution.
// Exact interface-base arguments check declared T/P defaults and inheritance;
// metadata checks select roles, bounds, names and actual parents. Terminator
// IMP is explicitly a compatible component type; nominal IMP=int and literal
// connect-signature/default-phase wording are not certified by these probes.
module test_tlm2_nonblocking_socket_declarations_preserve_default_and_custom_phase_base_types;
  import uvm_pkg::*;
  typedef enum {LOCAL_BEGIN,LOCAL_END} local_phase;
  class message extends uvm_object;
    function new(); super.new("message"); endfunction
  endclass
  class endpoint#(type T=uvm_tlm_generic_payload,type P=uvm_tlm_phase_e) extends uvm_component;
    function new(string name); super.new(name,null); endfunction
    task b_transport(T value,uvm_tlm_time delay); endtask
    function uvm_tlm_sync_e nb_transport_fw(T value,ref P phase,input uvm_tlm_time delay);
      return UVM_TLM_COMPLETED;
    endfunction
    function uvm_tlm_sync_e nb_transport_bw(T value,ref P phase,input uvm_tlm_time delay);
      return UVM_TLM_COMPLETED;
    endfunction
  endclass
  function automatic bit inspect_default(uvm_port_base#(uvm_tlm_if#(
      uvm_tlm_generic_payload,uvm_tlm_phase_e)) value,
                                          uvm_component owner,string name,int role);
    return value != null && value.get_parent() == owner && value.get_name() == name &&
           value.min_size() == 1 && value.max_size() == 1 &&
           (role == 0 ? value.is_imp() : role == 1 ? value.is_port() : value.is_export());
  endfunction
  function automatic bit inspect_request_only(uvm_port_base#(uvm_tlm_if#(message,
      uvm_tlm_phase_e)) value,
                                          uvm_component owner,string name,int role);
    return value != null && value.get_parent() == owner && value.get_name() == name &&
           value.min_size() == 1 && value.max_size() == 1 &&
           (role == 0 ? value.is_imp() : role == 1 ? value.is_port() : value.is_export());
  endfunction
  function automatic bit inspect_custom(uvm_port_base#(uvm_tlm_if#(message,local_phase)) value,
                                          uvm_component owner,string name,int role);
    return value != null && value.get_parent() == owner && value.get_name() == name &&
           value.min_size() == 1 && value.max_size() == 1 &&
           (role == 0 ? value.is_imp() : role == 1 ? value.is_port() : value.is_export());
  endfunction
  initial begin
    automatic bit ok = 1;
    automatic endpoint owner_default = new("owner_default");
    automatic uvm_tlm_nb_target_socket#(endpoint) default_target =
        new("default_target",owner_default);
    automatic uvm_tlm_nb_initiator_socket#(endpoint) default_initiator =
        new("default_initiator",owner_default);
    automatic uvm_tlm_nb_passthrough_initiator_socket#() default_passthrough_initiator =
        new("default_passthrough_initiator",owner_default);
    automatic uvm_tlm_nb_passthrough_target_socket#() default_passthrough_target =
        new("default_passthrough_target",owner_default);
    automatic endpoint#(message,uvm_tlm_phase_e) owner_request_only = new("owner_request_only");
    automatic uvm_tlm_nb_target_socket#(endpoint#(message,uvm_tlm_phase_e),
      message) request_only_target =
        new("request_only_target",owner_request_only);
    automatic uvm_tlm_nb_initiator_socket#(endpoint#(message,uvm_tlm_phase_e),
      message) request_only_initiator =
        new("request_only_initiator",owner_request_only);
    automatic uvm_tlm_nb_passthrough_initiator_socket#(message) request_only_passthrough_initiator =
        new("request_only_passthrough_initiator",owner_request_only);
    automatic uvm_tlm_nb_passthrough_target_socket#(message) request_only_passthrough_target =
        new("request_only_passthrough_target",owner_request_only);
    automatic endpoint#(message,local_phase) owner_custom = new("owner_custom");
    automatic uvm_tlm_nb_target_socket#(endpoint#(message,local_phase),message,
      local_phase) custom_target =
        new("custom_target",owner_custom);
    automatic uvm_tlm_nb_initiator_socket#(endpoint#(message,local_phase),message,
      local_phase) custom_initiator =
        new("custom_initiator",owner_custom);
    automatic uvm_tlm_nb_passthrough_initiator_socket#(message,
      local_phase) custom_passthrough_initiator =
        new("custom_passthrough_initiator",owner_custom);
    automatic uvm_tlm_nb_passthrough_target_socket#(message,local_phase) custom_passthrough_target =
        new("custom_passthrough_target",owner_custom);
    ok = 1;
    ok &= inspect_default(default_target,owner_default,"default_target",0);
    ok &= inspect_default(default_initiator,owner_default,"default_initiator",1);
    ok &= inspect_default(default_passthrough_initiator,owner_default,
      "default_passthrough_initiator",1);
    ok &= inspect_default(default_passthrough_target,owner_default,"default_passthrough_target",2);
    $display("UT: socket_default count 4 exact_types_and_metadata %0d",ok);
    ok = 1;
    ok &= inspect_request_only(request_only_target,owner_request_only,"request_only_target",0);
    ok &= inspect_request_only(request_only_initiator,owner_request_only,
      "request_only_initiator",1);
    ok &= inspect_request_only(request_only_passthrough_initiator,owner_request_only,
      "request_only_passthrough_initiator",1);
    ok &= inspect_request_only(request_only_passthrough_target,owner_request_only,
      "request_only_passthrough_target",2);
    $display("UT: socket_request_only count 4 exact_types_and_metadata %0d",ok);
    ok = 1;
    ok &= inspect_custom(custom_target,owner_custom,"custom_target",0);
    ok &= inspect_custom(custom_initiator,owner_custom,"custom_initiator",1);
    ok &= inspect_custom(custom_passthrough_initiator,owner_custom,
      "custom_passthrough_initiator",1);
    ok &= inspect_custom(custom_passthrough_target,owner_custom,"custom_passthrough_target",2);
    $display("UT: socket_custom count 4 exact_types_and_metadata %0d",ok);
    $finish;
  end
endmodule
