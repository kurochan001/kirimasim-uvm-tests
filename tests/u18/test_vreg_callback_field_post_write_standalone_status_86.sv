/*
:name: test_vreg_callback_field_post_write_standalone_status_86
:description: Virtual callback field_post_write_standalone_status checks actual public dispatch and preserved modeled storage
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.10.5.2 18.9.1.4.1 18.9.1.4.2 18.9.1.4.3 18.9.1.4.4 18.9.2.2.1 18.9.2.2.2 18.9.2.2.3 18.9.2.2.4 18.10.5.1 18.10.5.3 18.10.5.4 18.10.6.2.1 18.10.6.2.2 18.10.6.2.3 18.10.6.2.4 18.9.1.1.2 18.10.2.1 18.10.2.2 18.9.1.3.1 18.9.1.3.2 18.10.4.1 18.10.4.2 18.6.9.1 18.6.9.2 18.6.9.3 18.6.9.4 18.6.6.2 18.6.7.2 19.4.2.2.1 19.4.2.3 19.5.2.6 19.5.2.7 D.4.5.9 D.4.5.11 10.7.2.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:files: helpers86/callback_fixture86.svh
:incdirs: helpers86
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=observe86
:expected_exit: 0
:expected_stdout: @test_vreg_callback_field_post_write_standalone_status_86.expected
*/
// What it checks:
// 1. A virtual-field post_write method can change the returned status through
//    parent-register and standalone-field write calls.
// 2. A standalone virtual-field post_write method executes after the
//    corresponding memory post-write hook.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.10.5.2 (UVM-VREG-CALLBACK-FIELD-POST-WRITE-STATUS-86)
//    gives rule 1 above. Setup: Original 16-bit memory-backed virtual
//    registers have one 4-bit field at LSB4 and selected indices0/2 of a
//    static three-element array. Two healthy map-specific original frontdoors
//    and one original user backdoor contain different independently
//    seeded16-bit words. Each index first reads all three routes with edits
//    disabled. Actual virtual/registered callbacks then edit one selected
//    data/path/map/status or record first/last events for the selected
//    read/write kind. Memory callbacks of the other kind are outside those
//    ordering predicates. Parent-register and standalone-field calls are
//    distinct inputs. No real HDL, bus driver or protocol implementation is
//    involved. The standalone partial-write input explicitly installs a user
//    backdoor aliased to its selected frontdoor bank after separate route
//    controls; this keeps read-modify-write state coherent. Its initial
//    independent-bank inputs and diagnostic/control logs are archived and
//    excluded. Expected: A virtual-field post_write method can change the
//    returned status through parent-register and standalone-field write calls.
// 2. 1800.2-2020 18.10.5.2
//    (UVM-VREG-CALLBACK-FIELD-POST-WRITE-AFTER-MEMORY-86) gives rule 2 above.
//    Setup: Original 16-bit memory-backed virtual registers have one 4-bit
//    field at LSB4 and selected indices0/2 of a static three-element array.
//    Two healthy map-specific original frontdoors and one original user
//    backdoor contain different independently seeded16-bit words. Each index
//    first reads all three routes with edits disabled. Actual
//    virtual/registered callbacks then edit one selected data/path/map/status
//    or record first/last events for the selected read/write kind. Memory
//    callbacks of the other kind are outside those ordering predicates.
//    Parent-register and standalone-field calls are distinct inputs. No real
//    HDL, bus driver or protocol implementation is involved. The standalone
//    partial-write input explicitly installs a user backdoor aliased to its
//    selected frontdoor bank after separate route controls; this keeps
//    read-modify-write state coherent. Its initial independent-bank inputs and
//    diagnostic/control logs are archived and excluded. Expected: A standalone
//    virtual-field post_write method executes after the corresponding memory
//    post-write hook.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original banks provide distinct healthy routes without a physical bus or HDL.
// Literal pre-read order probes keep the incompatible clause readings separate.
module test_vreg_callback_field_post_write_standalone_status_86;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=15;
  localparam string CASE_NAME="field_post_write_standalone_status";
  `include "callback_fixture86.svh"
  class alias_back86 extends uvm_reg_backdoor;
    front86 provider;
    function new(); super.new("alias86"); endfunction
    virtual task read(uvm_reg_item rw);
      #1;
      if (rw.get_offset()>=32) begin rw.set_status(UVM_NOT_OK); return; end
      rw.set_value(uvm_reg_data_t'(provider.words[rw.get_offset()]));
      rw.set_status(UVM_IS_OK);
    endtask
    virtual task write(uvm_reg_item rw);
      #1;
      if (rw.get_offset()>=32) begin rw.set_status(UVM_NOT_OK); return; end
      provider.words[rw.get_offset()]=rw.get_value(0); rw.set_status(UVM_IS_OK);
    endtask
  endclass
  class observe86 extends test86;
    `uvm_component_utils(observe86)
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual task run_phase(uvm_phase phase);
      automatic alias_back86 alias_bd=new();
      uvm_status_e status;
      uvm_reg_data_t value,prior_a[32],prior_b[32],prior_c[32];
      int address;
      bit controls,storage_ok,post_ok;
      phase.raise_objection(this);
      memory.set_frontdoor(first_fd,first_map); memory.set_frontdoor(second_fd,second_map);
      alias_bd.provider=first_fd; post_ok=1;
      for (int slot=0;slot<2;slot++) begin
        slot86=slot; selected86=(slot==0 ? 0 : 2); address=3+4*selected86;
        for (int i=0;i<32;i++) begin
          first_fd.words[i]=16'h1000 ^ (i*16'h31);
          second_fd.words[i]=16'h5000 ^ (i*16'h53);
          back.words[i]=16'hc000 ^ (i*16'h79);
        end
        first_fd.words[address]=original86(0,slot);
        second_fd.words[address]=original86(1,slot);
        back.words[address]=original86(2,slot);
        active86=0; memory.set_backdoor(back);
        vr.read(selected86,status,value,UVM_FRONTDOOR,first_map);
        controls=status==UVM_IS_OK && (value & 'hffff)==original86(0,slot);
        vr.read(selected86,status,value,UVM_FRONTDOOR,second_map);
        controls &= status==UVM_IS_OK && (value & 'hffff)==original86(1,slot);
        vr.read(selected86,status,value,UVM_BACKDOOR,first_map);
        controls &= status==UVM_IS_OK && (value & 'hffff)==original86(2,slot);
        // The observed partial write uses coherent frontdoor/backdoor storage.
        memory.set_backdoor(alias_bd);
        for (int i=0;i<32;i++) begin
          prior_a[i]=first_fd.words[i]; prior_b[i]=second_fd.words[i]; prior_c[i]=back.words[i];
        end
        serial86=0; indices86=1;
        foreach (first86[i]) begin first86[i]=0; last86[i]=0; end
        write86=1; active86=1;
        vf.write(selected86,status,field_edit86(slot),UVM_FRONTDOOR,first_map);
        active86=0; storage_ok=1;
        for (int i=0;i<32;i++) begin
          if (i!=address) storage_ok &= first_fd.words[i]==prior_a[i];
          storage_ok &= second_fd.words[i]==prior_b[i] && back.words[i]==prior_c[i];
        end
        post_ok &= before86(5,9);
        $display("UT: vcb86 %s idx %0d controls %0d",CASE_NAME,selected86,controls);
        $display("UT: vcb86 status %0d data %0d storage %0d",
          status==UVM_NOT_OK,first_fd.words[address]==field_result86(slot),storage_ok);
        $display("UT: vcb86 hook %0d indices %0d",first86[9]>0,indices86);
      end
      $display("DBG: vcb86 raw_after_status %04h",first_fd.words[11]);
      $display("UT: vcb86 standalone_post_after_memory %0d",post_ok);
      active86=0; first_fd.words[11]=16'h2d94;
      vf.write(2,status,'h5,UVM_FRONTDOOR,first_map);
      $display("UT: vcb86 standalone_control status %0d data %0d",
        status==UVM_IS_OK,first_fd.words[11]==16'h2d54);
      $display("DBG: vcb86 raw_control %04h",first_fd.words[11]);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("observe86");
  initial begin #5000; $fatal(1,"virtual callback86 watchdog"); end
endmodule
