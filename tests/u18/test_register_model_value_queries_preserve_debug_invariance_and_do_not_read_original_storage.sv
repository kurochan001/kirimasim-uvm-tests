/*
:name: test_register_model_value_queries_preserve_debug_invariance_and_do_not_read_original_storage
:description: register model value queries preserve debug invariance and do not read original storage
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.4.1 18.4.4.3 18.4.4.2 18.4.4.15 18.4.4.12 18.4.6.2 19.5.2.2 19.5.2.3 19.5.2.4 19.5.2.5 19.5.2.6 19.5.2.7 19.1.1.2.4 19.1.1.2.6 18.4.2.2 18.5.3.2 18.1.2.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_register_model_value_queries_preserve_debug_invariance_and_do_not_read_original_storage.expected
*/
// What it checks:
// 1. The selected getter returns the desired model value independently of
//    distinct original storage.
// 2. Changing debug-only source information preserves the selected desired
//    getter result.
// 3. The selected desired query reads no original storage and performs no
//    write before the independent live peek control.
// 4. The selected getter returns the mirrored model value independently of
//    distinct original storage.
// 5. Changing debug-only source information preserves the selected mirrored
//    getter result.
// 6. The selected mirrored query reads no original storage and performs no
//    write before the independent live peek control.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.4.4.1 (UVM-REGISTER-CONTRACT-GET-MODEL-VALUE) gives rule 1
//    above. Setup: The selected original user backdoor stores CAFE, while
//    explicit predict sets model mirror 5522 and set changes desired to AA99.
//    Query calls vary omitted/default and explicit debug source information; a
//    later real peek establishes that the attached original backend is live.
//    Expected: The selected getter returns the desired model value
//    independently of distinct original storage.
// 2. 1800.2-2020 18.4.4.1 (UVM-REGISTER-CONTRACT-GET-DEBUG) gives rule 2
//    above. Setup: The selected original user backdoor stores CAFE, while
//    explicit predict sets model mirror 5522 and set changes desired to AA99.
//    Query calls vary omitted/default and explicit debug source information; a
//    later real peek establishes that the attached original backend is live.
//    Expected: Changing debug-only source information preserves the selected
//    desired getter result.
// 3. 1800.2-2020 18.4.4.1 (UVM-REGISTER-CONTRACT-GET-NO-DUT-READ) gives rule 3
//    above. Setup: The selected original user backdoor stores CAFE, while
//    explicit predict sets model mirror 5522 and set changes desired to AA99.
//    Query calls vary omitted/default and explicit debug source information; a
//    later real peek establishes that the attached original backend is live.
//    Expected: The selected desired query reads no original storage and
//    performs no write before the independent live peek control.
// 4. 1800.2-2020 18.4.4.3 (UVM-REGISTER-CONTRACT-MIRROR-MODEL-VALUE) gives
//    rule 4 above. Setup: The selected original user backdoor stores CAFE,
//    while explicit predict sets model mirror 5522 and set changes desired to
//    AA99. Query calls vary omitted/default and explicit debug source
//    information; a later real peek establishes that the attached original
//    backend is live. Expected: The selected getter returns the mirrored model
//    value independently of distinct original storage.
// 5. 1800.2-2020 18.4.4.3 (UVM-REGISTER-CONTRACT-MIRROR-DEBUG) gives rule 5
//    above. Setup: The selected original user backdoor stores CAFE, while
//    explicit predict sets model mirror 5522 and set changes desired to AA99.
//    Query calls vary omitted/default and explicit debug source information; a
//    later real peek establishes that the attached original backend is live.
//    Expected: Changing debug-only source information preserves the selected
//    mirrored getter result.
// 6. 1800.2-2020 18.4.4.3 (UVM-REGISTER-CONTRACT-MIRROR-NO-DUT-READ) gives
//    rule 6 above. Setup: The selected original user backdoor stores CAFE,
//    while explicit predict sets model mirror 5522 and set changes desired to
//    AA99. Query calls vary omitted/default and explicit debug source
//    information; a later real peek establishes that the attached original
//    backend is live. Expected: The selected mirrored query reads no original
//    storage and performs no write before the independent live peek control.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_register_model_value_queries_preserve_debug_invariance_and_do_not_read_original_storage;
  import uvm_pkg::*;
  class block_type extends uvm_reg_block;
    function new(string name);super.new(name,UVM_NO_COVERAGE);endfunction
  endclass
  class register_type extends uvm_reg;
    function new(string name,int unsigned width=16,int coverage_models=UVM_NO_COVERAGE);
      super.new(name,width,coverage_models);
    endfunction
  endclass

  class original_storage extends uvm_reg_backdoor;
    uvm_reg_data_t value='hCAFE;
    int reads=0,writes=0;
    virtual task read(uvm_reg_item rw);
      do_pre_read(rw);reads++;#1;rw.set_value(value);rw.set_status(UVM_IS_OK);do_post_read(rw);
    endtask
    virtual task write(uvm_reg_item rw);
      do_pre_write(rw);writes++;#1;value=rw.get_value(0);
      rw.set_status(UVM_IS_OK);do_post_write(rw);
    endtask
  endclass
  initial begin
    automatic block_type owner=new("owner52");
    automatic register_type rg=new("chosen52");
    automatic uvm_reg_field f=uvm_reg_field::type_id::create("bits52");
    automatic original_storage storage=new();
    bit predicted;
    uvm_status_e status;
    uvm_reg_data_t value;
    owner.configure();rg.configure(owner);f.configure(rg,16,0,"RW",0,0,1,0,0);
    rg.set_backdoor(storage);predicted=rg.predict('h5522);rg.set('hAA99);
    for (int variant=0;variant<2;variant++) begin
      $display(
        "UT: register_model_query debug %0d desired %0h mirror %0h no_reads %0d no_writes %0d",
        variant,rg.get(variant ? "desired52.sv" : "",variant ? 520 : 0),
        rg.get_mirrored_value(variant ? "mirror52.sv" : "",variant ? 521 : 0),
        storage.reads==0,storage.writes==0);
    end
    rg.peek(status,value);
    $display("UT: register_model_query live_control %0d value %0h backend_used %0d predicted %0d",
      status==UVM_IS_OK,value,storage.reads>0,predicted);
    $finish;
  end
endmodule
