// Original callback bodies/observers; actual UVM macros supply registration/dispatch.
`include "uvm_macros.svh"
class callback82 extends uvm_callback;
  int calls, last_token, weight;
  bit affine;
  string tag;
  uvm_object last_owner;
  function new(string name="C",int value=1,bit transform=0);
    super.new(name);
    tag=name;
    weight=value;
    affine=transform;
    calls=0;
    last_token=0;
    last_owner=null;
    void'(callback_mode(1));
  endfunction
  virtual function void hook82(input uvm_object who,input int token,
                               ref int acc,ref string trace);
    calls++;
    last_owner=who;
    last_token=token;
    if (affine) acc=2*acc+weight;
    else acc+=weight;
    trace={trace,tag};
  endfunction
endclass
class parameter_callback82 #(int GAIN=3) extends callback82;
  function new(string name="P");
    super.new(name,GAIN,0);
  endfunction
endclass
typedef parameter_callback82#(3) gain3_callback82;
typedef parameter_callback82#(7) gain7_callback82;
class derived_callback82 extends callback82;
  int overrides;
  function new();
    super.new("D",5,0);
    overrides=0;
  endfunction
  virtual function void hook82(input uvm_object who,input int token,
                               ref int acc,ref string trace);
    overrides++;
    super.hook82(who,token,acc,trace);
  endfunction
endclass
class unrelated_callback82 extends uvm_callback;
  int calls;
  uvm_object last_owner;
  function new();
    super.new("X");
    calls=0;
    void'(callback_mode(1));
  endfunction
  virtual function void hook82(input uvm_object who,input int token,
                               ref int acc,ref string trace);
    calls++;
    last_owner=who;
    acc+=99;
    trace={trace,"X"};
  endfunction
endclass
class owner82 extends uvm_object;
  `uvm_register_cb(owner82,callback82)
  `uvm_register_cb(owner82,unrelated_callback82)
  int entries;
  function new(string name="owner82");
    super.new(name);
    entries=0;
  endfunction
  function void fire82(input int token,ref int acc,ref string trace);
    entries++; `uvm_do_callbacks(owner82,callback82,hook82(this,token,acc,trace))
  endfunction
  function void other82(input int token,ref int acc,ref string trace);
    `uvm_do_callbacks(owner82,unrelated_callback82,hook82(this,token,acc,trace))
  endfunction
endclass
class derived_owner82 extends owner82;
  `uvm_register_cb(derived_owner82,callback82)
  `uvm_set_super_type(derived_owner82,owner82)
  function new();
    super.new("derived82");
  endfunction
endclass
class alias_owner82 extends uvm_object;
  `uvm_register_cb(alias_owner82,gain3_callback82)
  `uvm_register_cb(alias_owner82,gain7_callback82)
  function new();
    super.new("alias82");
  endfunction
  function void first82(input int token,ref int acc,ref string trace);
    `uvm_do_callbacks(alias_owner82,gain3_callback82,hook82(this,token,acc,trace))
  endfunction
  function void second82(input int token,ref int acc,ref string trace);
    `uvm_do_callbacks(alias_owner82,gain7_callback82,hook82(this,token,acc,trace))
  endfunction
endclass
class local_alias_owner82 extends uvm_object;
  typedef parameter_callback82#(13) cb_t;
  `uvm_register_cb(local_alias_owner82,cb_t)
  function new(string name);
    super.new(name);
  endfunction
  function void fire82(input int token,ref int acc,ref string trace);
    `uvm_do_callbacks(local_alias_owner82,cb_t,hook82(this,token,acc,trace))
  endfunction
endclass
class unregistered_owner82 extends uvm_object;
  function new();
    super.new("unregistered82");
  endfunction
endclass
class warning_observer82 extends uvm_report_catcher;
  bit active;
  int warnings;
  function new();
    super.new("warning82");
    active=0;
    warnings=0;
  endfunction
  virtual function action_e catch();
    if (active && get_severity()==UVM_WARNING) begin
      warnings++;
      return CAUGHT;
    end
    return THROW;
  endfunction
endclass
typedef uvm_callbacks#(owner82,callback82) pool82;
