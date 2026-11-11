// Original small register models shared by symbolic and physical fixtures.
class block79 extends uvm_reg_block;
  function new(string name="owner79");
    super.new(name,UVM_NO_COVERAGE);
  endfunction
endclass
class register79 extends uvm_reg;
  function new(string name="r79",int unsigned width=16);
    super.new(name,width,UVM_NO_COVERAGE);
  endfunction
endclass
function automatic register79 physical_reg79(block79 owner,string name,int width,
                                           bit whole);
  automatic register79 rg=new(name,width);
  automatic uvm_reg_field field_value=new("field79");
  rg.configure(owner);
  field_value.configure(rg,width,0,"RW",0,0,1,0,0);
  if (whole) rg.add_hdl_path_slice("whole_value",-1,-1);
  else begin
    rg.add_hdl_path_slice("split_high",width/2,width/2);
    rg.add_hdl_path_slice("split_low",0,width/2);
  end
  return rg;
endfunction
