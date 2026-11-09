/*
:name: test_register_access_wrapper_body_uses_live_declared_child_for_selected_targets
:description: Original child audits live uvm_reg_access_seq slot and routing during body
:tags: uE uvm
:type: simulation
:lrm: 1800.2-2020 E.3.2.3.2 E.3.2.2.2 E.3.1 19.5.2.2 19.5.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 8.3.1.4.2 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.3 18.2.3.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_access_wrapper_body_uses_live_declared_child_for_selected_targets.expected
*/
// What it checks:
// 1. The protected reg_seq slot stores a uvm_reg_single_access_seq handle for
//    the selected wrapper.
// 2. The register-access body executes its selected per-register sequence.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 E.3.2.2.2 (UVM-BUILTIN-AUDIT-CHILD-REGISTER-ACCESS) gives
//    rule 1 above. Setup: Original derived accessors use the literal prototype
//    member name and exact child type, assign/replace/clear the selected slot
//    and capture a peer baseline; separate original factory children audit
//    live routing. The live access probes attach original per-target storage
//    backdoors before starting, satisfying access-test eligibility; their
//    routing-only child bodies do not invoke those handlers. Expected:
//    Selected storage matches, the prior child remains valid and the peer
//    remains unchanged; live probes require the declared slot to identify the
//    executing child and selected targets.
// 2. 1800.2-2020 E.3.2.3.2 (UVM-BUILTIN-AUDIT-BODY-REGISTER-ACCESS) gives rule
//    2 above. Setup: Use the selected model and legal sequence start; original
//    factory children audit live slots/target identity, while unchanged
//    full-algorithm fixtures remain separate controls where their citations
//    differ. The live access probes attach original per-target storage
//    backdoors before starting, satisfying access-test eligibility; their
//    routing-only child bodies do not invoke those handlers. Expected: The
//    declared observations identify the selected targets and completion or
//    actual existing reset/selection behavior.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The factory-selected child audits wrapper delegation and target identity.
// It does not certify the builtin access or walking-ones algorithm.
// Original storage backdoors satisfy access-test eligibility; they are not
// invoked by the routing-only factory children.
module test_register_access_wrapper_body_uses_live_declared_child_for_selected_targets;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class block_type extends uvm_reg_block;
    function new(string name); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass
  class register_type extends uvm_reg;
    function new(string name); super.new(name,8,UVM_NO_COVERAGE); endfunction
  endclass
  class memory_type extends uvm_mem;
    function new(string name); super.new(name,4,8,"RW",UVM_NO_COVERAGE); endfunction
  endclass
  class storage_backdoor extends uvm_reg_backdoor;
    uvm_reg_data_t cells[uvm_reg_addr_t];
    function new(string name); super.new(name); endfunction
    virtual task read(uvm_reg_item rw);
      uvm_reg_addr_t location;
      do_pre_read(rw);
      location=rw.get_element_kind()==UVM_MEM ? rw.get_offset() : 0;
      #1;
      rw.set_value(cells.exists(location) ? cells[location] : 0);
      rw.set_status(UVM_IS_OK); do_post_read(rw);
    endtask
    virtual task write(uvm_reg_item rw);
      uvm_reg_addr_t location;
      do_pre_write(rw);
      location=rw.get_element_kind()==UVM_MEM ? rw.get_offset() : 0;
      #1; cells[location]=rw.get_value(0);
      rw.set_status(UVM_IS_OK); do_post_write(rw);
    endtask
  endclass
  typedef class observed_wrapper;
  observed_wrapper active_wrapper;
  uvm_reg targets[2];
  bit slot_ok=1,wrong_target=0;
  bit [1:0] seen=0;
  class child_probe extends uvm_reg_single_access_seq;
    `uvm_object_utils(child_probe)
    function new(string name="child_probe"); super.new(name); endfunction
    virtual task body();
      slot_ok &= active_wrapper.selected_child()==this;
      if (rg==targets[0]) seen[0]=1;
      else if (rg==targets[1]) seen[1]=1;
      else wrong_target=1;
      #1;
    endtask
  endclass
  class observed_wrapper extends uvm_reg_access_seq;
    function new(); super.new("observed_wrapper"); endfunction
    function uvm_reg_single_access_seq selected_child(); return reg_seq; endfunction
  endclass
  initial begin
    block_type block_model;
    register_type first_target,second_target;
    uvm_reg_map selected_map;
    storage_backdoor first_backdoor,second_backdoor;
    uvm_reg_field first_field,second_field;
    uvm_factory factory;
    time started;
    block_model=new("model60"); block_model.configure();
    selected_map=block_model.create_map("selected60",0,1,UVM_LITTLE_ENDIAN);
    first_target=new("first60"); second_target=new("second60");
    first_target.configure(block_model); second_target.configure(block_model);
    first_backdoor=new("first_backdoor"); second_backdoor=new("second_backdoor");
    first_target.set_backdoor(first_backdoor); second_target.set_backdoor(second_backdoor);
    first_field=new("first_field"); second_field=new("second_field");
    first_field.configure(first_target,8,0,"RW",0,0,1,1,0);
    second_field.configure(second_target,8,0,"RW",0,0,1,1,0);
    selected_map.add_reg(first_target,0,"RW"); selected_map.add_reg(second_target,1,"RW");
    targets[0]=first_target; targets[1]=second_target;
    block_model.lock_model(); active_wrapper=new(); active_wrapper.model=block_model;
    factory=uvm_factory::get();
    factory.set_type_override_by_type(uvm_reg_single_access_seq::get_type(),
      child_probe::get_type());
    started=$time; active_wrapper.start(null);
    $display("UT: wrapper_body slot_agrees %0d both_targets %0d no_foreign %0d delayed %0d",
      slot_ok,seen==2'b11,!wrong_target,$time>started);
    $finish;
  end
  initial begin #100; $fatal(1,"wrapper body watchdog expired"); end
endmodule
