// Original coverage-selection and observer fixtures; no covergroups or HDL.
class coverage_block80 extends uvm_reg_block;
  function new(string name);
    super.new(name,UVM_NO_COVERAGE);
  endfunction
  function uvm_reg_cvr_t selected(uvm_reg_cvr_t models);
    return build_coverage(models);
  endfunction
endclass
class coverage_reg80 extends uvm_reg;
  function new(string name, uvm_reg_cvr_t models=UVM_NO_COVERAGE);
    super.new(name,16,models);
  endfunction
  function uvm_reg_cvr_t selected(uvm_reg_cvr_t models);
    return build_coverage(models);
  endfunction
  protected function void via_base_add(uvm_reg_cvr_t models);
    add_coverage(models);
  endfunction
endclass
class coverage_mem80 extends uvm_mem;
  function new(string name);
    super.new(name,4,16,"RW",UVM_NO_COVERAGE);
  endfunction
  function uvm_reg_cvr_t selected(uvm_reg_cvr_t models);
    return build_coverage(models);
  endfunction
endclass
class coverage_added80 extends coverage_reg80;
  function new(string name, uvm_reg_cvr_t original_models,
               uvm_reg_cvr_t first, uvm_reg_cvr_t second);
    super.new(name,original_models);
    add_coverage(first);
    add_coverage(second);
  endfunction
endclass
class coverage_hook80 extends coverage_reg80;
  int calls;
  uvm_reg_cvr_t last_models;
  function new(string name);
    super.new(name,UVM_CVR_REG_BITS);
    calls=0;
    // The inherited caller executes while this derived constructor is active.
    via_base_add(UVM_CVR_ADDR_MAP);
  endfunction
  virtual protected function void add_coverage(uvm_reg_cvr_t models);
    calls++;
    last_models=models;
    super.add_coverage(models);
  endfunction
endclass
class coverage_sample80 extends coverage_reg80;
  uvm_reg_field value_field;
  int calls;
  uvm_reg_data_t last_value;
  function new(string name);
    super.new(name,UVM_NO_COVERAGE);
  endfunction
  function void build_field();
    value_field=new("value80");
    value_field.configure(this,16,0,"RW",0,0,1,0,1);
  endfunction
  virtual function void sample_values();
    calls++;
    last_value=value_field.get();
  endfunction
endclass
class coverage_token80 extends uvm_object;
  function new();
    super.new("accessor80");
  endfunction
endclass
