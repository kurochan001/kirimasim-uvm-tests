/*
:name: test_policy_extension_controls_copy_user_hook
:description: an extension visible through the field operation policy can gate the copy hook (IEEE 1800.2-2020 Section 16.1.2.3.3)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.1.2.3.3 16.6.4.1 5.3.13 5.7.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_policy_extension_controls_copy_user_hook.expected
*/
// The object reads a gate extension during do_execute_op. Updating that
// extension in place enables a later copy without reinstalling the extension.

module test_policy_extension_controls_copy_user_hook;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class limit_ext extends uvm_object;
    `uvm_object_utils(limit_ext)
    int threshold = 0;
    function new(string name="limit_ext"); super.new(name); endfunction
  endclass
  class derived_limit_ext extends limit_ext;
    `uvm_object_utils(derived_limit_ext)
    function new(string name="derived_limit_ext"); super.new(name); endfunction
  endclass
  class flag_ext extends uvm_object;
    `uvm_object_utils(flag_ext)
    bit enabled = 1;
    function new(string name="flag_ext"); super.new(name); endfunction
  endclass

  class item extends uvm_object;
    `uvm_object_utils(item)
    int payload = 0;
    int copies = 0;
    function new(string name="item"); super.new(name); endfunction
    function void do_copy(uvm_object rhs);
      item source;
      super.do_copy(rhs);
      if (!$cast(source, rhs)) $fatal(1, "copy type");
      payload = source.payload;
      copies++;
    endfunction
  endclass

  class gated_item extends item;
    `uvm_object_utils(gated_item)
    function new(string name="gated_item"); super.new(name); endfunction
    function void do_execute_op(uvm_field_op op);
      uvm_policy policy;
      flag_ext gate;
      super.do_execute_op(op);
      if (op.get_op_type() == UVM_COPY) begin
        policy = op.get_policy();
        if ($cast(gate, policy.get_extension(flag_ext::get_type())) && gate != null)
          if (!gate.enabled) op.disable_user_hook();
      end
    endfunction
  endclass
  initial begin
    automatic uvm_copier policy = new;
    automatic gated_item source = new("source");
    automatic gated_item target = new("target");
    automatic flag_ext gate = new;
    uvm_object previous;
    source.payload = 7;
    target.payload = 1;
    policy.copy_object(target, source);
    $display("UT: no_extension payload %0d copies %0d", target.payload, target.copies);
    gate.enabled = 0;
    previous = policy.set_extension(gate);
    source.payload = 9;
    policy.copy_object(target, source);
    $display("UT: gated payload %0d copies %0d", target.payload, target.copies);
    gate.enabled = 1;
    source.payload = 11;
    policy.copy_object(target, source);
    $display("UT: enabled payload %0d copies %0d", target.payload, target.copies);
    $finish;
  end
endmodule
