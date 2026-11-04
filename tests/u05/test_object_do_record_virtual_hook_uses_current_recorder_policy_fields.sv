/*
:name: test_object_do_record_virtual_hook_uses_current_recorder_policy_fields
:description: A direct virtual recording hook writes through each supplied standard recorder policy
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.7.2 5.3.7 16.4.6.2 7.1.4.1 7.2.5.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_do_record_virtual_hook_uses_current_recorder_policy_fields.expected
*/
module test_object_do_record_virtual_hook_uses_current_recorder_policy_fields;
  import uvm_pkg::*;
  class original_object extends uvm_object;
    function new(string name=""); super.new(name); endfunction
    virtual function string get_type_name(); return "original_object61"; endfunction
    virtual function uvm_object create(string name="");
      original_object result;
      result=new(name); return result;
    endfunction
  endclass
  class capture_recorder extends uvm_recorder;
    int objects=0,fields=0;
    uvm_object last_object;
    time opened=0,closed=0;
    uvm_integral_t field_value=0;
    function new(string name); super.new(name); endfunction
    protected virtual function void do_open(uvm_tr_stream stream,time open_time,string type_name);
      opened=open_time;
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
  class record_subject extends original_object;
    int payload=37,calls=0;
    uvm_recorder seen;
    function new(); super.new("record_subject61"); endfunction
    virtual function void do_record(uvm_recorder recorder);
      calls++; seen=recorder; recorder.record_field_int("payload61",payload,8,UVM_HEX);
    endfunction
    virtual function string get_type_name(); return "record_subject61"; endfunction
    virtual function uvm_object create(string name="");
      record_subject result;
      result=new(); result.set_name(name); return result;
    endfunction
  endclass
  initial begin
    record_subject value;
    uvm_object view;
    capture_database database;
    capture_recorder first,second;
    uvm_tr_stream stream_value;
    uvm_recorder first_base,second_base;
    value=new(); view=value; database=new();
    if (!database.open_db()) $fatal(1,"original database did not open");
    stream_value=database.open_stream("hook61","scope61","");
    #1; first_base=stream_value.open_recorder("first61",$time,"");
    second_base=stream_value.open_recorder("second61",$time,"");
    if (!$cast(first,first_base) || !$cast(second,second_base)) $fatal(1,"recorders missing");
    view.do_record(first_base);
    $display("UT: record_hook first_policy %0d first_value %0d first_calls %0d",
      value.seen==first_base,first.field_value==37,first.fields==1);
    value.payload=61; view.do_record(second_base);
    $display("UT: record_hook second_policy %0d second_value %0d first_unchanged %0d two_hooks %0d",
      value.seen==second_base,second.field_value==61,
      first.field_value==37 && first.fields==1,value.calls==2);
    $finish;
  end
  initial begin #100; $fatal(1,"base hook fixture watchdog expired"); end
endmodule
