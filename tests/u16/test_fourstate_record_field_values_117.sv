/*
:name: test_fourstate_record_field_values_117
:description: recording delivers four-state X and Z bits unchanged to the recorder hooks, directly and through field macros (IEEE 1800.2-2020 Section 16.4.6.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.4.6.1 16.4.6.2 16.4.7.4 16.4.7.5 5.3.7.1 B.2.2.1.1 B.2.1.2 F.2.1.3 F.2.1.4 7.1.3.1 7.1.4.1 7.2.5.1 1800-2023 5.7.1 6.3.1 6.11 11.4.5 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_fourstate_record_field_values_117.expected
*/
// An original database, stream and recorder capture what each recording hook
// receives. Direct record_field and record_field_int calls and field-macro
// recording of an object with logic fields must deliver the same X and Z bits
// and sizes. The expectation comes from the cited clauses; a two-state
// simulator cannot represent X or Z, so this case is spec-only. Only the lines
// that begin with "UT: " are compared.
module test_fourstate_record_field_values_117;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Captures the value that each recording hook receives. The name form that
  // field macros pass is not specified, so lookups accept a scoped leaf name.
  class capture_recorder117 extends uvm_recorder;
    uvm_bitstream_t values[string];

    function new(string name = "capture_recorder117");
      super.new(name);
    endfunction

    protected virtual function void do_record_field(string name, uvm_bitstream_t value,
                                                    int size, uvm_radix_enum radix);
      values[name] = value;
    endfunction

    protected virtual function void do_record_field_int(string name, uvm_integral_t value,
                                                        int size, uvm_radix_enum radix);
      values[name] = value;
    endfunction

    protected virtual function void do_record_field_real(string name, real value);
    endfunction

    function bit find117(string leaf, output uvm_bitstream_t value);
      foreach (values[key]) begin
        if (key == leaf || (key.len() > leaf.len() &&
            key.substr(key.len() - leaf.len() - 1, key.len() - 1) == {".", leaf})) begin
          value = values[key];
          return 1;
        end
      end
      return 0;
    endfunction

    protected virtual function void do_record_object(string name, uvm_object value);
    endfunction

    protected virtual function void do_record_string(string name, string value);
    endfunction

    protected virtual function void do_record_time(string name, time value);
    endfunction

    protected virtual function void do_record_generic(string name, string value,
                                                      string type_name);
    endfunction
  endclass

  class capture_stream117 extends uvm_tr_stream;
    capture_recorder117 created;

    function new(string name = "capture_stream117");
      super.new(name);
    endfunction

    protected virtual function uvm_recorder do_open_recorder(string name, time open_time,
                                                            string type_name);
      created = new(name);
      return created;
    endfunction
  endclass

  class capture_database117 extends uvm_tr_database;
    function new(string name = "capture_database117");
      super.new(name);
    endfunction

    protected virtual function bit do_open_db();
      return 1;
    endfunction

    protected virtual function bit do_close_db();
      return 1;
    endfunction

    protected virtual function uvm_tr_stream do_open_stream(string name, string scope,
                                                           string type_name);
      capture_stream117 result;
      result = new(name);
      return result;
    endfunction

    protected virtual function void do_establish_link(uvm_link_base link);
    endfunction
  endclass

  class fields117 extends uvm_object;
    logic [7:0] narrow;
    logic [99:0] wide;
    `uvm_object_utils_begin(fields117)
      `uvm_field_int(narrow, UVM_DEFAULT)
      `uvm_field_int(wide, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "fields117");
      super.new(name);
    endfunction
  endclass

  initial begin
    automatic capture_database117 db = new("db117");
    automatic fields117 item = new("item117");
    capture_stream117 stream;
    uvm_recorder recorder;
    uvm_bitstream_t seen[4];
    bit found[4];
    bit opened;
    opened = db.open_db();
    if (!$cast(stream, db.open_stream("stream117"))) $fatal(1, "fourstate117 stream missing");
    recorder = stream.open_recorder("record117", 0);
    recorder.record_field("direct_wide", 'b1x0z_10xz, 8, UVM_BIN);
    recorder.record_field_int("direct_small", 'bz0x1, 4, UVM_BIN);
    item.narrow = 8'b1x0z_z0x1;
    item.wide = {96'h0, 4'bzx10};
    item.record(recorder);
    found[0] = stream.created.find117("direct_wide", seen[0]);
    found[1] = stream.created.find117("direct_small", seen[1]);
    found[2] = stream.created.find117("narrow", seen[2]);
    found[3] = stream.created.find117("wide", seen[3]);
    $display("UT: direct wide %0d small %0d", found[0] && seen[0][7:0] === 8'b1x0z_10xz,
             found[1] && seen[1][3:0] === 4'bz0x1);
    $display("UT: fields narrow %0d wide %0d", found[2] && seen[2][7:0] === 8'b1x0z_z0x1,
             found[3] && seen[3][99:0] === {96'h0, 4'bzx10});
    $finish;
  end
endmodule
