bit [15:0] dut90[2];
bit [15:0] unrelated90;
class watching90 extends uvm_reg;
  int selected,calls=0;
  function new(string name,int index);
    super.new(name,16,UVM_NO_COVERAGE);
    selected=index;
  endfunction
  virtual task backdoor_watch();
    automatic bit [15:0] before_value=dut90[selected];
    calls++;
    wait(dut90[selected]!=before_value);
  endtask
endclass
watching90 watchers90[2];
uvm_reg bases90[2];
bit returned90[2];
time returned_at90[2];
initial begin
  int first_index,second_index;
  dut90[0]='h3ca5;
  dut90[1]='ha53c;
  unrelated90=0;
  watchers90[0]=new("watch_first90",0);
  watchers90[1]=new("watch_second90",1);
  bases90[0]=watchers90[0];
  bases90[1]=watchers90[1];
  first_index=MODE;
  second_index=1-MODE;
  fork
    begin
      bases90[0].backdoor_watch();
      returned90[0]=1;
      returned_at90[0]=$time;
    end
    begin
      bases90[1].backdoor_watch();
      returned90[1]=1;
      returned_at90[1]=$time;
    end
  join_none
  #1;
  $display("UT: reg_watch90 %s entered %0d blocked %0d",CASE_NAME,
    watchers90[0].calls==1 && watchers90[1].calls==1,!returned90[0] && !returned90[1]);
  unrelated90='hffff;
  #1;
  $display("UT: reg_watch90 unrelated_ignored %0d",!returned90[0] && !returned90[1]);
  #1;
  dut90[first_index]^=16'h0080;
  #1;
  $display("UT: reg_watch90 first %0d other_blocked %0d timestamp %0d",
    returned90[first_index],!returned90[second_index],returned_at90[first_index]==3);
  #1;
  dut90[second_index]^=16'h8000;
  #1;
  $display("UT: reg_watch90 second %0d timestamp %0d calls %0d",returned90[second_index],
    returned_at90[second_index]==5,watchers90[0].calls==1 && watchers90[1].calls==1);
  $finish;
end
