class writable90 extends uvm_reg;
  bit [15:0] storage;
  int calls=0;
  uvm_reg_item observed;
  function new(string name);
    super.new(name,16,UVM_NO_COVERAGE);
  endfunction
  virtual task backdoor_write(uvm_reg_item rw);
    calls++;
    observed=rw;
    storage=rw.get_value(0);
    rw.set_status(UVM_IS_OK);
  endtask
endclass
initial begin
  automatic writable90 first=new("first90");
  automatic writable90 second=new("second90");
  automatic uvm_reg_item item=new("item90");
  uvm_reg base;
  bit [15:0] value,first_expected,second_expected;
  int first_calls,second_calls;
  first.storage='h1234;
  second.storage='hfedc;
  first_expected='h1234;
  second_expected='hfedc;
  first_calls=0;
  second_calls=0;
  for (int step=0;step<3;step++) begin
    base=MODE==1 && step==1 ? second : first;
    value=16'h2491+step*16'h1703;
    item.set_element(base);
    item.set_element_kind(UVM_REG);
    item.set_kind(UVM_WRITE);
    item.set_value(value);
    item.set_status(UVM_NOT_OK);
    base.backdoor_write(item);
    if (base==first) begin
      first_expected=value;
      first_calls++;
    end
    else begin
      second_expected=value;
      second_calls++;
    end
    $display("UT: reg_write90 %s step %0d dispatched %0d descriptor %0d state %0d status %0d",
      CASE_NAME,step,first.calls==first_calls && second.calls==second_calls,
      (base==first ? first.observed==item : second.observed==item) && item.get_element()==base,
      first.storage==first_expected && second.storage==second_expected,item.get_status()==UVM_IS_OK);
  end
  $finish;
end
