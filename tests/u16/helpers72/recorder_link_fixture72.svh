// Original in-memory endpoints and callbacks; no external recording backend.
class recorder72 extends uvm_recorder;
  function new(string name); super.new(name); endfunction
  protected virtual function void do_open(uvm_tr_stream stream, time open_time,
                                          string type_name); endfunction
  protected virtual function void do_close(time close_time); endfunction
  protected virtual function void do_free(); endfunction
  protected virtual function void do_record_field(string name, uvm_bitstream_t value,
                                                 int size, uvm_radix_enum radix); endfunction
  protected virtual function void do_record_field_int(string name, uvm_integral_t value,
                                                     int size, uvm_radix_enum radix); endfunction
  protected virtual function void do_record_field_real(string name, real value); endfunction
  protected virtual function void do_record_string(string name, string value); endfunction
  protected virtual function void do_record_time(string name, time value); endfunction
  protected virtual function void do_record_generic(string name, string value,
                                                   string type_name); endfunction
endclass
class stream72 extends uvm_tr_stream;
  function new(string name); super.new(name); endfunction
  protected virtual function void do_open(uvm_tr_database db, string scope,
                                          string stream_type_name); endfunction
  protected virtual function void do_close(); endfunction
  protected virtual function void do_free(); endfunction
  protected virtual function uvm_recorder do_open_recorder(string name, time open_time,
                                                         string type_name);
    recorder72 value;
    value = new(name); return value;
  endfunction
endclass
class database72 extends uvm_tr_database;
  int link_calls = 0;
  uvm_link_base last_link;
  function new(string name = "database72"); super.new(name); endfunction
  protected virtual function bit do_open_db(); return 1; endfunction
  protected virtual function bit do_close_db(); return 1; endfunction
  protected virtual function uvm_tr_stream do_open_stream(string name, string scope,
                                                        string type_name);
    stream72 value;
    value = new(name); return value;
  endfunction
  protected virtual function void do_establish_link(uvm_link_base link);
    link_calls++; last_link = link;
  endfunction
endclass
class error_window72 extends uvm_report_catcher;
  bit active = 0;
  bit terminal_error = 0;
  int errors = 0;
  function new(); super.new("error_window72"); endfunction
  virtual function action_e catch();
    if (active && (get_severity() == UVM_ERROR || get_severity() == UVM_FATAL)) begin
      errors++;
      if (terminal_error) begin
        $display("UT: recorder_link_error present 1");
        $finish;
      end
      return CAUGHT;
    end
    return THROW;
  endfunction
endclass
function automatic stream72 make_stream72(database72 db, string name);
  stream72 value;
  if (!$cast(value, db.open_stream(name)) || value == null)
    $fatal(1, "original stream setup failed");
  return value;
endfunction
function automatic recorder72 make_recorder72(stream72 stream, string name);
  recorder72 value;
  if (!$cast(value, stream.open_recorder(name, 17, "packet72")) || value == null)
    $fatal(1, "original recorder setup failed");
  return value;
endfunction
