/*
:name: test_object_record_ignores_null_policies_and_delegates_the_same_object_to_a_supplied_recorder
:description: object record ignores null policies and delegates the same object to a supplied recorder
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.7.1 16.4.6.4 16.4.7.7 16.4.2.1 6.6.5 D.4.4 13.1.7.11 13.1.7.13 7.1.3.1 7.1.4.1 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.2.7.1 7.2.7.2 7.2.7.3 7.2.7.4 16.4.7.1 16.4.7.2 16.4.7.3 16.4.7.4 16.4.7.5 16.4.7.6 16.4.7.9 16.4.7.10 16.4.7.11 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_record_ignores_null_policies_and_delegates_the_same_object_to_a_supplied_recorder.expected
*/
// What it checks:
// 1. Omitted and explicit-null record policies are silently ignored by the
//    object record wrapper.
// 2. With a supplied recorder, the object record wrapper passes that same
//    object to the selected recorder operation.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.3.7.1 (UVM-RECORDING-AUDIT-OBJECT-RECORD-NULL-IGNORED)
//    gives rule 1 above. Setup: Call the actual object record wrapper. Null
//    cases observe original report and object hooks; the nonnull case uses an
//    opened original recorder with explicit DEEP recursion and a
//    do_record_object observer. Expected: Omitted and explicit-null record
//    policies are silently ignored by the object record wrapper.
// 2. 1800.2-2020 5.3.7.1 (UVM-RECORDING-AUDIT-OBJECT-RECORD-SAME-DELEGATION)
//    gives rule 2 above. Setup: Call the actual object record wrapper. Null
//    cases observe original report and object hooks; the nonnull case uses an
//    opened original recorder with explicit DEEP recursion and a
//    do_record_object observer. Expected: With a supplied recorder, the object
//    record wrapper passes that same object to the selected recorder
//    operation.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module
  test_object_record_ignores_null_policies_and_delegates_the_same_object_to_a_supplied_recorder;
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
  class record_subject extends uvm_object;
    int field_calls=0,user_calls=0;
    function new(string name); super.new(name); endfunction
    virtual function void do_execute_op(uvm_field_op op);
      super.do_execute_op(op); field_calls++;
    endfunction
    virtual function void do_record(uvm_recorder recorder); user_calls++; endfunction
  endclass
  class report_probe extends uvm_report_catcher;
    int reports=0;
    virtual function action_e catch(); reports++; return CAUGHT; endfunction
  endclass
  class delegate_recorder extends original_recorder;
    uvm_object seen;
    int objects=0;
    function new(string name); super.new(name); endfunction
    protected virtual function void do_record_object(string name,uvm_object value);
      objects++; seen=value;
    endfunction
  endclass
  class delegate_stream extends original_stream;
    function new(string name); super.new(name); endfunction
    protected virtual function uvm_recorder do_open_recorder(string name,time open_time,
                                                          string type_name);
      delegate_recorder value;
      value=new(name); return value;
    endfunction
  endclass
  class delegate_database extends original_database;
    protected virtual function uvm_tr_stream do_open_stream(string name,string scope,
                                                         string type_name);
      delegate_stream value;
      value=new(name); return value;
    endfunction
  endclass
  initial begin
    automatic record_subject subject=new("subject48");
    automatic report_probe probe=new();
    automatic delegate_database db=new();
    uvm_tr_stream stream_value;
    uvm_recorder recorder;
    delegate_recorder observed;
    uvm_report_cb::add(null,probe); probe.reports=0;
    subject.record();
    $display("UT: object_record omitted_silent %0d",
             probe.reports==0 && subject.field_calls==0 && subject.user_calls==0);
    probe.reports=0; subject.record(null);
    $display("UT: object_record explicit_null_silent %0d",
             probe.reports==0 && subject.field_calls==0 && subject.user_calls==0);
    uvm_report_cb::delete(null,probe);
    if (!db.open_db()) $fatal(1,"original database not open");
    stream_value=db.open_stream("objects48","scope48","");
    recorder=stream_value.open_recorder("selected48",7,"");
    if (!$cast(observed,recorder)) $fatal(1,"selected recorder missing");
    recorder.set_recursion_policy(UVM_DEEP); subject.record(recorder);
    $display("UT: object_record delegated %0d same %0d",observed.objects>0,observed.seen==subject);
    $finish;
  end
endmodule
