/*
:name: test_transaction_explicit_deep_recording_links_the_selected_recorder_handle
:description: Enabled transaction recording exposes the live original recorder handle without fixing its numeric ID
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.4.2.8 16.4.2.1 5.4.2.9 5.4.2.11 5.4.2.4 5.4.2.6 16.4.5.1 16.4.5.2 7.2.5.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_transaction_explicit_deep_recording_links_the_selected_recorder_handle.expected
*/
// What it checks:
// 1. A recorded begin exposes the opened recorder handle.
// 2. An ended transaction has no live transaction handle.
// 3. Recorded begin calls object recording on the transaction.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.4.2.8 (UVM-BASE-AUDIT-ENABLED-HANDLE) gives rule 1 above.
//    Setup: Use fresh original transactions and legally opened streams,
//    positive begin/end times and exact original recorder identities.
//    Expected: The nonzero begin/getter handles agree and resolve to the exact
//    original recorder.
// 2. 1800.2-2020 5.4.2.8 (UVM-BASE-AUDIT-ENDED-HANDLE) gives rule 2 above.
//    Setup: Use fresh original transactions and legally opened streams,
//    positive begin/end times and exact original recorder identities.
//    Expected: The getter returns zero; the default free releases the recorder
//    handle and ID lookup becomes null.
// 3. 1800.2-2020 5.4.2.4 (UVM-BASE-AUDIT-BEGIN-RECORD-OBJECT) gives rule 3
//    above. Setup: Use fresh original transactions and legally opened streams,
//    positive begin/end times and exact original recorder identities.
//    Expected: The original recorder object hook observes the exact
//    transaction handle.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_transaction_explicit_deep_recording_links_the_selected_recorder_handle;
  import uvm_pkg::*;
  class transaction_type extends uvm_transaction;
    function new(string name="",uvm_component initiator=null);
      super.new(name,initiator);
    endfunction
    virtual function string get_type_name(); return "transaction_type61"; endfunction
    virtual function uvm_object create(string name="");
      transaction_type result;
      result=new(name); return result;
    endfunction
  endclass
  class capture_recorder extends uvm_recorder;
    int objects=0,fields=0;
    uvm_object last_object;
    time opened=0,closed=0;
    uvm_integral_t field_value=0;
    function new(string name);
      super.new(name); set_recursion_policy(UVM_DEEP);
    endfunction
    protected virtual function void do_open(uvm_tr_stream stream,time open_time,string type_name);
      opened=open_time; set_recursion_policy(UVM_DEEP);
    endfunction
    protected virtual function void do_close(time close_time); closed=close_time; endfunction
    protected virtual function void do_free(); endfunction
    protected virtual function void do_record_object(string name,uvm_object value);
      objects++; last_object=value;
    endfunction
    protected virtual function void do_record_field(string name,uvm_bitstream_t value,int size,
                                                   uvm_radix_enum radix); endfunction
    protected virtual function void do_record_field_int(string name,uvm_integral_t value,int size,
                                                       uvm_radix_enum radix);
      if (name=="payload61" && size==8 && radix==UVM_HEX) begin
        fields++; field_value=value;
      end
    endfunction
    protected virtual function void do_record_field_real(string name,real value); endfunction
    protected virtual function void do_record_string(string name,string value); endfunction
    protected virtual function void do_record_time(string name,time value); endfunction
    protected virtual function void do_record_generic(string name,string value,string type_name);
    endfunction
  endclass
  class capture_stream extends uvm_tr_stream;
    capture_recorder last;
    int opens=0;
    function new(string name); super.new(name); endfunction
    protected virtual function void do_open(
        uvm_tr_database db,string scope,string stream_type_name);
    endfunction
    protected virtual function void do_close(); endfunction
    protected virtual function void do_free(); endfunction
    protected virtual function uvm_recorder do_open_recorder(
        string name,time open_time,string type_name);
      last=new(name); opens++; return last;
    endfunction
  endclass
  class capture_database extends uvm_tr_database;
    function new(); super.new("database61"); endfunction
    protected virtual function bit do_open_db(); return 1; endfunction
    protected virtual function bit do_close_db(); return 1; endfunction
    protected virtual function uvm_tr_stream do_open_stream(
        string name,string scope,string type_name);
      capture_stream result;
      result=new(name); return result;
    endfunction
    protected virtual function void do_establish_link(uvm_link_base link); endfunction
  endclass
  class reports extends uvm_report_catcher;
    bit gated=0;
    int errors=0;
    virtual function action_e catch();
      if (gated && (get_severity()==UVM_ERROR || get_severity()==UVM_FATAL)) begin
        errors++; return CAUGHT;
      end
      return THROW;
    endfunction
  endclass
  initial begin
    transaction_type value,peer;
    capture_database database;
    capture_stream first_stream,second_stream;
    uvm_tr_stream first_base,second_base;
    int handle_value;
    reports catcher;
    value=new("value61"); peer=new("peer61"); database=new(); catcher=new();
    if (!database.open_db()) $fatal(1,"original database did not open");
    first_base=database.open_stream("first61","scope61","");
    second_base=database.open_stream("second61","scope61","");
    if (!$cast(first_stream,first_base) || !$cast(second_stream,second_base))
      $fatal(1,"original streams missing");
    value.enable_recording(first_base);
    $display("UT: recording_selected enabled %0d before_handle_zero %0d",
      value.is_recording_enabled(),value.get_tr_handle()==0);
    #2; handle_value=value.begin_tr();
    if (first_stream.last==null) $fatal(1,"transaction recorder missing");
    $display(
      "UT: recording_handle valid %0d same %0d lookup %0d recorded_subject %0d deep_mode %0d",
      handle_value!=0,handle_value==value.get_tr_handle(),
      uvm_recorder::get_recorder_from_handle(handle_value)==first_stream.last,
      first_stream.last.objects>0 && first_stream.last.last_object==value,
      first_stream.last.get_recursion_policy()==UVM_DEEP);
    #2; value.end_tr();
    $display("UT: recording_ended no_handle %0d freed %0d lookup_null %0d",
      value.get_tr_handle()==0,first_stream.last.get_handle()==0,
      uvm_recorder::get_recorder_from_handle(handle_value)==null);
    $finish;
  end
  initial begin #100; $fatal(1,"base-class fixture watchdog expired"); end
endmodule
