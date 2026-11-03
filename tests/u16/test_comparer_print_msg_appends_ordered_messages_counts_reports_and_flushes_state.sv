/*
:name: test_comparer_print_msg_appends_ordered_messages_counts_reports_and_flushes_state
:description: comparer print msg appends ordered messages counts reports and flushes state
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.3.7 16.3.3.8 16.3.3.9 16.3.2.2 16.3.5.1 16.3.5.2 16.3.5.3 6.6.5 D.4.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_print_msg_appends_ordered_messages_counts_reports_and_flushes_state.expected
*/
module test_comparer_print_msg_appends_ordered_messages_counts_reports_and_flushes_state;
  import uvm_pkg::*;
  // A limit of five keeps both calls away from the limit-boundary reading.
  // Only original message tokens and the separating newline are examined.
  bit observe=0;
  function automatic int find_token(string text,string token);
    for (int i=0;i+token.len()<=text.len();i++)
      if (text.substr(i,i+token.len()-1)==token) return i;
    return -1;
  endfunction
  class probe extends uvm_report_catcher;
    int messages=0;
    bit first_seen=0,second_seen=0,info_only=1;
    virtual function action_e catch();
      if (observe && (find_token(get_message(),"FIRST43")>=0 ||
                      find_token(get_message(),"SECOND43")>=0)) begin
        messages++; first_seen|=find_token(get_message(),"FIRST43")>=0;
        second_seen|=find_token(get_message(),"SECOND43")>=0;
        info_only&=get_severity()==UVM_INFO; return CAUGHT;
      end
      return THROW;
    endfunction
  endclass
  initial begin
    automatic uvm_comparer comparer=new();
    automatic probe catcher=new();
    string text;
    int first_pos,second_pos;
    bit separator;
    comparer.set_show_max(5); comparer.set_verbosity(UVM_NONE); comparer.set_severity(UVM_INFO);
    $display("UT: messages_initial count %0d empty %0d",comparer.get_result(),
             comparer.get_miscompares()=="");
    uvm_report_cb::add(null,catcher); observe=1;
    comparer.print_msg("FIRST43"); comparer.print_msg("SECOND43"); observe=0;
    text=comparer.get_miscompares(); first_pos=find_token(text,"FIRST43");
    second_pos=find_token(text,"SECOND43"); separator=0;
    if (first_pos>=0 && second_pos>first_pos)
      for (int i=first_pos+7;i<second_pos;i++) if (text[i]==10) separator=1;
    $display("UT: messages_stored count %0d first %0d second %0d order %0d newline %0d",
             comparer.get_result(),first_pos>=0,second_pos>=0,second_pos>first_pos,separator);
    $display("UT: messages_reported count %0d first %0d second %0d info %0d",catcher.messages,
             catcher.first_seen,catcher.second_seen,catcher.info_only);
    comparer.flush();
    $display("UT: messages_flushed count %0d empty %0d",comparer.get_result(),
             comparer.get_miscompares()=="");
    uvm_report_cb::delete(null,catcher); $finish;
  end
endmodule
