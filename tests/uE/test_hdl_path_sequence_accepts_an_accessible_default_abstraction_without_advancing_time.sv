/*
:name: test_hdl_path_sequence_accepts_an_accessible_default_abstraction_without_advancing_time
:description: HDL path sequence accepts an accessible path under the default abstraction in zero time (E.7)
:tags: uE uvm
:type: simulation
:lrm: 1800.2-2020 E.7 E.7.2 18.1.2.1 18.1.2.2 18.1.2.6 18.1.6.9 18.4.2.1 18.4.2.2 18.5.3.2 19.6.2.1 6.6.3.2 D.4.4 1800-2023 6.21
:uvm: 2020.3.1
:uvm_dpi: yes
:uvm_hdl_backend: vpi
:uvm_defines: UVM_REGEX_NO_DPI UVM_CMDLINE_NO_DPI
:dpi_c: @../../tools/uvm_hdl_vpi.cpp
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_hdl_path_sequence_accepts_an_accessible_default_abstraction_without_advancing_time.expected
*/
// Accessible-path control; this does not assert the absence of reads.
// Run with tools/run_verilator_hdl.py; ordinary runs do not link this DPI.
module test_hdl_path_sequence_accepts_an_accessible_default_abstraction_without_advancing_time;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import "DPI-C" function void uvm_test_hdl_reset_counts();
  import "DPI-C" function int uvm_test_hdl_count(int operation);
  logic [7:0] live /*verilator public_flat_rw*/;
  class model_block extends uvm_reg_block;
    function new(); super.new("blk", UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    uvm_reg_field field;
    function new(string name); super.new(name, 8, UVM_NO_COVERAGE); endfunction
    function void build();
      field = uvm_reg_field::type_id::create("value");
      field.configure(this, 8, 0, "RW", 0, 0, 1, 0, 0);
    endfunction
  endclass
  class warning_probe extends uvm_report_catcher;
    int warnings = 0;
    int errors = 0;
    function new(); super.new("probe"); endfunction
    virtual function action_e catch();
      if (get_severity() == UVM_WARNING) begin warnings++; return CAUGHT; end
      if (get_severity() == UVM_ERROR) begin errors++; return CAUGHT; end
      return THROW;
    endfunction
  endclass
  initial begin
    automatic model_block blk = new();
    automatic model_reg good = new("good");
    automatic uvm_reg_mem_hdl_paths_seq seq = new();
    automatic warning_probe probe = new();
    time started;
    live = 'h3c;
    blk.configure(null,
                  {"test_hdl_path_sequence_accepts_an_accessible_default_abstraction_",
                   "without_advancing_time"});
    good.configure(blk, null, "live");
    good.build();
    blk.lock_model();
    seq.model = blk;
    uvm_report_cb::add(null, probe);
    uvm_test_hdl_reset_counts();
    started = $time;
    seq.start(null);
    $display("UT: accessible no_warnings %0d no_errors %0d zero_time %0d",
             probe.warnings == 0, probe.errors == 0, $time == started);
    $display("UT: checked %0d no_deposits %0d no_other %0d storage %0d",
             uvm_test_hdl_count(0) > 0, uvm_test_hdl_count(2) == 0,
             uvm_test_hdl_count(3) == 0, live == 'h3c);
    uvm_report_cb::delete(null, probe);
    $finish;
  end
endmodule
