/*
:name: test_recorder_configuration_defaults_updates_and_flush_restore_the_declared_values
:description: recorder configuration defaults updates and flush restore the declared values
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.4.2.1 16.4.2.2 16.4.2.3 16.4.4.1 16.4.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_recorder_configuration_defaults_updates_and_flush_restore_the_declared_values.expected
*/
module test_recorder_configuration_defaults_updates_and_flush_restore_the_declared_values;
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
  initial begin
    automatic local_recorder selected=new();
    automatic local_recorder peer=new();
    automatic uvm_policy view=selected;
    $display("UT: recorder_defaults recursion %0d id %0d radix %0d base %0d",
             selected.get_recursion_policy()==UVM_DEFAULT_POLICY,selected.get_id_enabled()==1,
             selected.get_default_radix()==UVM_HEX,view==selected);
    selected.set_recursion_policy(UVM_SHALLOW); selected.set_id_enabled(0);
    selected.set_default_radix(UVM_DEC);
    $display("UT: recorder_changed recursion %0d id %0d radix %0d peer %0d",
             selected.get_recursion_policy()==UVM_SHALLOW,selected.get_id_enabled()==0,
             selected.get_default_radix()==UVM_DEC,
             peer.get_recursion_policy()==UVM_DEFAULT_POLICY && peer.get_id_enabled()==1 &&
             peer.get_default_radix()==UVM_HEX);
    selected.flush();
    $display("UT: recorder_flushed recursion %0d id %0d radix %0d",
             selected.get_recursion_policy()==UVM_DEFAULT_POLICY,selected.get_id_enabled()==1,
             selected.get_default_radix()==UVM_HEX);
    $finish;
  end
endmodule
