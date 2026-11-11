/*
:name: test_vreg_backdoor_model_vreg_peek_word8_85
:description: Virtual vreg peek checks selected storage, isolation and debug invariance
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.3.4 18.9.1.1.2 18.10.2.1 18.10.2.2 18.6.5.6 18.6.7.2 19.1.1.2.4 19.1.1.2.5 1800-2023 6.21 8.20
:uvm: 2020.3.1
:files: helpers85/vreg_backdoor_fixture85.svh
:incdirs: helpers85
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vreg_backdoor_model_vreg_peek_word8_85.expected
*/
// What it checks:
// 1. Virtual-register peek returns the current logical value sampled from the
//    selected element through its memory backdoor.
// 2. Virtual-register peek samples storage without modifying the selected
//    element or other memory words.
// 3. The filename and line-number debug arguments have no functional effect on
//    virtual-vreg peek.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.9.1.3.4 (UVM-VIRTUAL-VREG-PEEK-SAMPLED-DATA-85) gives rule
//    1 above. Setup: Read-write memory and statically configured three-element
//    virtual arrays use explicit memory-word offsets and strides. Each
//    original fixture independently seeds all 32 words, selects indices 0 and
//    2, and repeats the operation with omitted debug arguments, a named
//    file/positive line, and another file/negative line. Singleword profiles
//    use 8-bit or 16-bit memory/register widths and 4-bit or 9-bit fields. Two
//    16-bit-word profiles add a 32-bit whole register or a 16-bit field at LSB
//    8. Original user backdoor storage and actual public 16-bit HDL array
//    storage are separate execution conditions. Fields are created through
//    type_id::create. Expected: Defined logical bits match independently
//    seeded singleword values or the two equal halves of the multiword profile
//    at both selected indices.
// 2. 1800.2-2020 18.9.1.3.4 (UVM-VIRTUAL-VREG-PEEK-STORAGE-PRESERVATION-85)
//    gives rule 2 above. Setup: Read-write memory and statically configured
//    three-element virtual arrays use explicit memory-word offsets and
//    strides. Each original fixture independently seeds all 32 words, selects
//    indices 0 and 2, and repeats the operation with omitted debug arguments,
//    a named file/positive line, and another file/negative line. Singleword
//    profiles use 8-bit or 16-bit memory/register widths and 4-bit or 9-bit
//    fields. Two 16-bit-word profiles add a 32-bit whole register or a 16-bit
//    field at LSB 8. Original user backdoor storage and actual public 16-bit
//    HDL array storage are separate execution conditions. Fields are created
//    through type_id::create. Expected: Every raw memory word remains equal to
//    the pre-call independently seeded snapshot after each peek.
// 3. 1800.2-2020 18.9.1.3.4 (UVM-VIRTUAL-VREG-PEEK-DEBUG-INVARIANCE-85) gives
//    rule 3 above. Setup: Read-write memory and statically configured
//    three-element virtual arrays use explicit memory-word offsets and
//    strides. Each original fixture independently seeds all 32 words, selects
//    indices 0 and 2, and repeats the operation with omitted debug arguments,
//    a named file/positive line, and another file/negative line. Singleword
//    profiles use 8-bit or 16-bit memory/register widths and 4-bit or 9-bit
//    fields. Two 16-bit-word profiles add a 32-bit whole register or a 16-bit
//    field at LSB 8. Original user backdoor storage and actual public 16-bit
//    HDL array storage are separate execution conditions. Fields are created
//    through type_id::create. Expected: Omitted/default debug arguments and
//    two explicit file/line variants each satisfy the same independently
//    derived status, data and storage-preservation predicates.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Independent literals check two indices and three debug-argument variants.
// Multiword checks retain only order-independent observations.
module test_vreg_backdoor_model_vreg_peek_word8_85;
  import uvm_pkg::*;
  `include "vreg_backdoor_fixture85.svh"
  localparam int WORDS=1, BASE=2, STRIDE=3;
  initial begin
    automatic block85 owner=new();
    automatic uvm_mem memory=new("memory85",32,8,"RW");
    automatic uvm_vreg vr=new("virtual85",8);
    automatic storage85 storage=new(8);
    uvm_vreg_field vf;
    uvm_reg_map mapping;
    uvm_reg_data_t value,before_words[32];
    uvm_status_e status;
    int idx,address;
    bit selected_ok,isolation_ok;
    owner.configure(); memory.configure(owner); memory.set_backdoor(storage);
    mapping=owner.create_map("map85",0,1,UVM_LITTLE_ENDIAN);
    mapping.add_mem(memory,0);
    vr.configure(owner,memory,3,BASE,STRIDE);
    vf=uvm_vreg_field::type_id::create("selected85");
    vf.configure(vr,4,2);
    owner.lock_model();
    for (int slot=0;slot<2;slot++) begin
      idx=(slot==0 ? 0 : 2); address=BASE+idx*STRIDE;
      for (int variant=0;variant<3;variant++) begin
        for (int i=0;i<32;i++) storage.words[i]=('h8201 ^ (i*'h137)) & 'hff;
        for (int i=0;i<WORDS;i++) storage.words[address+i]=(slot==0 ? 'h96 : 'h69);
        for (int i=0;i<32;i++) before_words[i]=storage.words[i];
        #1;
        if (variant==0) vr.peek(idx,status,value);
        else vr.peek(idx,status,value,null,null,
          (variant==1 ? "selected85.sv" : "other85.sv"),(variant==1 ? 8517 : -85));
        #1;
        selected_ok=(value & 'hff)==(slot==0 ? 'h96 : 'h69);
        isolation_ok=1;
        for (int i=0;i<32;i++) begin
           isolation_ok &= storage.words[i]==before_words[i];
        end
        $display("UT: vreg85 model vreg_peek_word8 idx %0d debug %0d",
          idx,variant);
        $display("UT: vreg85 status %0d value %0d isolated %0d",
          status==UVM_IS_OK,selected_ok,isolation_ok);
      end
    end
    $finish;
  end
  initial begin #2000; $fatal(1,"vreg85 watchdog"); end
endmodule
