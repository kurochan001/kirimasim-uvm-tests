/*
:name: test_core_service_recording_database_selection_and_restoration
:description: core service selects and restores its default recording database (IEEE 1800.2-2020 Section F.4.1.4.7)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.4.1.4.7 F.4.1.4.6 F.4.1.3 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_core_service_recording_database_selection_and_restoration.expected
*/
// Only the selected database handle is observed; no database is opened.
// Concrete hooks allow construction without choosing an external file format.
module test_core_service_recording_database_selection_and_restoration;
  import uvm_pkg::*;

  class database_type extends uvm_tr_database;
    function new(string name="database"); super.new(name); endfunction
    protected virtual function bit do_open_db(); return 1; endfunction
    protected virtual function bit do_close_db(); return 1; endfunction
    protected virtual function uvm_tr_stream do_open_stream(string name, string scope,
    string type_name); return null; endfunction
    protected virtual function void do_establish_link(uvm_link_base link); endfunction
  endclass
  initial begin
    automatic uvm_coreservice_t core = uvm_coreservice_t::get();
    automatic uvm_tr_database saved = core.get_default_tr_database();
    automatic database_type first = new("first");
    automatic database_type second = new("second");
    core.set_default_tr_database(first);
    $display("UT: first exact %0d", core.get_default_tr_database() == first);
    core.set_default_tr_database(second);
    $display("UT: second exact %0d excludes_first %0d", core.get_default_tr_database() == second,
    core.get_default_tr_database() != first);
    core.set_default_tr_database(saved);
    $display("UT: restored exact %0d", core.get_default_tr_database() == saved);
    $finish;
  end

endmodule
