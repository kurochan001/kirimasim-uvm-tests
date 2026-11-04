/*
:name: test_predefined_common_function_proxies_dispatch_only_the_selected_virtual_component_hook
:description: predefined common function proxies dispatch only the selected virtual component hook
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.8.1.1 9.8.1.1 9.8.1.2 9.8.1.3 9.8.1.4 9.8.1.6 9.8.1.7 9.8.1.8 9.8.1.9 9.3.1.5.1 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_predefined_common_function_proxies_dispatch_only_the_selected_virtual_component_hook.expected
*/
module test_predefined_common_function_proxies_dispatch_only_the_selected_virtual_component_hook;
  import uvm_pkg::*;
  uvm_phase wanted;
  class probe extends uvm_component;
    int calls[8]='{default:0};
    bit context_ok=1;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    function void note(int index,uvm_phase phase);
      calls[index]++;context_ok &= phase==wanted;
    endfunction
    virtual function void build_phase(uvm_phase phase);note(0,phase);endfunction
    virtual function void connect_phase(uvm_phase phase);note(1,phase);endfunction
    virtual function void end_of_elaboration_phase(uvm_phase phase);note(2,phase);endfunction
    virtual function void start_of_simulation_phase(uvm_phase phase);note(3,phase);endfunction
    virtual function void extract_phase(uvm_phase phase);note(4,phase);endfunction
    virtual function void check_phase(uvm_phase phase);note(5,phase);endfunction
    virtual function void report_phase(uvm_phase phase);note(6,phase);endfunction
    virtual function void final_phase(uvm_phase phase);note(7,phase);endfunction
  endclass
  initial begin
    automatic probe selected=new("selected54",null);
    automatic probe peer=new("peer54",null);
    automatic uvm_phase context_node=new("context54",UVM_PHASE_NODE);
    uvm_phase implementations[8];
    int saved[8];
    wanted=context_node;
    implementations[0]=uvm_build_phase::get();
    implementations[1]=uvm_connect_phase::get();
    implementations[2]=uvm_end_of_elaboration_phase::get();
    implementations[3]=uvm_start_of_simulation_phase::get();
    implementations[4]=uvm_extract_phase::get();
    implementations[5]=uvm_check_phase::get();
    implementations[6]=uvm_report_phase::get();
    implementations[7]=uvm_final_phase::get();
    foreach (saved[j]) saved[j]=selected.calls[j];
    implementations[0].exec_func(selected,context_node);
    begin
      bit selected_only;
      selected_only=1;
      foreach (saved[j])
        selected_only &= selected.calls[j]==saved[j]+(j==0) && peer.calls[j]==0;
      $display("UT: common_delegate build selected_only %0d context %0d",
        selected_only,selected.context_ok);
    end
    foreach (saved[j]) saved[j]=selected.calls[j];
    implementations[1].exec_func(selected,context_node);
    begin
      bit selected_only;
      selected_only=1;
      foreach (saved[j])
        selected_only &= selected.calls[j]==saved[j]+(j==1) && peer.calls[j]==0;
      $display("UT: common_delegate connect selected_only %0d context %0d",
        selected_only,selected.context_ok);
    end
    foreach (saved[j]) saved[j]=selected.calls[j];
    implementations[2].exec_func(selected,context_node);
    begin
      bit selected_only;
      selected_only=1;
      foreach (saved[j])
        selected_only &= selected.calls[j]==saved[j]+(j==2) && peer.calls[j]==0;
      $display("UT: common_delegate end_of_elaboration selected_only %0d context %0d",
        selected_only,selected.context_ok);
    end
    foreach (saved[j]) saved[j]=selected.calls[j];
    implementations[3].exec_func(selected,context_node);
    begin
      bit selected_only;
      selected_only=1;
      foreach (saved[j])
        selected_only &= selected.calls[j]==saved[j]+(j==3) && peer.calls[j]==0;
      $display("UT: common_delegate start_of_simulation selected_only %0d context %0d",
        selected_only,selected.context_ok);
    end
    foreach (saved[j]) saved[j]=selected.calls[j];
    implementations[4].exec_func(selected,context_node);
    begin
      bit selected_only;
      selected_only=1;
      foreach (saved[j])
        selected_only &= selected.calls[j]==saved[j]+(j==4) && peer.calls[j]==0;
      $display("UT: common_delegate extract selected_only %0d context %0d",
        selected_only,selected.context_ok);
    end
    foreach (saved[j]) saved[j]=selected.calls[j];
    implementations[5].exec_func(selected,context_node);
    begin
      bit selected_only;
      selected_only=1;
      foreach (saved[j])
        selected_only &= selected.calls[j]==saved[j]+(j==5) && peer.calls[j]==0;
      $display("UT: common_delegate check selected_only %0d context %0d",
        selected_only,selected.context_ok);
    end
    foreach (saved[j]) saved[j]=selected.calls[j];
    implementations[6].exec_func(selected,context_node);
    begin
      bit selected_only;
      selected_only=1;
      foreach (saved[j])
        selected_only &= selected.calls[j]==saved[j]+(j==6) && peer.calls[j]==0;
      $display("UT: common_delegate report selected_only %0d context %0d",
        selected_only,selected.context_ok);
    end
    foreach (saved[j]) saved[j]=selected.calls[j];
    implementations[7].exec_func(selected,context_node);
    begin
      bit selected_only;
      selected_only=1;
      foreach (saved[j])
        selected_only &= selected.calls[j]==saved[j]+(j==7) && peer.calls[j]==0;
      $display("UT: common_delegate final selected_only %0d context %0d",
        selected_only,selected.context_ok);
    end
    $finish;
  end
endmodule
