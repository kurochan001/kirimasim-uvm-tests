/*
:name: test_reporting_constructors_preserve_default_explicit_empty_names_and_exact_bases
:description: reporting constructors preserve default explicit empty names and exact bases
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.3.2 6.3.1 6.3.3.1 6.2.1 6.2.2.1 6.4.1 6.4.2.1 6.6.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reporting_constructors_preserve_default_explicit_empty_names_and_exact_bases.expected
*/
module test_reporting_constructors_preserve_default_explicit_empty_names_and_exact_bases;
  import uvm_pkg::*;
  class original_catcher extends uvm_report_catcher;
    virtual function action_e catch(); return THROW; endfunction
  endclass
  class named_catcher extends uvm_report_catcher;
    function new(string name); super.new(name); endfunction
    virtual function action_e catch(); return THROW; endfunction
  endclass
  initial begin
    automatic uvm_report_object ro = new();
    automatic uvm_report_object rn = new("report");
    automatic uvm_report_object re = new("");
    automatic uvm_report_message mo = new();
    automatic uvm_report_message mn = new("message");
    automatic uvm_report_message me = new("");
    automatic uvm_report_handler ho = new();
    automatic uvm_report_handler hn = new("handler");
    automatic uvm_report_handler he = new("");
    automatic original_catcher co = new();
    automatic named_catcher cn = new("catcher");
    automatic named_catcher ce = new("");
    automatic uvm_object rb = rn, mb = mn, hb = hn;
    automatic uvm_callback cb = cn;
    $display("UT: report_names default %0d named %0d empty %0d self %0d base %0d",
             ro.get_name() == "", rn.get_name() == "report", re.get_name() == "",
             rn.uvm_get_report_object() == rn, rb == rn);
    $display("UT: message_names default %0d named %0d empty %0d base %0d",
             mo.get_name() == "uvm_report_message", mn.get_name() == "message",
             me.get_name() == "", mb == mn);
    $display("UT: handler_names default %0d named %0d empty %0d base %0d",
             ho.get_name() == "uvm_report_handler", hn.get_name() == "handler",
             he.get_name() == "", hb == hn);
    $display("UT: catcher_names default %0d named %0d empty %0d base %0d",
             co.get_name() == "uvm_report_catcher", cn.get_name() == "catcher",
             ce.get_name() == "", cb == cn);
    $finish;
  end
endmodule
