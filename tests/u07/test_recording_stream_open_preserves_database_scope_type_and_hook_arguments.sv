/*
:name: test_recording_stream_open_preserves_database_scope_type_and_hook_arguments
:description: opened streams retain their database and explicit or default metadata (IEEE 1800.2-2020 Section 7.2.3.1)
:tags: u07 uvm
:type: simulation
:lrm: 1800.2-2020 7.2.3.1 7.2.3.2 7.2.3.3 7.1.1 7.1.3.1 7.1.3.2 7.1.4.1 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.2.7.1 7.2.7.2 7.2.7.3 7.2.7.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_recording_stream_open_preserves_database_scope_type_and_hook_arguments.expected
*/
// Local hooks supply in-memory streams; no database file or external backend
// is opened. Recorder creation and record contents are outside these cases.
module test_recording_stream_open_preserves_database_scope_type_and_hook_arguments;
  import uvm_pkg::*;

  class local_stream extends uvm_tr_stream;
    int opens = 0;
    int closes = 0;
    int frees = 0;
    uvm_tr_database seen_db;
    string seen_scope;
    string seen_type;
    function new(string name="local_stream"); super.new(name); endfunction
    protected virtual function void do_open(uvm_tr_database db, string scope,
                                             string stream_type_name);
      opens++; seen_db = db; seen_scope = scope; seen_type = stream_type_name;
    endfunction
    protected virtual function void do_close(); closes++; endfunction
    protected virtual function void do_free(); frees++; endfunction
    protected virtual function uvm_recorder do_open_recorder(string name, time open_time,
                                                            string type_name);
      return null;
    endfunction
  endclass
  class local_database extends uvm_tr_database;
    bit allow_open = 1;
    bit allow_stream = 1;
    int stream_calls = 0;
    local_stream created[$];
    function new(string name="local_database"); super.new(name); endfunction
    protected virtual function bit do_open_db(); return allow_open; endfunction
    protected virtual function bit do_close_db(); return 1; endfunction
    protected virtual function uvm_tr_stream do_open_stream(string name, string scope,
                                                           string type_name);
      local_stream result_value;
      stream_calls++;
      if (!allow_stream) return null;
      result_value = new(name); created.push_back(result_value); return result_value;
    endfunction
    protected virtual function void do_establish_link(uvm_link_base link); endfunction
  endclass

  initial begin
    local_database db;
    uvm_tr_stream first_stream;
    uvm_tr_stream second_stream;
    bit result_value;

    db = new("db");

    result_value = db.open_db();
    first_stream = db.open_stream("lane", "env.bus", "packet");
    second_stream = db.open_stream("defaults");
    $display("UT: metadata db %0d name %s scope %s type %s", first_stream.get_db() == db,
             first_stream.get_name(), first_stream.get_scope(),
             first_stream.get_stream_type_name());
    $display("UT: hook calls %0d args %0d", db.created[0].opens,
             db.created[0].seen_db == db && db.created[0].seen_scope == "env.bus" &&
             db.created[0].seen_type == "packet");
    $display("UT: defaults db %0d scope_empty %0d type_empty %0d", second_stream.get_db() == db,
             second_stream.get_scope() == "", second_stream.get_stream_type_name() == "");
    $finish;
  end

endmodule
