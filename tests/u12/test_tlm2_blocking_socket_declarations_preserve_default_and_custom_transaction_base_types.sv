/*
:name: test_tlm2_blocking_socket_declarations_preserve_default_and_custom_transaction_base_types
:description: tlm2 blocking socket declarations preserve default and custom transaction base types (IEEE 1800.2-2020 Section 12.3.5.1.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.5.1.1 12.3.5.1 12.3.5.1.3 12.3.5.2 12.3.5.2.1 12.3.5.2.3 12.3.5.7 12.3.5.7.1 12.3.5.7.3 12.3.5.8 12.3.5.8.1 12.3.5.8.3 5.5.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_blocking_socket_declarations_preserve_default_and_custom_transaction_base_types.expected
*/
// What it checks:
// 1. The selected blocking target socket exposes the forward implementation
//    role.
// 2. The blocking target socket defaults its transaction type to generic
//    payload.
// 3. The blocking target socket supports the selected explicit transaction
//    type through its declared port base.
// 4. The selected blocking initiator socket exposes the forward port role.
// 5. The blocking initiator socket defaults its transaction type to generic
//    payload.
// 6. The blocking initiator socket supports the selected explicit transaction
//    type through its declared port base.
// 7. The selected blocking initiator relay socket exposes the forward port
//    role.
// 8. The blocking initiator relay socket defaults its transaction type to
//    generic payload.
// 9. The blocking initiator relay socket supports the selected explicit
//    transaction type through its declared port base.
// 10. The selected blocking target relay socket exposes the forward export
//     role.
// 11. The blocking target relay socket defaults its transaction type to
//     generic payload.
// 12. The blocking target relay socket supports the selected explicit
//     transaction type through its declared port base.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.5.1 (UVM-TLM2-TYPES-SOCKET-1-FORWARD-ROLE) gives rule 1
//    above. Setup: Construct all four selected blocking socket families with
//    default generic payload or explicit custom transaction types; inspect
//    exact base views before binding. Expected: The exact socket view reports
//    its specified role with matching constructor metadata.
// 2. 1800.2-2020 12.3.5.1.1 (UVM-TLM2-TYPES-SOCKET-1-DEFAULT-T) gives rule 2
//    above. Setup: Construct all four selected blocking socket families with
//    default generic payload or explicit custom transaction types; inspect
//    exact base views before binding. Expected: The default family fits the
//    exact generic-payload/standard-phase base.
// 3. 1800.2-2020 12.3.5.1.1 (UVM-TLM2-TYPES-SOCKET-1-CUSTOM-T-BASE) gives rule
//    3 above. Setup: Construct all four selected blocking socket families with
//    default generic payload or explicit custom transaction types; inspect
//    exact base views before binding. Expected: The explicit custom
//    transaction view retains exact type compatibility and selected metadata.
// 4. 1800.2-2020 12.3.5.2 (UVM-TLM2-TYPES-SOCKET-2-FORWARD-ROLE) gives rule 4
//    above. Setup: Construct all four selected blocking socket families with
//    default generic payload or explicit custom transaction types; inspect
//    exact base views before binding. Expected: The exact socket view reports
//    its specified role with matching constructor metadata.
// 5. 1800.2-2020 12.3.5.2.1 (UVM-TLM2-TYPES-SOCKET-2-DEFAULT-T) gives rule 5
//    above. Setup: Construct all four selected blocking socket families with
//    default generic payload or explicit custom transaction types; inspect
//    exact base views before binding. Expected: The default family fits the
//    exact generic-payload/standard-phase base.
// 6. 1800.2-2020 12.3.5.2.1 (UVM-TLM2-TYPES-SOCKET-2-CUSTOM-T-BASE) gives rule
//    6 above. Setup: Construct all four selected blocking socket families with
//    default generic payload or explicit custom transaction types; inspect
//    exact base views before binding. Expected: The explicit custom
//    transaction view retains exact type compatibility and selected metadata.
// 7. 1800.2-2020 12.3.5.7 (UVM-TLM2-TYPES-SOCKET-7-FORWARD-ROLE) gives rule 7
//    above. Setup: Construct all four selected blocking socket families with
//    default generic payload or explicit custom transaction types; inspect
//    exact base views before binding. Expected: The exact socket view reports
//    its specified role with matching constructor metadata.
// 8. 1800.2-2020 12.3.5.7.1 (UVM-TLM2-TYPES-SOCKET-7-DEFAULT-T) gives rule 8
//    above. Setup: Construct all four selected blocking socket families with
//    default generic payload or explicit custom transaction types; inspect
//    exact base views before binding. Expected: The default family fits the
//    exact generic-payload/standard-phase base.
// 9. 1800.2-2020 12.3.5.7.1 (UVM-TLM2-TYPES-SOCKET-7-CUSTOM-T-BASE) gives rule
//    9 above. Setup: Construct all four selected blocking socket families with
//    default generic payload or explicit custom transaction types; inspect
//    exact base views before binding. Expected: The explicit custom
//    transaction view retains exact type compatibility and selected metadata.
// 10. 1800.2-2020 12.3.5.8 (UVM-TLM2-TYPES-SOCKET-8-FORWARD-ROLE) gives rule
//     10 above. Setup: Construct all four selected blocking socket families
//     with default generic payload or explicit custom transaction types;
//     inspect exact base views before binding. Expected: The exact socket view
//     reports its specified role with matching constructor metadata.
// 11. 1800.2-2020 12.3.5.8.1 (UVM-TLM2-TYPES-SOCKET-8-DEFAULT-T) gives rule 11
//     above. Setup: Construct all four selected blocking socket families with
//     default generic payload or explicit custom transaction types; inspect
//     exact base views before binding. Expected: The default family fits the
//     exact generic-payload/standard-phase base.
// 12. 1800.2-2020 12.3.5.8.1 (UVM-TLM2-TYPES-SOCKET-8-CUSTOM-T-BASE) gives
//     rule 12 above. Setup: Construct all four selected blocking socket
//     families with default generic payload or explicit custom transaction
//     types; inspect exact base views before binding. Expected: The explicit
//     custom transaction view retains exact type compatibility and selected
//     metadata.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Construct selected default and explicit typed sockets before resolution.
// Exact interface-base arguments check declared T/P defaults and inheritance;
// metadata checks select roles, bounds, names and actual parents. Terminator
// IMP is explicitly a compatible component type; nominal IMP=int and literal
// connect-signature/default-phase wording are not certified by these probes.
module test_tlm2_blocking_socket_declarations_preserve_default_and_custom_transaction_base_types;
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
  function automatic bit inspect_custom(uvm_port_base#(uvm_tlm_if#(message,uvm_tlm_phase_e)) value,
                                          uvm_component owner,string name,int role);
    return value != null && value.get_parent() == owner && value.get_name() == name &&
           value.min_size() == 1 && value.max_size() == 1 &&
           (role == 0 ? value.is_imp() : role == 1 ? value.is_port() : value.is_export());
  endfunction
  initial begin
    automatic bit ok = 1;
    automatic endpoint owner_default = new("owner_default");
    automatic uvm_tlm_b_target_socket#(endpoint) default_target =
        new("default_target",owner_default);
    automatic uvm_tlm_b_initiator_socket#() default_initiator =
        new("default_initiator",owner_default);
    automatic uvm_tlm_b_passthrough_initiator_socket#() default_passthrough_initiator =
        new("default_passthrough_initiator",owner_default);
    automatic uvm_tlm_b_passthrough_target_socket#() default_passthrough_target =
        new("default_passthrough_target",owner_default);
    automatic endpoint#(message,uvm_tlm_phase_e) owner_custom = new("owner_custom");
    automatic uvm_tlm_b_target_socket#(endpoint#(message,uvm_tlm_phase_e),message) custom_target =
        new("custom_target",owner_custom);
    automatic uvm_tlm_b_initiator_socket#(message) custom_initiator =
        new("custom_initiator",owner_custom);
    automatic uvm_tlm_b_passthrough_initiator_socket#(message) custom_passthrough_initiator =
        new("custom_passthrough_initiator",owner_custom);
    automatic uvm_tlm_b_passthrough_target_socket#(message) custom_passthrough_target =
        new("custom_passthrough_target",owner_custom);
    ok = 1;
    ok &= inspect_default(default_target,owner_default,"default_target",0);
    ok &= inspect_default(default_initiator,owner_default,"default_initiator",1);
    ok &= inspect_default(default_passthrough_initiator,owner_default,
      "default_passthrough_initiator",1);
    ok &= inspect_default(default_passthrough_target,owner_default,"default_passthrough_target",2);
    $display("UT: socket_default count 4 exact_types_and_metadata %0d",ok);
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
