/*
:name: test_vreg_backdoor_model_field_peek_word16_85
:description: Virtual field peek checks selected storage, isolation and debug invariance
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.10.4.4 18.9.1.1.2 18.10.2.1 18.10.2.2 18.6.5.6 18.6.7.2 19.1.1.2.4 19.1.1.2.5 1800-2023 6.21 8.20
:uvm: 2020.3.1
:files: helpers85/vreg_backdoor_fixture85.svh
:incdirs: helpers85
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_backdoor_model_field_peek_word16_85.expected
*/
// Independent literals check two indices and three debug-argument variants.
// Multiword checks retain only order-independent observations.
module test_vreg_backdoor_model_field_peek_word16_85;
  import uvm_pkg::*;
  `include "vreg_backdoor_fixture85.svh"
  localparam int WORDS=1, BASE=3, STRIDE=4;
  initial begin
    automatic block85 owner=new();
    automatic uvm_mem memory=new("memory85",32,16,"RW");
    automatic uvm_vreg vr=new("virtual85",16);
    automatic storage85 storage=new(16);
    uvm_vreg_field vf;
    uvm_reg_map mapping;
    uvm_reg_data_t value,before_words[32];
    uvm_status_e status;
    int idx,address;
    bit selected_ok,isolation_ok;
    owner.configure(); memory.configure(owner); memory.set_backdoor(storage);
    mapping=owner.create_map("map85",0,2,UVM_LITTLE_ENDIAN);
    mapping.add_mem(memory,0);
    vr.configure(owner,memory,3,BASE,STRIDE);
    vf=uvm_vreg_field::type_id::create("selected85");
    vf.configure(vr,9,3);
    owner.lock_model();
    for (int slot=0;slot<2;slot++) begin
      idx=(slot==0 ? 0 : 2); address=BASE+idx*STRIDE;
      for (int variant=0;variant<3;variant++) begin
        for (int i=0;i<32;i++) storage.words[i]=('h8201 ^ (i*'h137)) & 'hffff;
        for (int i=0;i<WORDS;i++) storage.words[address+i]=(slot==0 ? 'hb6d3 : 'h492c);
        for (int i=0;i<32;i++) before_words[i]=storage.words[i];
        #1;
        if (variant==0) vf.peek(idx,status,value);
        else vf.peek(idx,status,value,null,null,
          (variant==1 ? "selected85.sv" : "other85.sv"),(variant==1 ? 8517 : -85));
        #1;
        selected_ok=(value & 'h1ff)==(slot==0 ? 'hda : 'h125);
        isolation_ok=1;
        for (int i=0;i<32;i++) begin
           isolation_ok &= storage.words[i]==before_words[i];
        end
        $display("UT: vreg85 model field_peek_word16 idx %0d debug %0d",
          idx,variant);
        $display("UT: vreg85 status %0d value %0d isolated %0d",
          status==UVM_IS_OK,selected_ok,isolation_ok);
      end
    end
    $finish;
  end
  initial begin #2000; $fatal(1,"vreg85 watchdog"); end
endmodule
