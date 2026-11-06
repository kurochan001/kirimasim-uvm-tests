// Original message observers; default report actions are not executed here.
`include "uvm_macros.svh"
class report_observer84 extends uvm_default_report_server;
  int calls, verbosity;
  uvm_severity severity;
  string id, body;
  uvm_report_object source;
  function new(); super.new(); calls=0; endfunction
  virtual function void execute_report_message(uvm_report_message message,
                                                string composed_message);
    calls++; severity=message.get_severity(); verbosity=message.get_verbosity();
    id=message.get_id(); body=message.get_message();
    source=message.get_report_object();
  endfunction
  function bit matches84(uvm_report_object who,uvm_severity kind,int level,
                          string tag,string text);
    return source==who && severity==kind && verbosity==level &&
           id==tag && body==text;
  endfunction
endclass
