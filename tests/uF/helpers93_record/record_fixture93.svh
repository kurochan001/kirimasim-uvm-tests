// Original in-memory backend: test public dispatch, not a binary DB renderer.
class recorder93 extends uvm_recorder;
  int wide_calls=0,int_calls=0;
  string seen_name;
  uvm_bitstream_t seen_value;
  int seen_size;
  uvm_radix_enum seen_radix;
  function new(string name="recorder93");
    super.new(name);
  endfunction
  protected virtual function void do_open(uvm_tr_stream stream,time open_time,string type_name);endfunction
  protected virtual function void do_close(time close_time);endfunction
  protected virtual function void do_free();endfunction
  protected virtual function void do_record_field(string name,uvm_bitstream_t value,int size,uvm_radix_enum radix);
    wide_calls++;
    seen_name=name;
    seen_value=value;
    seen_size=size;
    seen_radix=radix;
  endfunction
  protected virtual function void do_record_field_int(string name,uvm_integral_t value,int size,uvm_radix_enum radix);
    int_calls++;
    seen_name=name;
    seen_value=uvm_bitstream_t'(value);
    seen_size=size;
    seen_radix=radix;
  endfunction
  protected virtual function void do_record_field_real(string name,real value);endfunction
  protected virtual function void do_record_string(string name,string value);endfunction
  protected virtual function void do_record_time(string name,time value);endfunction
  protected virtual function void do_record_generic(string name,string value,string type_name);endfunction
endclass
class stream93 extends uvm_tr_stream;
  function new(string name="stream93");
    super.new(name);
  endfunction
  protected virtual function void do_open(uvm_tr_database db,string scope,string stream_type_name);endfunction
  protected virtual function void do_close();endfunction
  protected virtual function void do_free();endfunction
  protected virtual function uvm_recorder do_open_recorder(string name,time open_time,string type_name);
    recorder93 result_value;
    result_value=new(name);
    return result_value;
  endfunction
endclass
class database93 extends uvm_tr_database;
  function new(string name="database93");
    super.new(name);
  endfunction
  protected virtual function bit do_open_db();
    return 1;
  endfunction
  protected virtual function bit do_close_db();
    return 1;
  endfunction
  protected virtual function uvm_tr_stream do_open_stream(string name,string scope,string type_name);
    stream93 result_value;
    result_value=new(name);
    return result_value;
  endfunction
  protected virtual function void do_establish_link(uvm_link_base link);endfunction
endclass
function automatic bit selected93(uvm_radix_enum seen,uvm_radix_enum requested,uvm_radix_enum chosen_default);
  // The standard does not fix which side of the implementation hook resolves NORADIX.
  return requested==UVM_NORADIX?(seen==UVM_NORADIX || seen==chosen_default):seen==requested;
endfunction
initial begin
  database93 db;
  stream93 stream_value;
  recorder93 record_value,peer;
  uvm_radix_enum radices[$],chosen_default;
  uvm_bitstream_t wide_value;
  uvm_integral_t int_value;
  bit opened,wide_ok,int_ok,default_ok;
  int wide_size,int_size;
  db=new();
  opened=db.open_db();
  if(!$cast(stream_value,db.open_stream("stream93"))) $fatal(1,"missing original stream93");
  if(!$cast(record_value,stream_value.open_recorder("record93",0))) $fatal(1,"missing original recorder93");
  if(!$cast(peer,stream_value.open_recorder("peer93",0))) $fatal(1,"missing original peer93");
  chosen_default=VARIANT==0?UVM_OCT:UVM_DEC;
  record_value.set_default_radix(chosen_default);
  wide_size=VARIANT==0?128:192;
  int_size=VARIANT==0?32:64;
  wide_value='0;
  wide_value[wide_size-2]=1;
  wide_value[15:0]=VARIANT==0?16'h4b61:16'h5a37;
  int_value=VARIANT==0?uvm_integral_t'(32'h8f2a4b61):uvm_integral_t'(64'hc1d2e3f412345678);
  radices={UVM_BIN,UVM_DEC,UVM_UNSIGNED,UVM_UNFORMAT2,UVM_UNFORMAT4,UVM_OCT,UVM_HEX,UVM_STRING,UVM_TIME,UVM_ENUM,UVM_REAL,UVM_REAL_DEC,UVM_REAL_EXP,UVM_NORADIX};
  foreach(radices[i]) begin
    record_value.record_field("wide93",wide_value,wide_size,radices[i]);
    wide_ok=record_value.seen_name=="wide93" && record_value.seen_value==wide_value && record_value.seen_size==wide_size && selected93(record_value.seen_radix,radices[i],chosen_default);
    record_value.record_field_int("int93",int_value,int_size,radices[i]);
    int_ok=record_value.seen_name=="int93" && record_value.seen_value==uvm_bitstream_t'(int_value) && record_value.seen_size==int_size && selected93(record_value.seen_radix,radices[i],chosen_default);
    default_ok=record_value.get_default_radix()==chosen_default && peer.get_default_radix()==UVM_HEX;
    $display("UT: radix93 %s %s wide %0d int %0d calls %0d default %0d peer %0d",CASE_NAME,radices[i].name(),wide_ok,int_ok,
      record_value.wide_calls==i+1 && record_value.int_calls==i+1,default_ok,peer.wide_calls==0 && peer.int_calls==0);
  end
  $finish;
end
