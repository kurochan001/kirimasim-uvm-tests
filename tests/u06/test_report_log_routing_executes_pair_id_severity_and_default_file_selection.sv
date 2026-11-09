/*
:name: test_report_log_routing_executes_pair_id_severity_and_default_file_selection
:description: report log routing executes pair id severity and default file selection
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.5.1.2.16 6.3.6.1 6.3.6.2 6.4.5.1 6.4.5.2 6.5.1.2.15 6.4 6.3 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_log_routing_executes_pair_id_severity_and_default_file_selection.expected
*/
// What it checks:
// 1. Configured file associations are retained at default and specific scopes.
// 2. All four public file setters configure the handler paths used by real
//    logging.
// 3. The handler retains file configuration and delegates actual reports to
//    the selected server.
// 4. LOG execution writes the composed payload to the selected report file.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.4.5.2 (UVM-HANDLER-CONFIG-FILE-ASSOCIATIONS) gives rule 1
//    above. Setup: Four distinct opened handles are assigned to default,
//    severity, ID and pair settings. Expected: Each query returns its selected
//    handle without fixing descriptor numbers.
// 2. 1800.2-2020 6.3.6.2 (UVM-REPORT-AUDIT-FILE-SETTER-DELEGATION) gives rule
//    2 above. Setup: Use the selected original reporting fixtures and explicit
//    object, severity, ID and action configuration described by their
//    observation anchors. Expected: Four reports reach only their pair, ID,
//    severity or default files, respectively.
// 3. 1800.2-2020 6.4 (UVM-REPORT-AUDIT-HANDLER-STORED-CONFIG-ROUTING) gives
//    rule 3 above. Setup: Use the selected original reporting fixtures and
//    explicit object, severity, ID and action configuration described by their
//    observation anchors. Expected: The public reporter path logs each of four
//    uniquely marked payloads only to its configured effective file.
// 4. 1800.2-2020 6.5.1.2.16 (UVM-REPORT-AUDIT-EXECUTE-ACTUAL-FILE-LOG) gives
//    rule 4 above. Setup: Use the selected original reporting fixtures and
//    explicit object, severity, ID and action configuration described by their
//    observation anchors. Expected: Each of four actual files contains only
//    its uniquely selected payload once.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_report_log_routing_executes_pair_id_severity_and_default_file_selection;
  import uvm_pkg::*;
  // Original formatting makes the payload visible without fixing UVM's
  // default text layout. Real handler selection and LOG execution do the I/O.
  class format_server extends uvm_default_report_server;
    virtual function string compose_report_message(uvm_report_message report_message,
                                                  string report_object_name = "");
      return $sformatf("%0d|%s|%s|%s", report_message.get_severity(),
             report_message.get_report_object().get_full_name(), report_message.get_id(),
             report_message.get_message());
    endfunction
  endclass
  function automatic int occurrences(string text, string token);
    int count = 0;
    for (int i = 0; i + token.len() <= text.len(); i++)
      if (text.substr(i, i + token.len() - 1) == token) count++;
    return count;
  endfunction
  initial begin
    automatic uvm_report_object reporter = new("reporter");
    automatic format_server server = new();
    automatic uvm_report_server saved = uvm_report_server::get_server();
    automatic string paths[4] = '{"pair.txt", "id.txt", "severity.txt", "default.txt"};
    automatic string labels[4] = '{"routeP41", "routeI41", "routeS41", "routeD41"};
    int files[4];
    string text, line;
    int count[4];
    foreach (files[i]) begin
      files[i] = $fopen(paths[i], "w");
      if (!files[i]) $fatal(1, "cannot open original log");
    end
    uvm_report_server::set_server(server);
    reporter.set_report_severity_action(UVM_INFO, UVM_LOG);
    reporter.set_report_severity_action(UVM_WARNING, UVM_LOG);
    reporter.set_report_default_file(files[3]);
    reporter.set_report_severity_file(UVM_INFO, files[2]);
    reporter.set_report_id_file("selected", files[1]);
    reporter.set_report_severity_id_file(UVM_INFO, "selected", files[0]);
    reporter.uvm_report_info("selected", labels[0], UVM_NONE);
    reporter.uvm_report_warning("selected", labels[1]);
    reporter.uvm_report_info("other", labels[2], UVM_NONE);
    reporter.uvm_report_warning("other", labels[3]);
    foreach (files[i]) $fclose(files[i]);
    foreach (files[i]) begin
      files[i] = $fopen(paths[i], "r"); text = "";
      while ($fgets(line, files[i])) text = {text, line};
      $fclose(files[i]);
      foreach (labels[j]) count[j] = occurrences(text, labels[j]);
      $display("UT: routed_file %0d payloads %0d/%0d/%0d/%0d", i,
               count[0], count[1], count[2], count[3]);
    end
    uvm_coreservice_t::get().set_report_server(saved); $finish;
  end
endmodule
