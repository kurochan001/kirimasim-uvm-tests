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
