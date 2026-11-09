/*
:name: test_component_error_recording_selected_backend_marks_explicit_default_and_zero_times
:description: component error recording selected backend marks explicit default and zero times
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.1.7.7 13.1.7.11 13.1.7.13 7.1.3.1 7.1.4.1 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.2.7.1 7.2.7.2 7.2.7.3 7.2.7.4 16.4.7.1 16.4.7.2 16.4.7.3 16.4.7.4 16.4.7.5 16.4.7.6 16.4.7.9 16.4.7.10 16.4.7.11 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_error_recording_selected_backend_marks_explicit_default_and_zero_times.expected
*/
// What it checks:
// 1. The selected explicit error timestamp is marked through the original
//    recording backend.
// 2. Omitting the error time marks the current simulation time in the selected
//    backend.
// 3. Explicit zero error time selects the current simulation time with both
//    selected keep-active values.
// 4. Omitting keep_active records a zero-length error transaction at the
//    selected explicit or current timestamp.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 13.1.7.7 (UVM-RECORDING-AUDIT-ERROR-EXPLICIT-TIME) gives rule
//    1 above. Setup: Use the linked original fixtures, selected public
//    arguments, explicit declared types and exact expected observations. The
//    recording backend is original in-memory setup, not an
//    implementation-derived oracle. Expected: The selected explicit error
//    timestamp is marked through the original recording backend.
// 2. 1800.2-2020 13.1.7.7 (UVM-RECORDING-AUDIT-ERROR-OMITTED-TIME) gives rule
//    2 above. Setup: Use the linked original fixtures, selected public
//    arguments, explicit declared types and exact expected observations. The
//    recording backend is original in-memory setup, not an
//    implementation-derived oracle. Expected: Omitting the error time marks
//    the current simulation time in the selected backend.
// 3. 1800.2-2020 13.1.7.7 (UVM-RECORDING-AUDIT-ERROR-ZERO-TIME) gives rule 3
//    above. Setup: Use the linked original fixtures, selected public
//    arguments, explicit declared types and exact expected observations. The
//    recording backend is original in-memory setup, not an
//    implementation-derived oracle. Expected: Explicit zero error time selects
//    the current simulation time with both selected keep-active values.
// 4. 1800.2-2020 13.1.7.7 (UVM-RECORDING-AUDIT-ERROR-DEFAULT-ZERO-LENGTH)
//    gives rule 4 above. Setup: Use the linked original fixtures, selected
//    public arguments, explicit declared types and exact expected
//    observations. The recording backend is original in-memory setup, not an
//    implementation-derived oracle. Expected: Omitting keep_active records a
//    zero-length error transaction at the selected explicit or current
//    timestamp.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_component_error_recording_selected_backend_marks_explicit_default_and_zero_times;
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
  initial begin
    automatic original_component actor=new("actor48",null);
    automatic original_database db=new();
    int token;
    if (!db.open_db()) $fatal(1,"original database not open");
    actor.set_tr_database(db); actor.set_recording_enabled(1);
    #19;
    wanted_time=7; saw_time=0; saw_zero_length=0;
    token=actor.record_error_tr(.error_time(7));
    $display("UT: error_time explicit selected %0d zero_length %0d",saw_time,saw_zero_length);
    #4;
    wanted_time=$time; saw_time=0; saw_zero_length=0;
    token=actor.record_error_tr();
    $display("UT: error_time omitted selected %0d zero_length %0d",saw_time,saw_zero_length);
    #6;
    wanted_time=$time; saw_time=0; saw_zero_length=0;
    token=actor.record_error_tr(.error_time(0));
    $display("UT: error_time zero selected %0d zero_length %0d",saw_time,saw_zero_length);
    #2;
    wanted_time=$time; saw_time=0; saw_zero_length=0;
    token=actor.record_error_tr(.error_time(0),.keep_active(1));
    $display("UT: error_time active selected %0d",saw_time);
    // Observe original callbacks before free; do not decode returned tokens.
    $finish;
  end
endmodule
