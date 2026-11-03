/*
:name: test_report_server_message_database_replacement_and_clear_are_local
:description: report server message database replacement and clear are local
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.5.1.2.12 6.5.1.2.11 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_server_message_database_replacement_and_clear_are_local.expected
*/
module test_report_server_message_database_replacement_and_clear_are_local;
  import uvm_pkg::*;
  // Original databases are identity tokens; no recording backend runs.
  class original_database extends uvm_tr_database;
    function new(string name); super.new(name); endfunction
    protected function bit do_open_db(); return 0; endfunction
    protected function bit do_close_db(); return 0; endfunction
    protected function uvm_tr_stream do_open_stream(string name, string scope, string type_name);
      return null;
    endfunction
    protected function void do_establish_link(uvm_link_base link); endfunction
  endclass
  initial begin
    automatic uvm_default_report_server first = new();
    automatic uvm_default_report_server peer = new();
    automatic uvm_report_server view = first;
    automatic original_database a = new("a");
    automatic original_database b = new("b");
    view.set_message_database(a); peer.set_message_database(b);
    $display("UT: databases exact %0d/%0d", view.get_message_database() == a,
             peer.get_message_database() == b);
    view.set_message_database(b);
    $display("UT: database_replaced selected %0d peer %0d", view.get_message_database() == b,
             peer.get_message_database() == b);
    view.set_message_database(null);
    $display("UT: database_clear selected %0d peer %0d", view.get_message_database() == null,
             peer.get_message_database() == b);
    $finish;
  end
endmodule
