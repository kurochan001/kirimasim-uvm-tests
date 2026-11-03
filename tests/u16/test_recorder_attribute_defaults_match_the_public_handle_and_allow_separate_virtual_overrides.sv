/*
:name: test_recorder_attribute_defaults_match_the_public_handle_and_allow_separate_virtual_overrides
:description: recorder attribute defaults match the public handle and allow separate virtual overrides
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.4.6.8 16.4.6.9 16.4.5.1 16.4.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_recorder_attribute_defaults_match_the_public_handle_and_allow_separate_virtual_overrides.expected
*/
module
  test_recorder_attribute_defaults_match_the_public_handle_and_allow_separate_virtual_overrides;
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
  class custom_recorder extends local_recorder;
    virtual function bit use_record_attribute(); return 1; endfunction
    virtual function int get_record_attribute_handle(); return 4343; endfunction
  endclass
  initial begin
    automatic local_stream stream=make_stream();
    automatic local_recorder ordinary=new();
    automatic custom_recorder custom=new();
    automatic uvm_recorder view=custom;
    uvm_recorder result;
    stream.candidate=ordinary; result=stream.open_recorder("ordinary",17,"packet");
    $display("UT: record_attribute_default disabled %0d handle %0d",
             ordinary.use_record_attribute()==0,
             ordinary.get_record_attribute_handle()==ordinary.get_handle());
    stream.candidate=custom; result=stream.open_recorder("custom",23,"packet");
    $display("UT: record_attribute_override enabled %0d token %0d",
             view.use_record_attribute()==1,view.get_record_attribute_handle()==4343);
    ordinary.free(); custom.free(); stream.close(); stream.free(); $finish;
  end
endmodule
