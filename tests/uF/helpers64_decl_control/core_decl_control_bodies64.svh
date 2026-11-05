// Original declaration-control bodies; they do not model builtin algorithms.
// Each negative fixture omits exactly one otherwise fully implemented method.
int calls[26];
uvm_root root_state;
uvm_factory factory_state;
uvm_report_server server_state;
uvm_tr_database database_state;
uvm_visitor#(uvm_component) visitor_state;
uvm_printer printer_state;
uvm_packer packer_state;
uvm_comparer comparer_state;
uvm_copier copier_state;
uvm_resource_pool pool_state;
int limit_state;
int unsigned precedence_state;
bit seeding_state;
function new(); super.new(); root_state=uvm_root::get(); endfunction
`ifndef AUDIT64_OMIT_GET_ROOT
virtual function uvm_root get_root();
  calls[0]++;
  return root_state;
endfunction
`endif
`ifndef AUDIT64_OMIT_GET_FACTORY
virtual function uvm_factory get_factory();
  calls[1]++;
  return factory_state;
endfunction
`endif
`ifndef AUDIT64_OMIT_SET_FACTORY
virtual function void set_factory(uvm_factory f);
  calls[2]++;
  factory_state=f;
endfunction
`endif
`ifndef AUDIT64_OMIT_GET_REPORT_SERVER
virtual function uvm_report_server get_report_server();
  calls[3]++;
  return server_state;
endfunction
`endif
`ifndef AUDIT64_OMIT_SET_REPORT_SERVER
virtual function void set_report_server(uvm_report_server server);
  calls[4]++;
  server_state=server;
endfunction
`endif
`ifndef AUDIT64_OMIT_GET_DEFAULT_TR_DATABASE
virtual function uvm_tr_database get_default_tr_database();
  calls[5]++;
  return database_state;
endfunction
`endif
`ifndef AUDIT64_OMIT_SET_DEFAULT_TR_DATABASE
virtual function void set_default_tr_database(uvm_tr_database db);
  calls[6]++;
  database_state=db;
endfunction
`endif
`ifndef AUDIT64_OMIT_GET_COMPONENT_VISITOR
virtual function uvm_visitor#(uvm_component) get_component_visitor();
  calls[7]++;
  return visitor_state;
endfunction
`endif
`ifndef AUDIT64_OMIT_SET_COMPONENT_VISITOR
virtual function void set_component_visitor(uvm_visitor#(uvm_component) v);
  calls[8]++;
  visitor_state=v;
endfunction
`endif
`ifndef AUDIT64_OMIT_SET_PHASE_MAX_READY_TO_END
virtual function void set_phase_max_ready_to_end(int max);
  calls[9]++;
  limit_state=max;
endfunction
`endif
`ifndef AUDIT64_OMIT_GET_PHASE_MAX_READY_TO_END
virtual function int get_phase_max_ready_to_end();
  calls[10]++;
  return limit_state;
endfunction
`endif
`ifndef AUDIT64_OMIT_SET_DEFAULT_PRINTER
virtual function void set_default_printer(uvm_printer printer);
  calls[11]++;
  printer_state=printer;
endfunction
`endif
`ifndef AUDIT64_OMIT_GET_DEFAULT_PRINTER
virtual function uvm_printer get_default_printer();
  calls[12]++;
  return printer_state;
endfunction
`endif
`ifndef AUDIT64_OMIT_SET_DEFAULT_PACKER
virtual function void set_default_packer(uvm_packer packer);
  calls[13]++;
  packer_state=packer;
endfunction
`endif
`ifndef AUDIT64_OMIT_GET_DEFAULT_PACKER
virtual function uvm_packer get_default_packer();
  calls[14]++;
  return packer_state;
endfunction
`endif
`ifndef AUDIT64_OMIT_SET_DEFAULT_COMPARER
virtual function void set_default_comparer(uvm_comparer comparer);
  calls[15]++;
  comparer_state=comparer;
endfunction
`endif
`ifndef AUDIT64_OMIT_GET_DEFAULT_COMPARER
virtual function uvm_comparer get_default_comparer();
  calls[16]++;
  return comparer_state;
endfunction
`endif
`ifndef AUDIT64_OMIT_SET_DEFAULT_COPIER
virtual function void set_default_copier(uvm_copier copier);
  calls[17]++;
  copier_state=copier;
endfunction
`endif
`ifndef AUDIT64_OMIT_GET_DEFAULT_COPIER
virtual function uvm_copier get_default_copier();
  calls[18]++;
  return copier_state;
endfunction
`endif
`ifndef AUDIT64_OMIT_GET_GLOBAL_SEED
virtual function int unsigned get_global_seed();
  calls[19]++;
  return 233;
endfunction
`endif
`ifndef AUDIT64_OMIT_SET_RESOURCE_POOL
virtual function void set_resource_pool(uvm_resource_pool pool);
  calls[20]++;
  pool_state=pool;
endfunction
`endif
`ifndef AUDIT64_OMIT_GET_RESOURCE_POOL
virtual function uvm_resource_pool get_resource_pool();
  calls[21]++;
  return pool_state;
endfunction
`endif
`ifndef AUDIT64_OMIT_SET_RESOURCE_POOL_DEFAULT_PRECEDENCE
virtual function void set_resource_pool_default_precedence(int unsigned precedence);
  calls[22]++;
  precedence_state=precedence;
endfunction
`endif
`ifndef AUDIT64_OMIT_GET_RESOURCE_POOL_DEFAULT_PRECEDENCE
virtual function int unsigned get_resource_pool_default_precedence();
  calls[23]++;
  return precedence_state;
endfunction
`endif
`ifndef AUDIT64_OMIT_GET_UVM_SEEDING
virtual function bit get_uvm_seeding();
  calls[24]++;
  return seeding_state;
endfunction
`endif
`ifndef AUDIT64_OMIT_SET_UVM_SEEDING
virtual function void set_uvm_seeding(bit enable);
  calls[25]++;
  seeding_state=enable;
endfunction
`endif
// Pinned-release declaration setup only; no IEEE algorithm depends on it.
// This additional hook is not one of the standard's twenty-six pure methods.
virtual function uvm_phase_hopper get_phase_hopper(); return null; endfunction
