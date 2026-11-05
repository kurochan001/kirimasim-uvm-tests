// Original recording hooks observe macro delegation, not a vendor database.
class recorder68 extends uvm_recorder;
  int field_calls=0,int_calls=0,string_calls=0,time_calls=0,real_calls=0,generic_calls=0;
  int handle_queries=0;
  bit attributes=0;
  string field_name,string_name,time_name,real_name,generic_name,generic_type;
  uvm_bitstream_t field_value;
  int field_size,int_size;
  string int_name;
  uvm_integral_t int_value;
  uvm_radix_enum int_radix;
  uvm_radix_enum field_radix;
  string string_value,generic_value;
  time time_value;
  real real_value;
  function new(string name="recorder68");
    super.new(name);set_recursion_policy(UVM_DEEP);
  endfunction
  virtual function bit use_record_attribute();return attributes;endfunction
  virtual function int get_record_attribute_handle();
    handle_queries++;
    return attributes?4343:super.get_record_attribute_handle();
  endfunction
  function void clear68();
    field_calls=0;int_calls=0;string_calls=0;time_calls=0;real_calls=0;generic_calls=0;
    handle_queries=0;
  endfunction
  function int calls68();
    return field_calls+int_calls+string_calls+time_calls+real_calls+generic_calls;
  endfunction
  protected virtual function void do_open(uvm_tr_stream stream,time open_time,
      string type_name);endfunction
  protected virtual function void do_close(time close_time);endfunction
  protected virtual function void do_free();endfunction
  protected virtual function void do_record_field(string name,uvm_bitstream_t value,
      int size,uvm_radix_enum radix);
    field_calls++;field_name=name;field_value=value;field_size=size;field_radix=radix;
  endfunction
  protected virtual function void do_record_field_int(string name,uvm_integral_t value,
      int size,uvm_radix_enum radix);
    int_calls++;int_name=name;int_value=value;int_size=size;int_radix=radix;
  endfunction
  protected virtual function void do_record_field_real(string name,real value);
    real_calls++;real_name=name;real_value=value;
  endfunction
  protected virtual function void do_record_string(string name,string value);
    string_calls++;string_name=name;string_value=value;
  endfunction
  protected virtual function void do_record_time(string name,time value);
    time_calls++;time_name=name;time_value=value;
  endfunction
  protected virtual function void do_record_generic(string name,string value,string type_name);
    generic_calls++;generic_name=name;generic_value=value;generic_type=type_name;
  endfunction
endclass
class stream68 extends uvm_tr_stream;
  recorder68 candidate;
  function new(string name);super.new(name);endfunction
  protected virtual function void do_open(uvm_tr_database db,string scope,
      string stream_type_name);endfunction
  protected virtual function void do_close();endfunction
  protected virtual function void do_free();endfunction
  protected virtual function uvm_recorder do_open_recorder(string name,time open_time,
      string type_name);
    recorder68 result=candidate;candidate=null;return result;
  endfunction
endclass
class database68 extends uvm_tr_database;
  protected virtual function bit do_open_db();return 1;endfunction
  protected virtual function bit do_close_db();return 1;endfunction
  protected virtual function uvm_tr_stream do_open_stream(string name,string scope,
      string type_name);
    stream68 result=new(name);return result;
  endfunction
  protected virtual function void do_establish_link(uvm_link_base link);endfunction
endclass
class transaction68 extends uvm_transaction;
  function new(string name="transaction68");super.new(name);endfunction
endclass
function automatic void activate68(recorder68 recorder,transaction68 transaction);
  database68 database=new();
  stream68 stream;
  int handle_value;
  if(!database.open_db() || !$cast(stream,database.open_stream("stream68")))
    $fatal(1,"original recording stream missing");
  stream.candidate=recorder;transaction.enable_recording(stream);
  handle_value=transaction.begin_tr();
  if(handle_value==0 || uvm_recorder::get_recorder_from_handle(handle_value)!=recorder)
    $fatal(1,"original transaction recorder missing");
  recorder.clear68();
endfunction
