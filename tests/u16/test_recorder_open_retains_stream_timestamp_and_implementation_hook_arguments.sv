/*
:name: test_recorder_open_retains_stream_timestamp_and_implementation_hook_arguments
:description: opened recorders retain stream identity explicit time and hook metadata (IEEE 1800.2-2020 Section 16.4.3)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.4.3 16.4.4.4 16.4.4.5 16.4.4.6 7.1.3.1 7.1.4.1 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.2.5.1 7.2.7.1 7.2.7.2 7.2.7.3 7.2.7.4 16.4.7.1 16.4.7.2 16.4.7.3 16.4.7.4 16.4.7.5 16.4.7.6 16.4.7.9 16.4.7.10 16.4.7.11 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_recorder_open_retains_stream_timestamp_and_implementation_hook_arguments.expected
*/
// In-memory recorder hooks only: no database file, DPI or vendor attribute
// macro. Timestamps are explicit recording metadata, not simulation delays.
module test_recorder_open_retains_stream_timestamp_and_implementation_hook_arguments;
  import uvm_pkg::*;

  string order = "";
  class local_recorder extends uvm_recorder;
    int opens = 0;
    int closes = 0;
    int frees = 0;
    uvm_tr_stream seen_stream;
    time seen_open;
    time seen_close;
    string seen_type;
    bit [5:0] attributes = 0;
    function new(string name="local_recorder"); super.new(name); endfunction
    protected virtual function void do_open(uvm_tr_stream stream, time open_time, string type_name);
      opens++; seen_stream = stream; seen_open = open_time; seen_type = type_name;
    endfunction
    protected virtual function void do_close(time close_time);
      closes++; seen_close = close_time; order = {order, "C"};
    endfunction
    protected virtual function void do_free(); frees++; order = {order, "F"}; endfunction
    protected virtual function void do_record_field(string name, uvm_bitstream_t value,
                                                    int size, uvm_radix_enum radix);
      attributes[0] = name == "wide" && value == (uvm_bitstream_t'(1) << 100) &&
                      size == 128 && radix == UVM_HEX;
    endfunction
    protected virtual function void do_record_field_int(string name, uvm_integral_t value,
                                                        int size, uvm_radix_enum radix);
      attributes[1] = name == "small" && value == 42 && size == 8 && radix == UVM_DEC;
    endfunction
    protected virtual function void do_record_field_real(string name, real value);
      attributes[2] = name == "real" && value > 1.49 && value < 1.51;
    endfunction
    protected virtual function void do_record_string(string name, string value);
      attributes[3] = name == "text" && value == "hello";
    endfunction
    protected virtual function void do_record_time(string name, time value);
      attributes[4] = name == "stamp" && value == 73;
    endfunction
    protected virtual function void do_record_generic(string name, string value, string type_name);
      attributes[5] = name == "generic" && value == "42" && type_name == "counter";
    endfunction
  endclass
  class local_stream extends uvm_tr_stream;
    local_recorder created[$];
    int recorder_calls = 0;
    int closes = 0;
    int frees = 0;
    function new(string name="local_stream"); super.new(name); endfunction
    protected virtual function void do_open(uvm_tr_database db, string scope,
                                             string stream_type_name); endfunction
    protected virtual function void do_close(); closes++; order = {order, "S"}; endfunction
    protected virtual function void do_free(); frees++; order = {order, "T"}; endfunction
    protected virtual function uvm_recorder do_open_recorder(string name, time open_time,
                                                            string type_name);
      local_recorder result_value;
      recorder_calls++; result_value = new(name); created.push_back(result_value);
      return result_value;
    endfunction
  endclass
  class local_database extends uvm_tr_database;
    function new(string name="local_database"); super.new(name); endfunction
    protected virtual function bit do_open_db(); return 1; endfunction
    protected virtual function bit do_close_db(); return 1; endfunction
    protected virtual function uvm_tr_stream do_open_stream(string name, string scope,
                                                           string type_name);
      local_stream result_value;
      result_value = new(name); return result_value;
    endfunction
    protected virtual function void do_establish_link(uvm_link_base link); endfunction
  endclass

  initial begin
    local_database db;
    local_stream stream_value;
    uvm_recorder first_record;
    uvm_recorder second_record;
    bit opened;

    db = new("db"); opened = db.open_db();
    if (!$cast(stream_value, db.open_stream("stream"))) $fatal(1, "stream missing");

    first_record = stream_value.open_recorder("record", 17, "packet");
    $display("UT: opened %0d closed %0d stream %0d time %0d", first_record.is_open(),
    first_record.is_closed(), first_record.get_stream() == stream_value,
    first_record.get_open_time());
    $display("UT: hook calls %0d args %0d", stream_value.created[0].opens,
             stream_value.created[0].seen_stream == stream_value &&
             stream_value.created[0].seen_open == 17 &&
             stream_value.created[0].seen_type == "packet");
    $finish;
  end

endmodule
