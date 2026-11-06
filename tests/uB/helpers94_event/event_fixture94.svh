class packet94 extends uvm_object;
  event active,muted;
  `uvm_object_utils_begin(packet94)
    `uvm_field_event(active,UVM_COPY)
    `uvm_field_event(muted,UVM_COPY|UVM_NOCOPY)
  `uvm_object_utils_end
  function new(string name="packet94");super.new(name);endfunction
endclass
initial begin
  packet94 source,target,original,peer;
  int copied_wakes,old_wakes,retained_wakes,source_muted_wakes;
  source=new("source94");target=new("target94");peer=new("peer94");original=source;
  copied_wakes=0;old_wakes=0;retained_wakes=0;source_muted_wakes=0;
  // Arm these on the original queues before the macro performs any copying.
  fork
    begin @(target.active);old_wakes++;end
    begin @(target.muted);retained_wakes++;end
  join_none
  #1;
  target.copy(source);
  if(VARIANT!=0) begin target.copy(peer);source=peer;end
  $display("UT: event94 %0d copy_alias %0d negative_flag %0d",VARIANT,
    target.active==source.active,target.muted!=source.muted);
  fork
    begin @(target.active);copied_wakes++;end
    begin @(source.muted);source_muted_wakes++;end
  join_none
  #1;
  if(VARIANT!=0) begin ->original.active;#1;end
  $display("UT: event94 %0d selected_waiter_before_trigger %0d",VARIANT,copied_wakes==0 && old_wakes==0);
  ->source.active;#1;
  $display("UT: event94 %0d copied_notification %0d old_quiet %0d muted_quiet %0d",VARIANT,
    copied_wakes==1,old_wakes==0,retained_wakes==0);
  ->target.muted;#1;
  $display("UT: event94 %0d retained_notification %0d source_independent %0d copied_once %0d",VARIANT,
    retained_wakes==1,source_muted_wakes==0,copied_wakes==1);
  ->source.muted;#1;
  $display("UT: event94 %0d source_notification %0d retained_once %0d",VARIANT,
    source_muted_wakes==1,retained_wakes==1);
  $finish;
end
initial begin #20;$fatal(1,"event94 watchdog");end
