/*
:name: test_predefined_task_proxies_dispatch_each_original_hook_and_wait_for_its_delayed_return
:description: predefined task proxies dispatch each original hook and wait for its delayed return
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.8.1.5 9.8.2.1 9.8.2.2 9.8.2.3 9.8.2.4 9.8.2.5 9.8.2.6 9.8.2.7 9.8.2.8 9.8.2.9 9.8.2.10 9.8.2.11 9.8.2.12 9.3.1.5.2 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_predefined_task_proxies_dispatch_each_original_hook_and_wait_for_its_delayed_return.expected
*/
// What it checks:
// 1. The run phase task proxy calls and awaits the corresponding virtual
//    component task.
// 2. The pre_reset phase task proxy calls and awaits the corresponding virtual
//    component task.
// 3. The reset phase task proxy calls and awaits the corresponding virtual
//    component task.
// 4. The post_reset phase task proxy calls and awaits the corresponding
//    virtual component task.
// 5. The pre_configure phase task proxy calls and awaits the corresponding
//    virtual component task.
// 6. The configure phase task proxy calls and awaits the corresponding virtual
//    component task.
// 7. The post_configure phase task proxy calls and awaits the corresponding
//    virtual component task.
// 8. The pre_main phase task proxy calls and awaits the corresponding virtual
//    component task.
// 9. The main phase task proxy calls and awaits the corresponding virtual
//    component task.
// 10. The post_main phase task proxy calls and awaits the corresponding
//     virtual component task.
// 11. The pre_shutdown phase task proxy calls and awaits the corresponding
//     virtual component task.
// 12. The shutdown phase task proxy calls and awaits the corresponding virtual
//     component task.
// 13. The post_shutdown phase task proxy calls and awaits the corresponding
//     virtual component task.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 9.8.1.5 (UVM-PHASE-RUNTIME-RUN-TASK-DELEGATE) gives rule 1
//    above. Setup: exec_task is called directly through a base phase view; the
//    original run hook waits two positive delay units. Expected: Only the
//    selected hook enters and completes; the peer stays silent, the context
//    matches and return follows the delayed completion.
// 2. 1800.2-2020 9.8.2.1 (UVM-PHASE-RUNTIME-PRE-RESET-TASK-DELEGATE) gives
//    rule 2 above. Setup: exec_task is called directly through a base phase
//    view; the original pre_reset hook waits two positive delay units.
//    Expected: Only the selected hook enters and completes; the peer stays
//    silent, the context matches and return follows the delayed completion.
// 3. 1800.2-2020 9.8.2.2 (UVM-PHASE-RUNTIME-RESET-TASK-DELEGATE) gives rule 3
//    above. Setup: exec_task is called directly through a base phase view; the
//    original reset hook waits two positive delay units. Expected: Only the
//    selected hook enters and completes; the peer stays silent, the context
//    matches and return follows the delayed completion.
// 4. 1800.2-2020 9.8.2.3 (UVM-PHASE-RUNTIME-POST-RESET-TASK-DELEGATE) gives
//    rule 4 above. Setup: exec_task is called directly through a base phase
//    view; the original post_reset hook waits two positive delay units.
//    Expected: Only the selected hook enters and completes; the peer stays
//    silent, the context matches and return follows the delayed completion.
// 5. 1800.2-2020 9.8.2.4 (UVM-PHASE-RUNTIME-PRE-CONFIGURE-TASK-DELEGATE) gives
//    rule 5 above. Setup: exec_task is called directly through a base phase
//    view; the original pre_configure hook waits two positive delay units.
//    Expected: Only the selected hook enters and completes; the peer stays
//    silent, the context matches and return follows the delayed completion.
// 6. 1800.2-2020 9.8.2.5 (UVM-PHASE-RUNTIME-CONFIGURE-TASK-DELEGATE) gives
//    rule 6 above. Setup: exec_task is called directly through a base phase
//    view; the original configure hook waits two positive delay units.
//    Expected: Only the selected hook enters and completes; the peer stays
//    silent, the context matches and return follows the delayed completion.
// 7. 1800.2-2020 9.8.2.6 (UVM-PHASE-RUNTIME-POST-CONFIGURE-TASK-DELEGATE)
//    gives rule 7 above. Setup: exec_task is called directly through a base
//    phase view; the original post_configure hook waits two positive delay
//    units. Expected: Only the selected hook enters and completes; the peer
//    stays silent, the context matches and return follows the delayed
//    completion.
// 8. 1800.2-2020 9.8.2.7 (UVM-PHASE-RUNTIME-PRE-MAIN-TASK-DELEGATE) gives rule
//    8 above. Setup: exec_task is called directly through a base phase view;
//    the original pre_main hook waits two positive delay units. Expected: Only
//    the selected hook enters and completes; the peer stays silent, the
//    context matches and return follows the delayed completion.
// 9. 1800.2-2020 9.8.2.8 (UVM-PHASE-RUNTIME-MAIN-TASK-DELEGATE) gives rule 9
//    above. Setup: exec_task is called directly through a base phase view; the
//    original main hook waits two positive delay units. Expected: Only the
//    selected hook enters and completes; the peer stays silent, the context
//    matches and return follows the delayed completion.
// 10. 1800.2-2020 9.8.2.9 (UVM-PHASE-RUNTIME-POST-MAIN-TASK-DELEGATE) gives
//     rule 10 above. Setup: exec_task is called directly through a base phase
//     view; the original post_main hook waits two positive delay units.
//     Expected: Only the selected hook enters and completes; the peer stays
//     silent, the context matches and return follows the delayed completion.
// 11. 1800.2-2020 9.8.2.10 (UVM-PHASE-RUNTIME-PRE-SHUTDOWN-TASK-DELEGATE)
//     gives rule 11 above. Setup: exec_task is called directly through a base
//     phase view; the original pre_shutdown hook waits two positive delay
//     units. Expected: Only the selected hook enters and completes; the peer
//     stays silent, the context matches and return follows the delayed
//     completion.
// 12. 1800.2-2020 9.8.2.11 (UVM-PHASE-RUNTIME-SHUTDOWN-TASK-DELEGATE) gives
//     rule 12 above. Setup: exec_task is called directly through a base phase
//     view; the original shutdown hook waits two positive delay units.
//     Expected: Only the selected hook enters and completes; the peer stays
//     silent, the context matches and return follows the delayed completion.
// 13. 1800.2-2020 9.8.2.12 (UVM-PHASE-RUNTIME-POST-SHUTDOWN-TASK-DELEGATE)
//     gives rule 13 above. Setup: exec_task is called directly through a base
//     phase view; the original post_shutdown hook waits two positive delay
//     units. Expected: Only the selected hook enters and completes; the peer
//     stays silent, the context matches and return follows the delayed
//     completion.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_predefined_task_proxies_dispatch_each_original_hook_and_wait_for_its_delayed_return;
  import uvm_pkg::*;
  uvm_phase wanted;
  class probe extends uvm_component;
    int calls[13]='{default:0},completed[13]='{default:0};
    bit context_ok=1;
    function new(string name,uvm_component parent);super.new(name,parent);endfunction
    task note(int index,uvm_phase phase);
      calls[index]++;context_ok &= phase==wanted;#2;completed[index]++;
    endtask
    virtual task run_phase(uvm_phase phase);note(0,phase);endtask
    virtual task pre_reset_phase(uvm_phase phase);note(1,phase);endtask
    virtual task reset_phase(uvm_phase phase);note(2,phase);endtask
    virtual task post_reset_phase(uvm_phase phase);note(3,phase);endtask
    virtual task pre_configure_phase(uvm_phase phase);note(4,phase);endtask
    virtual task configure_phase(uvm_phase phase);note(5,phase);endtask
    virtual task post_configure_phase(uvm_phase phase);note(6,phase);endtask
    virtual task pre_main_phase(uvm_phase phase);note(7,phase);endtask
    virtual task main_phase(uvm_phase phase);note(8,phase);endtask
    virtual task post_main_phase(uvm_phase phase);note(9,phase);endtask
    virtual task pre_shutdown_phase(uvm_phase phase);note(10,phase);endtask
    virtual task shutdown_phase(uvm_phase phase);note(11,phase);endtask
    virtual task post_shutdown_phase(uvm_phase phase);note(12,phase);endtask
  endclass
  initial begin
    automatic probe selected=new("selected54",null);
    automatic probe peer=new("peer54",null);
    automatic uvm_phase context_node=new("context54",UVM_PHASE_NODE);
    uvm_phase implementations[13];
    int saved[13],saved_done[13];
    time entered_at;
    wanted=context_node;
    implementations[0]=uvm_run_phase::get();
    implementations[1]=uvm_pre_reset_phase::get();
    implementations[2]=uvm_reset_phase::get();
    implementations[3]=uvm_post_reset_phase::get();
    implementations[4]=uvm_pre_configure_phase::get();
    implementations[5]=uvm_configure_phase::get();
    implementations[6]=uvm_post_configure_phase::get();
    implementations[7]=uvm_pre_main_phase::get();
    implementations[8]=uvm_main_phase::get();
    implementations[9]=uvm_post_main_phase::get();
    implementations[10]=uvm_pre_shutdown_phase::get();
    implementations[11]=uvm_shutdown_phase::get();
    implementations[12]=uvm_post_shutdown_phase::get();
    foreach (saved[j]) begin
      saved[j]=selected.calls[j];saved_done[j]=selected.completed[j];
    end
    entered_at=$time;
    implementations[0].exec_task(selected,context_node);
    begin
      bit selected_only,completion;
      selected_only=1;completion=$time>entered_at;
      foreach (saved[j]) begin
        selected_only &= selected.calls[j]==saved[j]+(j==0) && peer.calls[j]==0;
        completion &= selected.completed[j]==saved_done[j]+(j==0) && peer.completed[j]==0;
      end
      $display("UT: task_delegate run selected_only %0d context %0d completion %0d",
        selected_only,selected.context_ok,completion);
    end
    foreach (saved[j]) begin
      saved[j]=selected.calls[j];saved_done[j]=selected.completed[j];
    end
    entered_at=$time;
    implementations[1].exec_task(selected,context_node);
    begin
      bit selected_only,completion;
      selected_only=1;completion=$time>entered_at;
      foreach (saved[j]) begin
        selected_only &= selected.calls[j]==saved[j]+(j==1) && peer.calls[j]==0;
        completion &= selected.completed[j]==saved_done[j]+(j==1) && peer.completed[j]==0;
      end
      $display("UT: task_delegate pre_reset selected_only %0d context %0d completion %0d",
        selected_only,selected.context_ok,completion);
    end
    foreach (saved[j]) begin
      saved[j]=selected.calls[j];saved_done[j]=selected.completed[j];
    end
    entered_at=$time;
    implementations[2].exec_task(selected,context_node);
    begin
      bit selected_only,completion;
      selected_only=1;completion=$time>entered_at;
      foreach (saved[j]) begin
        selected_only &= selected.calls[j]==saved[j]+(j==2) && peer.calls[j]==0;
        completion &= selected.completed[j]==saved_done[j]+(j==2) && peer.completed[j]==0;
      end
      $display("UT: task_delegate reset selected_only %0d context %0d completion %0d",
        selected_only,selected.context_ok,completion);
    end
    foreach (saved[j]) begin
      saved[j]=selected.calls[j];saved_done[j]=selected.completed[j];
    end
    entered_at=$time;
    implementations[3].exec_task(selected,context_node);
    begin
      bit selected_only,completion;
      selected_only=1;completion=$time>entered_at;
      foreach (saved[j]) begin
        selected_only &= selected.calls[j]==saved[j]+(j==3) && peer.calls[j]==0;
        completion &= selected.completed[j]==saved_done[j]+(j==3) && peer.completed[j]==0;
      end
      $display("UT: task_delegate post_reset selected_only %0d context %0d completion %0d",
        selected_only,selected.context_ok,completion);
    end
    foreach (saved[j]) begin
      saved[j]=selected.calls[j];saved_done[j]=selected.completed[j];
    end
    entered_at=$time;
    implementations[4].exec_task(selected,context_node);
    begin
      bit selected_only,completion;
      selected_only=1;completion=$time>entered_at;
      foreach (saved[j]) begin
        selected_only &= selected.calls[j]==saved[j]+(j==4) && peer.calls[j]==0;
        completion &= selected.completed[j]==saved_done[j]+(j==4) && peer.completed[j]==0;
      end
      $display("UT: task_delegate pre_configure selected_only %0d context %0d completion %0d",
        selected_only,selected.context_ok,completion);
    end
    foreach (saved[j]) begin
      saved[j]=selected.calls[j];saved_done[j]=selected.completed[j];
    end
    entered_at=$time;
    implementations[5].exec_task(selected,context_node);
    begin
      bit selected_only,completion;
      selected_only=1;completion=$time>entered_at;
      foreach (saved[j]) begin
        selected_only &= selected.calls[j]==saved[j]+(j==5) && peer.calls[j]==0;
        completion &= selected.completed[j]==saved_done[j]+(j==5) && peer.completed[j]==0;
      end
      $display("UT: task_delegate configure selected_only %0d context %0d completion %0d",
        selected_only,selected.context_ok,completion);
    end
    foreach (saved[j]) begin
      saved[j]=selected.calls[j];saved_done[j]=selected.completed[j];
    end
    entered_at=$time;
    implementations[6].exec_task(selected,context_node);
    begin
      bit selected_only,completion;
      selected_only=1;completion=$time>entered_at;
      foreach (saved[j]) begin
        selected_only &= selected.calls[j]==saved[j]+(j==6) && peer.calls[j]==0;
        completion &= selected.completed[j]==saved_done[j]+(j==6) && peer.completed[j]==0;
      end
      $display("UT: task_delegate post_configure selected_only %0d context %0d completion %0d",
        selected_only,selected.context_ok,completion);
    end
    foreach (saved[j]) begin
      saved[j]=selected.calls[j];saved_done[j]=selected.completed[j];
    end
    entered_at=$time;
    implementations[7].exec_task(selected,context_node);
    begin
      bit selected_only,completion;
      selected_only=1;completion=$time>entered_at;
      foreach (saved[j]) begin
        selected_only &= selected.calls[j]==saved[j]+(j==7) && peer.calls[j]==0;
        completion &= selected.completed[j]==saved_done[j]+(j==7) && peer.completed[j]==0;
      end
      $display("UT: task_delegate pre_main selected_only %0d context %0d completion %0d",
        selected_only,selected.context_ok,completion);
    end
    foreach (saved[j]) begin
      saved[j]=selected.calls[j];saved_done[j]=selected.completed[j];
    end
    entered_at=$time;
    implementations[8].exec_task(selected,context_node);
    begin
      bit selected_only,completion;
      selected_only=1;completion=$time>entered_at;
      foreach (saved[j]) begin
        selected_only &= selected.calls[j]==saved[j]+(j==8) && peer.calls[j]==0;
        completion &= selected.completed[j]==saved_done[j]+(j==8) && peer.completed[j]==0;
      end
      $display("UT: task_delegate main selected_only %0d context %0d completion %0d",
        selected_only,selected.context_ok,completion);
    end
    foreach (saved[j]) begin
      saved[j]=selected.calls[j];saved_done[j]=selected.completed[j];
    end
    entered_at=$time;
    implementations[9].exec_task(selected,context_node);
    begin
      bit selected_only,completion;
      selected_only=1;completion=$time>entered_at;
      foreach (saved[j]) begin
        selected_only &= selected.calls[j]==saved[j]+(j==9) && peer.calls[j]==0;
        completion &= selected.completed[j]==saved_done[j]+(j==9) && peer.completed[j]==0;
      end
      $display("UT: task_delegate post_main selected_only %0d context %0d completion %0d",
        selected_only,selected.context_ok,completion);
    end
    foreach (saved[j]) begin
      saved[j]=selected.calls[j];saved_done[j]=selected.completed[j];
    end
    entered_at=$time;
    implementations[10].exec_task(selected,context_node);
    begin
      bit selected_only,completion;
      selected_only=1;completion=$time>entered_at;
      foreach (saved[j]) begin
        selected_only &= selected.calls[j]==saved[j]+(j==10) && peer.calls[j]==0;
        completion &= selected.completed[j]==saved_done[j]+(j==10) && peer.completed[j]==0;
      end
      $display("UT: task_delegate pre_shutdown selected_only %0d context %0d completion %0d",
        selected_only,selected.context_ok,completion);
    end
    foreach (saved[j]) begin
      saved[j]=selected.calls[j];saved_done[j]=selected.completed[j];
    end
    entered_at=$time;
    implementations[11].exec_task(selected,context_node);
    begin
      bit selected_only,completion;
      selected_only=1;completion=$time>entered_at;
      foreach (saved[j]) begin
        selected_only &= selected.calls[j]==saved[j]+(j==11) && peer.calls[j]==0;
        completion &= selected.completed[j]==saved_done[j]+(j==11) && peer.completed[j]==0;
      end
      $display("UT: task_delegate shutdown selected_only %0d context %0d completion %0d",
        selected_only,selected.context_ok,completion);
    end
    foreach (saved[j]) begin
      saved[j]=selected.calls[j];saved_done[j]=selected.completed[j];
    end
    entered_at=$time;
    implementations[12].exec_task(selected,context_node);
    begin
      bit selected_only,completion;
      selected_only=1;completion=$time>entered_at;
      foreach (saved[j]) begin
        selected_only &= selected.calls[j]==saved[j]+(j==12) && peer.calls[j]==0;
        completion &= selected.completed[j]==saved_done[j]+(j==12) && peer.completed[j]==0;
      end
      $display("UT: task_delegate post_shutdown selected_only %0d context %0d completion %0d",
        selected_only,selected.context_ok,completion);
    end
    $finish;
  end
  initial begin #100;$fatal(1,"task delegate watchdog");end
endmodule
