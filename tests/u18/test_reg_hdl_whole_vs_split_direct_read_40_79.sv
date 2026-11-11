/*
:name: test_reg_hdl_whole_vs_split_direct_read_40_79
:description: original register HDL path observations for 18.4.6.10
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.6.10 18.4.6.4 18.4.6.5 18.4.6.7 18.4.6.9 17.2.1.7 17.2.3.1 18.1.2.2 18.1.6.4 18.1.6.7 18.1.6.8 18.1.6.9 18.4.2.1 18.4.2.2 18.5.3.2 18.4.4.11 18.4.4.12 18.4.6.10 19.6.2.2 19.6.2.7 19.1.1.2.4 19.1.1.2.6 19.1.1.2.7 19.1.1.2.8 19.1.1.2.9 19.1.1.2.13 1800-2023 6.21 7.6 8.18.1 13.5.1
:uvm: 2020.3.1
:uvm_dpi: yes
:uvm_hdl_backend: vpi
:uvm_defines: UVM_REGEX_NO_DPI UVM_CMDLINE_NO_DPI
:dpi_c: @../../tools/uvm_hdl_vpi.cpp
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers79/hdl_models79.svh
:expected_exit: 0
:expected_stdout: @test_reg_hdl_whole_vs_split_direct_read_40_79.expected
*/
// What it checks:
// 1. A -1/-1 slice implementing the entire register preserves complete
//    register access functionality.
// 2. The printed unqualified virtual backdoor_read task is callable through a
//    register receiver from public module scope.
// 3. The base backdoor_read implementation uses the UVM HDL support routines
//    to read the register.
//
// Variant: The number 16 or 40 is the register width: the whole register and
// the split pair of half-width variables hold 40-bit values.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.4.6.5 (UVM-REG-HDL-WHOLE-VARIABLE-ACCESS) gives rule 1
//    above. Setup: Actual public 16/40-bit HDL variables under the unchanged
//    original VPI backend. One register uses a single -1/-1 whole-variable
//    path, while an independent reference uses legal high/low slices of two
//    distinct HDL variables. Direct read inputs call the printed public
//    backdoor_read task from module scope; separate peek controls do not prove
//    that public declaration. Original backend counters expose HDL reads
//    without prescribing exact call counts. Expected: Whole-variable and legal
//    split references return fresh full-width values and receive independent
//    deposits without changing peers.
// 2. 1800.2-2020 18.4.6.10 (UVM-REG-BACKDOOR-READ-PUBLIC-CALL) gives rule 2
//    above. Setup: Actual public 16/40-bit HDL variables under the unchanged
//    original VPI backend. One register uses a single -1/-1 whole-variable
//    path, while an independent reference uses legal high/low slices of two
//    distinct HDL variables. Direct read inputs call the printed public
//    backdoor_read task from module scope; separate peek controls do not prove
//    that public declaration. Original backend counters expose HDL reads
//    without prescribing exact call counts. Expected: Direct calls build and
//    expose successful fresh full-width read observations for both whole and
//    split targets.
// 3. 1800.2-2020 18.4.6.10 (UVM-REG-BACKDOOR-READ-HDLSUPPORT) gives rule 3
//    above. Setup: Actual public 16/40-bit HDL variables under the unchanged
//    original VPI backend. One register uses a single -1/-1 whole-variable
//    path, while an independent reference uses legal high/low slices of two
//    distinct HDL variables. Direct read inputs call the printed public
//    backdoor_read task from module scope; separate peek controls do not prove
//    that public declaration. Original backend counters expose HDL reads
//    without prescribing exact call counts. Expected: Direct task calls return
//    the current actual storage values, record HDL reads and leave storage and
//    peer unchanged.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Standard public API observations; independent expectations precede runs.
// Real public HDL storage; no vendor overlay or path/value mock.
module test_reg_hdl_whole_vs_split_direct_read_40_79;
  import uvm_pkg::*;
  `include "hdl_models79.svh"
  import "DPI-C" function void uvm_test_hdl_reset_counts();
  import "DPI-C" function int uvm_test_hdl_count(int operation);
  logic [39:0] whole_value /*verilator public_flat_rw*/;
  logic [19:0] split_high /*verilator public_flat_rw*/;
  logic [19:0] split_low /*verilator public_flat_rw*/;
  logic [39:0] peer_value /*verilator public_flat_rw*/;
  localparam string ROOT_PATH="test_reg_hdl_whole_vs_split_direct_read_40_79";
  initial begin
    automatic block79 owner=new();
    register79 whole_reg,split_reg,target;
    automatic uvm_reg_item operation=new("read79");
    uvm_status_e status;
    uvm_reg_data_t actual,wanted_whole,wanted_split,wanted;
    int cycle,target_index;
    bit ok,unchanged;
    owner.configure(null,ROOT_PATH);
    whole_reg=physical_reg79(owner,"whole79",40,1);
    split_reg=physical_reg79(owner,"split79",40,0);
    whole_value=40'h123456789a;{split_high,split_low}=40'hfedcba987;peer_value=40'h5aa55aa55a;
    #1;
    for (cycle=0;cycle<2;cycle++) begin
      wanted_whole=cycle==0 ? 40'h123456789a : 40'he1d2c3b4a5;
      wanted_split=cycle==0 ? 40'hfedcba987 : 40'h91a2b3c4d5;
      whole_value=wanted_whole;{split_high,split_low}=wanted_split;#1;
      for (target_index=0;target_index<2;target_index++) begin
        target=target_index==0 ? whole_reg : split_reg;
        wanted=target_index==0 ? wanted_whole : wanted_split;
        actual='1;uvm_test_hdl_reset_counts();
        operation.set_element_kind(UVM_REG);operation.set_element(target);
        operation.set_kind(UVM_READ);operation.set_door(UVM_BACKDOOR);
        operation.set_bd_kind("RTL");operation.set_value_size(1);operation.set_value('1);
        operation.set_status(UVM_NOT_OK);
        target.backdoor_read(operation);
        status=operation.get_status();actual=operation.get_value(0);
        unchanged=whole_value==wanted_whole && {split_high,split_low}==wanted_split &&
                  peer_value==40'h5aa55aa55a;
        $display("UT: physical79 read cycle %0d target %0d status %0b data %0b dpi %0b same %0b",
          cycle,target_index,status==UVM_IS_OK,actual==wanted,
          uvm_test_hdl_count(1)>0,unchanged);
      end
    end
    $finish;
  end
endmodule
