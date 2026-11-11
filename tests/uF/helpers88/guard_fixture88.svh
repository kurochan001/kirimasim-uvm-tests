bit fatal_seen88=0,eoe_seen88=0,start_seen88=0,returned88=0,injected88=0;
class fatal_observer88 extends uvm_report_catcher;
  function new();
    super.new("fatal_observer88");
  endfunction
  virtual function action_e catch();
    if (get_severity()==UVM_FATAL) begin
      fatal_seen88=1;
      $display("UT: guard88 fatal injected %0d eoe %0d error_count %0d start_absent %0d",
        injected88,eoe_seen88,uvm_report_server::get_server().get_severity_count(UVM_ERROR)>0,
        !start_seen88);
    end
    return THROW;
  endfunction
endclass
class guard_test88 extends uvm_test;
  `uvm_component_utils(guard_test88)
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  function void inject_error();
    uvm_report_error("original88","intentional independent guard observation",UVM_NONE);
    injected88=1;
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (MODE==0) inject_error();
  endfunction
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    if (MODE==1) inject_error();
    eoe_seen88=1;
  endfunction
  virtual function void start_of_simulation_phase(uvm_phase phase);
    start_seen88=1;
  endfunction
endclass
initial begin
  automatic uvm_root root=uvm_root::get();
  automatic fatal_observer88 observer=new();
  uvm_report_cb::add(root,observer);
  $display("UT: guard88 %s before_errors_zero %0d",CASE_NAME,
    uvm_report_server::get_server().get_severity_count(UVM_ERROR)==0);
  run_test("guard_test88");
  returned88=1;
  $finish;
end
final $display("UT: guard88 final fatal %0d eoe %0d start %0d returned %0d",
  fatal_seen88,eoe_seen88,start_seen88,returned88);
