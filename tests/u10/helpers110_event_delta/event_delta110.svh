// Original scheduler witnesses; no #0 is inserted by this fixture.
typedef uvm_event#(int) event110;
// This always process queues an NBA while the caller resumes in Active.
bit nba_request110=0, nba_payload110=0, nba_marker110=0, nba_queued110=0;
always @(nba_request110) begin
  nba_marker110 <= nba_payload110;
  nba_queued110=1;
end
function automatic bit desired110(input event110 subject);
  return ON110 ? subject.is_on() : !subject.is_on();
endfunction
function automatic void set_state110(input event110 subject,input bit desired);
  if (ON110) begin
    if (desired) subject.trigger(11); else subject.reset();
  end else begin
    if (desired) subject.reset(); else subject.trigger(11);
  end
endfunction
task automatic selected_wait110(input event110 subject);
  if (ON110) begin
    case (ARG110)
      -1: subject.wait_on();
       0: subject.wait_on(0);
       1: subject.wait_on(1);
    endcase
  end else begin
    case (ARG110)
      -1: subject.wait_off();
       0: subject.wait_off(0);
       1: subject.wait_off(1);
    endcase
  end
endtask
task automatic default_wait110(input event110 subject);
  if (ON110) subject.wait_on(); else subject.wait_off();
endtask
task automatic no_wait_control110();
  // A task call with no blocking operation is a separate language control.
endtask
task automatic exercise110();
  automatic event110 subject=new("subject");
  automatic event110 peer=new("peer");
  automatic bit peer_returned=0;
  automatic bit language_child=0;
  bit language_snapshot;
  automatic int round=0;
  bit watcher_entered,watcher_returned,deferred_child;
  bit child_at_return,watcher_at_return,state_at_return,nba_at_return;
  bit call_returned,transition_done,released,at_release;
  time before_wait,after_wait,release_time;
  realtime before_real,after_real,release_real;
  peer.trigger(71);
  fork begin peer.wait_off(); peer_returned=1; end join_none
  #1;
  fork begin language_child=1; end join_none
  no_wait_control110(); language_snapshot=language_child;
  #1;
  $display("UT: language deferred %0d drained %0d peer_waiting %0d",
           !language_snapshot,language_child,!peer_returned && peer.is_on());
  for (round=1;round<=2;round++) begin
    set_state110(subject,0);
    watcher_entered=0; watcher_returned=0;
    fork begin watcher_entered=1; default_wait110(subject); watcher_returned=1; end join_none
    #1;
    $display("UT: round %0d armed entered %0d pending %0d",round,
             watcher_entered,!watcher_returned);
    set_state110(subject,1);
    nba_marker110=0; nba_queued110=0; nba_payload110=1;
    nba_request110=~nba_request110;
    wait(nba_queued110);
    $display("UT: round %0d nba_queued pending %0d",round,!nba_marker110);
    deferred_child=0;
    fork begin deferred_child=1; end join_none
    before_wait=$time; before_real=$realtime;
    selected_wait110(subject);
    after_wait=$time; after_real=$realtime;
    child_at_return=deferred_child; watcher_at_return=watcher_returned;
    state_at_return=desired110(subject); nba_at_return=nba_marker110;
    #1;
    $display("UT: round %0d already child %0d same_time %0d desired %0d nba_pending %0d drained %0d",
             round,child_at_return,before_wait==after_wait && before_real==after_real,
             state_at_return,!nba_at_return,
             deferred_child && watcher_returned && nba_marker110);
    $display("DIAG110: round %0d already_ready_waiter %0d",round,watcher_at_return);

    // A fresh unsatisfied wait checks the actual state condition. Relative
    // active-region return order after its release is diagnostic only.
    set_state110(subject,0);
    watcher_entered=0; watcher_returned=0;
    fork begin watcher_entered=1; default_wait110(subject); watcher_returned=1; end join_none
    #1;
    call_returned=0; transition_done=0; released=0;
    fork begin
      #2;
      $display("UT: round %0d blocked %0d peer_waiting %0d",round,
               !call_returned && watcher_entered && !watcher_returned,
               !peer_returned && peer.is_on());
      release_time=$time; release_real=$realtime; released=1;
      set_state110(subject,1); transition_done=1;
    end join_none
    selected_wait110(subject);
    after_wait=$time; after_real=$realtime;
    state_at_return=desired110(subject);
    at_release=released && after_wait==release_time && after_real==release_real;
    watcher_at_return=watcher_returned; call_returned=1;
    wait(transition_done); #1;
    $display("UT: round %0d released at_transition %0d desired %0d drained %0d",
             round,at_release,state_at_return,watcher_returned);
    $display("DIAG110: round %0d pending_ready_waiter %0d",round,watcher_at_return);
  end
  $display("UT: peer retained %0d",!peer_returned && peer.is_on());
  peer.reset(); #1;
  $display("UT: peer released %0d off %0d",peer_returned,!peer.is_on());
endtask
