// Original observers of actual macro reporting; no default text/exit policy oracle.
`include "uvm_macros.svh"
class macro_server81 extends uvm_default_report_server;
  int calls, verbosity, line_number;
  uvm_severity severity;
  string id, message, filename;
  uvm_report_object source;
  function void reset_observer81();
    calls=0; verbosity=-1; line_number=-1;
    id=""; message=""; filename=""; source=null;
  endfunction
  virtual function void execute_report_message(uvm_report_message report_message,
                                                string composed_message);
    calls++; severity=report_message.get_severity();
    verbosity=report_message.get_verbosity(); id=report_message.get_id();
    message=report_message.get_message(); filename=report_message.get_filename();
    line_number=report_message.get_line(); source=report_message.get_report_object();
    // Deliberately do not execute default DISPLAY/COUNT/EXIT actions.
  endfunction
endclass
class macro_reporter81 extends uvm_report_object;
  int formats, otherwise_count, expected_line;
  string expected_file;
  function new(string name); super.new(name); endfunction
  function string make_message81(); formats++; return "body81"; endfunction
  function void emit_info(uvm_report_object chosen, string id,
                             int verbosity, bit selected=1);
    expected_file=`__FILE__;
    if (selected) begin
      expected_line=`__LINE__+1;
      `uvm_info(id,make_message81(),verbosity)
    end
    else otherwise_count++;
  endfunction
  function void emit_warning(uvm_report_object chosen, string id,
                             int verbosity, bit selected=1);
    expected_file=`__FILE__;
    if (selected) begin
      expected_line=`__LINE__+1;
      `uvm_warning(id,make_message81())
    end
    else otherwise_count++;
  endfunction
  function void emit_error(uvm_report_object chosen, string id,
                             int verbosity, bit selected=1);
    expected_file=`__FILE__;
    if (selected) begin
      expected_line=`__LINE__+1;
      `uvm_error(id,make_message81())
    end
    else otherwise_count++;
  endfunction
  function void emit_fatal(uvm_report_object chosen, string id,
                             int verbosity, bit selected=1);
    expected_file=`__FILE__;
    if (selected) begin
      expected_line=`__LINE__+1;
      `uvm_fatal(id,make_message81())
    end
    else otherwise_count++;
  endfunction
  function void emit_info_context(uvm_report_object chosen, string id,
                             int verbosity, bit selected=1);
    expected_file=`__FILE__;
    if (selected) begin
      expected_line=`__LINE__+1;
      `uvm_info_context(id,make_message81(),verbosity,chosen)
    end
    else otherwise_count++;
  endfunction
  function void emit_warning_context(uvm_report_object chosen, string id,
                             int verbosity, bit selected=1);
    expected_file=`__FILE__;
    if (selected) begin
      expected_line=`__LINE__+1;
      `uvm_warning_context(id,make_message81(),chosen)
    end
    else otherwise_count++;
  endfunction
  function void emit_error_context(uvm_report_object chosen, string id,
                             int verbosity, bit selected=1);
    expected_file=`__FILE__;
    if (selected) begin
      expected_line=`__LINE__+1;
      `uvm_error_context(id,make_message81(),chosen)
    end
    else otherwise_count++;
  endfunction
  function void emit_fatal_context(uvm_report_object chosen, string id,
                             int verbosity, bit selected=1);
    expected_file=`__FILE__;
    if (selected) begin
      expected_line=`__LINE__+1;
      `uvm_fatal_context(id,make_message81(),chosen)
    end
    else otherwise_count++;
  endfunction
endclass
class macro_statement81 extends macro_reporter81;
  function new(); super.new("statement81"); endfunction
  function void statement_info(uvm_report_object chosen, string id,
                                   int verbosity, bit selected);
    if (selected)
      `uvm_info(id,make_message81(),verbosity)
    else
      otherwise_count++;
  endfunction
  function void statement_warning(uvm_report_object chosen, string id,
                                   int verbosity, bit selected);
    if (selected)
      `uvm_warning(id,make_message81())
    else
      otherwise_count++;
  endfunction
  function void statement_error(uvm_report_object chosen, string id,
                                   int verbosity, bit selected);
    if (selected)
      `uvm_error(id,make_message81())
    else
      otherwise_count++;
  endfunction
  function void statement_fatal(uvm_report_object chosen, string id,
                                   int verbosity, bit selected);
    if (selected)
      `uvm_fatal(id,make_message81())
    else
      otherwise_count++;
  endfunction
  function void statement_info_context(uvm_report_object chosen, string id,
                                   int verbosity, bit selected);
    if (selected)
      `uvm_info_context(id,make_message81(),verbosity,chosen)
    else
      otherwise_count++;
  endfunction
  function void statement_warning_context(uvm_report_object chosen, string id,
                                   int verbosity, bit selected);
    if (selected)
      `uvm_warning_context(id,make_message81(),chosen)
    else
      otherwise_count++;
  endfunction
  function void statement_error_context(uvm_report_object chosen, string id,
                                   int verbosity, bit selected);
    if (selected)
      `uvm_error_context(id,make_message81(),chosen)
    else
      otherwise_count++;
  endfunction
  function void statement_fatal_context(uvm_report_object chosen, string id,
                                   int verbosity, bit selected);
    if (selected)
      `uvm_fatal_context(id,make_message81(),chosen)
    else
      otherwise_count++;
  endfunction
endclass
