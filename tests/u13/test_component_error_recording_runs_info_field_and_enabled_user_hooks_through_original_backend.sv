/*
:name: test_component_error_recording_runs_info_field_and_enabled_user_hooks_through_original_backend
:description: component error recording runs info field and enabled user hooks through original backend
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.7.7 5.3.7.1 5.3.7.2 5.3.13 5.7.2.4 5.7.2.5 5.7.2.8 16.4.6.2 16.4.6.4 16.4.7.7 13.1.7.11 13.1.7.13 7.1.3.1 7.1.4.1 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.2.7.1 7.2.7.2 7.2.7.3 7.2.7.4 16.4.7.1 16.4.7.2 16.4.7.3 16.4.7.4 16.4.7.5 16.4.7.6 16.4.7.9 16.4.7.10 16.4.7.11 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_error_recording_runs_info_field_and_enabled_user_hooks_through_original_backend.expected
*/
// What it checks:
// 1. Error recording records the selected original info property through its
//    UVM_RECORD field-operation hook.
// 2. Error recording records the selected info property supplied by its
//    enabled do_record hook.
// 3. The info field operation can suppress its subsequent user recording hook
//    without suppressing its selected field property.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 13.1.7.7 (UVM-RECORDING-AUDIT-ERROR-INFO-FIELD-OP) gives rule
//    1 above. Setup: Use the linked original fixtures, selected public
//    arguments, explicit declared types and exact expected observations. The
//    recording backend is original in-memory setup, not an
//    implementation-derived oracle. Expected: Error recording records the
//    selected original info property through its UVM_RECORD field-operation
//    hook.
// 2. 1800.2-2020 13.1.7.7 (UVM-RECORDING-AUDIT-ERROR-INFO-USER-HOOK) gives
//    rule 2 above. Setup: Use the linked original fixtures, selected public
//    arguments, explicit declared types and exact expected observations. The
//    recording backend is original in-memory setup, not an
//    implementation-derived oracle. Expected: Error recording records the
//    selected info property supplied by its enabled do_record hook.
// 3. 1800.2-2020 16.4.7.7 (UVM-RECORDING-AUDIT-ERROR-INFO-USER-SUPPRESSION)
//    gives rule 3 above. Setup: Use the linked original fixtures, selected
//    public arguments, explicit declared types and exact expected
//    observations. The recording backend is original in-memory setup, not an
//    implementation-derived oracle. Expected: The info field operation can
//    suppress its subsequent user recording hook without suppressing its
//    selected field property.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module
  test_component_error_recording_runs_info_field_and_enabled_user_hooks_through_original_backend;
  import uvm_pkg::*;
  time wanted_time;
  bit saw_time=0,saw_zero_length=0,saw_field=0,saw_user=0;
  class original_recorder extends uvm_recorder;
    time opened_at;
    function new(string name); super.new(name); endfunction
    protected virtual function void do_open(uvm_tr_stream stream,time open_time,string type_name);
      opened_at=open_time; if (open_time==wanted_time) saw_time=1;
    endfunction
    protected virtual function void do_close(time close_time);
      if (opened_at==wanted_time && close_time==wanted_time) saw_zero_length=1;
    endfunction
    protected virtual function void do_free(); endfunction
    protected virtual function void do_record_field(string name,uvm_bitstream_t value,int size,
                                                   uvm_radix_enum radix); endfunction
    protected virtual function void do_record_field_int(string name,uvm_integral_t value,int size,
                                                       uvm_radix_enum radix);
      if (name=="origin_field48" && value==48 && size==32 && radix==UVM_DEC) saw_field=1;
      if (name=="origin_user48" && value==96 && size==32 && radix==UVM_DEC) saw_user=1;
    endfunction
    protected virtual function void do_record_field_real(string name,real value); endfunction
    protected virtual function void do_record_string(string name,string value); endfunction
    protected virtual function void do_record_time(string name,time value); endfunction
    protected virtual function void do_record_generic(string name,string value,string type_name);
    endfunction
  endclass
  class original_stream extends uvm_tr_stream;
    function new(string name); super.new(name); endfunction
    protected virtual function void do_open(uvm_tr_database db,string scope,string type_name);
    endfunction
    protected virtual function void do_close(); endfunction
    protected virtual function void do_free(); endfunction
    protected virtual function uvm_recorder do_open_recorder(string name,time open_time,
                                                          string type_name);
      original_recorder value;
      value=new(name); return value;
    endfunction
  endclass
  class original_database extends uvm_tr_database;
    function new(string name="db48"); super.new(name); endfunction
    protected virtual function bit do_open_db(); return 1; endfunction
    protected virtual function bit do_close_db(); return 1; endfunction
    protected virtual function uvm_tr_stream do_open_stream(string name,string scope,
                                                         string type_name);
      original_stream value;
      value=new(name); return value;
    endfunction
    protected virtual function void do_establish_link(uvm_link_base link); endfunction
  endclass
  class original_component extends uvm_component;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  class original_info extends uvm_object;
    bit disable_user=0;
    int field_calls=0,user_calls=0;
    virtual function void do_execute_op(uvm_field_op op);
      uvm_recorder recorder;
      super.do_execute_op(op);
      if (op.get_op_type()==UVM_RECORD) begin
        field_calls++;
        if (!$cast(recorder,op.get_policy())) $fatal(1,"record policy missing");
        recorder.record_field_int("origin_field48",48,32,UVM_DEC);
        if (disable_user) op.disable_user_hook();
      end
    endfunction
    virtual function void do_record(uvm_recorder recorder);
      user_calls++; recorder.record_field_int("origin_user48",96,32,UVM_DEC);
    endfunction
  endclass
  initial begin
    automatic original_component actor=new("actor48",null);
    automatic original_database db=new();
    automatic original_info enabled=new();
    automatic original_info suppressed=new();
    int token;
    if (!db.open_db()) $fatal(1,"original database not open");
    actor.set_tr_database(db); actor.set_recording_enabled(1); wanted_time=7;
    token=actor.record_error_tr(.info(enabled),.error_time(7));
    $display("UT: error_info enabled field %0d user %0d operation %0d hook %0d",
             saw_field,saw_user,enabled.field_calls>0,enabled.user_calls>0);
    saw_field=0; saw_user=0; suppressed.disable_user=1;
    token=actor.record_error_tr(.info(suppressed),.error_time(11));
    $display("UT: error_info suppressed field %0d user %0d operation %0d hook %0d",
             saw_field,saw_user,suppressed.field_calls>0,suppressed.user_calls>0);
    // Return tokens and string interpretations remain application-specific.
    $finish;
  end
endmodule
