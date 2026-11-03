/*
:name: test_report_server_concrete_constructor_exposes_base_names_and_summary_argument_defaults
:description: report server concrete constructor exposes base names and summary argument defaults
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.5.1.2.1 6.5.1.1 6.5.1 6.5.1.2.17 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_server_concrete_constructor_exposes_base_names_and_summary_argument_defaults.expected
*/
module test_report_server_concrete_constructor_exposes_base_names_and_summary_argument_defaults;
  import uvm_pkg::*;
  // Original complete signatures make the base constructible. Stub
  // method bodies are setup, not a reporting/counting implementation oracle.
  class complete_server extends uvm_report_server;
    UVM_FILE summary_file;
    virtual function int get_max_quit_count(); return 0; endfunction
    virtual function void set_max_quit_count(int count, bit overridable = 1); endfunction
    virtual function int get_quit_count(); return 0; endfunction
    virtual function void set_quit_count(int quit_count); endfunction
    virtual function int get_severity_count(uvm_severity severity); return 0; endfunction
    virtual function void set_severity_count(uvm_severity severity, int count); endfunction
    // Extra library hook is setup; no nonstandard API behavior is tested.
    virtual function void set_id_count(string id, int count); endfunction
    virtual function int get_id_count(string id); return 0; endfunction
    virtual function void get_id_set(output string q[$]); q.delete(); endfunction
    virtual function void get_severity_set(output uvm_severity q[$]); q.delete(); endfunction
    virtual function uvm_tr_database get_message_database(); return null; endfunction
    virtual function void set_message_database(uvm_tr_database database); endfunction
    virtual function void process_report_message(uvm_report_message report_message); endfunction
    virtual function string compose_report_message(uvm_report_message report_message,
                                                  string report_object_name = ""); return "";
    endfunction
    virtual function void execute_report_message(uvm_report_message report_message,
                                                string composed_message); endfunction
    virtual function void report_summarize(UVM_FILE file = UVM_STDOUT); summary_file = file;
    endfunction
  endclass
  class named_server extends uvm_report_server;
    UVM_FILE summary_file;
    function new(string name); super.new(name); endfunction
    virtual function int get_max_quit_count(); return 0; endfunction
    virtual function void set_max_quit_count(int count, bit overridable = 1); endfunction
    virtual function int get_quit_count(); return 0; endfunction
    virtual function void set_quit_count(int quit_count); endfunction
    virtual function int get_severity_count(uvm_severity severity); return 0; endfunction
    virtual function void set_severity_count(uvm_severity severity, int count); endfunction
    // Extra library hook is setup; no nonstandard API behavior is tested.
    virtual function void set_id_count(string id, int count); endfunction
    virtual function int get_id_count(string id); return 0; endfunction
    virtual function void get_id_set(output string q[$]); q.delete(); endfunction
    virtual function void get_severity_set(output uvm_severity q[$]); q.delete(); endfunction
    virtual function uvm_tr_database get_message_database(); return null; endfunction
    virtual function void set_message_database(uvm_tr_database database); endfunction
    virtual function void process_report_message(uvm_report_message report_message); endfunction
    virtual function string compose_report_message(uvm_report_message report_message,
                                                  string report_object_name = ""); return "";
    endfunction
    virtual function void execute_report_message(uvm_report_message report_message,
                                                string composed_message); endfunction
    virtual function void report_summarize(UVM_FILE file = UVM_STDOUT); summary_file = file;
    endfunction
  endclass
  initial begin
    automatic complete_server omitted = new();
    automatic named_server named = new("selected");
    automatic named_server empty = new("");
    automatic uvm_report_server view = named;
    automatic uvm_object object_view = named;
    $display("UT: server_names default %0d named %0d empty %0d base %0d",
             omitted.get_name() == "base", named.get_name() == "selected",
             empty.get_name() == "", object_view == named);
    view.report_summarize();
    $display("UT: summary_default %0d", named.summary_file == UVM_STDOUT);
    view.report_summarize(123);
    $display("UT: summary_explicit %0d", named.summary_file == 123);
    $finish;
  end
endmodule
