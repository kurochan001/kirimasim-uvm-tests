/*
:name: test_recorder_disabled_user_hook_finishes_history_and_unwinds_the_active_object
:description: recorder disabled user hook finishes history and unwinds the active object
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.4.6.4 16.4.7.7 16.4.7.8 16.1.3 16.1.3.2 16.1.3.3 16.1.3.4 16.1.4 5.7.2.8 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_recorder_disabled_user_hook_finishes_history_and_unwinds_the_active_object.expected
*/
module test_recorder_disabled_user_hook_finishes_history_and_unwinds_the_active_object;
  import uvm_pkg::*;
  string order="";
  class local_recorder extends uvm_recorder;
    int opens=0,closes=0,frees=0,object_calls=0;
    string object_name;
    uvm_object object_value;
    function new(string name="recorder"); super.new(name); endfunction
    protected virtual function void do_open(uvm_tr_stream stream,time open_time,string type_name);
      opens++; order={order,"O"};
    endfunction
    protected virtual function void do_close(time close_time); closes++; order={order,"C"};
    endfunction
    protected virtual function void do_free(); frees++; order={order,"F"}; endfunction
    protected virtual function void do_record_field(string name,uvm_bitstream_t value,
                                                           int size,uvm_radix_enum radix);
    endfunction
    protected virtual function void do_record_field_int(string name,uvm_integral_t value,
                                                               int size,uvm_radix_enum radix);
    endfunction
    protected virtual function void do_record_field_real(string name,real value); endfunction
    protected virtual function void do_record_string(string name,string value); endfunction
    protected virtual function void do_record_time(string name,time value); endfunction
    protected virtual function void do_record_generic(string name,string value,string type_name);
    endfunction

    protected virtual function void do_record_object(string name,uvm_object value);
      object_calls++; object_name=name; object_value=value; order={order,"H"};
      super.do_record_object(name,value);
    endfunction
  endclass
  class local_stream extends uvm_tr_stream;
    uvm_recorder candidate;
    function new(string name); super.new(name); endfunction
    protected virtual function void do_open(uvm_tr_database db,string scope,
                                            string stream_type_name);
    endfunction
    protected virtual function void do_close(); endfunction
    protected virtual function void do_free(); endfunction
    protected virtual function uvm_recorder do_open_recorder(string name,time open_time,
                                                           string type_name);
      uvm_recorder result=candidate; candidate=null; return result;
    endfunction
  endclass
  class local_database extends uvm_tr_database;
    protected virtual function bit do_open_db(); return 1; endfunction
    protected virtual function bit do_close_db(); return 1; endfunction
    protected virtual function uvm_tr_stream do_open_stream(string name,string scope,
                                                          string type_name);
      local_stream result=new(name); return result;
    endfunction
    protected virtual function void do_establish_link(uvm_link_base link); endfunction
  endclass
  function automatic local_stream make_stream();
    local_database db=new();
    local_stream value;
    if (!db.open_db() || !$cast(value,db.open_stream("stream"))) $fatal(1,"missing stream");
    return value;
  endfunction
  `include "uvm_macros.svh"
  class audit_recorder extends local_recorder;
    uvm_object target;
    bit finished_before_pop=0;
    virtual function uvm_object pop_active_object();
      finished_before_pop=object_recorded(target,UVM_DEEP)==uvm_policy::FINISHED;
      order={order,"X"}; return super.pop_active_object();
    endfunction
  endclass
  class item extends uvm_object;
    `uvm_object_utils(item)
    uvm_recorder selected;
    bit suppress=0;
    int fields=0,users=0;
    function new(string name="item"); super.new(name); endfunction
    virtual function void do_execute_op(uvm_field_op op);
      uvm_recorder actual;
      if (!$cast(actual,op.get_policy())) $fatal(1,"wrong recording policy");
      fields++; order={order,"E"};
      $display("UT: record_execute op %s exact %0d active %0d depth %0d started %0d",
               op.get_op_name(),actual==selected,actual.get_active_object()==this,
               actual.get_active_object_depth(),
               actual.object_recorded(this,UVM_DEEP)==uvm_policy::STARTED);
      if (suppress) op.disable_user_hook();
    endfunction
    virtual function void do_record(uvm_recorder recorder);
      users++; order={order,"U"};
      $display("UT: record_user exact %0d active %0d started %0d",recorder==selected,
               recorder.get_active_object()==this,
               recorder.object_recorded(this,UVM_DEEP)==uvm_policy::STARTED);
    endfunction
  endclass
  initial begin
    automatic local_stream stream=make_stream();
    automatic audit_recorder recorder=new();
    automatic item value=new("object_name");
    uvm_recorder result;
    value.selected=recorder; value.suppress=1; recorder.target=value;
    stream.candidate=recorder; result=stream.open_recorder("record",17,"packet");
    recorder.set_recursion_policy(UVM_DEEP); order="";
    $display("UT: record_history_never %0d",
             recorder.object_recorded(value,UVM_DEEP)==uvm_policy::NEVER);
    recorder.record_object("field43",value);
    $display(
      "UT: record_end trace %s fields %0d users %0d hook %0d name %0d value %0d finished %0d",
             order,value.fields,value.users,recorder.object_calls,recorder.object_name=="field43",
             recorder.object_value==value,
             recorder.object_recorded(value,UVM_DEEP)==uvm_policy::FINISHED);
    $display("UT: record_cleanup finished_before_pop %0d empty %0d",recorder.finished_before_pop,
             recorder.get_active_object()==null && recorder.get_active_object_depth()==0);
    recorder.free(); stream.close(); stream.free(); $finish;
  end
endmodule
