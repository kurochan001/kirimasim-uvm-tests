// Standard view and explicit library-member control stay separate.
function automatic void slices79(uvm_hdl_path_concat path,
                                  output uvm_hdl_path_slice values[]);
  if (path==null) begin values=new[0]; return; end
`ifdef KIRIMASIM_HDL_VIEW_CONTROL79
  // Nonstandard public member; this does not pass the standard get_slices API.
  values=path.slices;
`else
  path.get_slices(values);
`endif
endfunction
function automatic bit one79(uvm_hdl_path_concat path,string name,int offset,int size);
  uvm_hdl_path_slice values[];
  slices79(path,values);
  if (values.size()!=1) return 0;
  return values[0].path==name && values[0].offset==offset && values[0].size==size;
endfunction
function automatic bit pair79(uvm_hdl_path_concat path,string high_name,string low_name);
  uvm_hdl_path_slice values[];
  slices79(path,values);
  if (values.size()!=2) return 0;
  return values[0].path==high_name && values[0].offset==8 && values[0].size==8 &&
         values[1].path==low_name && values[1].offset==0 && values[1].size==8;
endfunction
function automatic bit has_pair79(ref uvm_hdl_path_concat paths[$],
                                 input string high_name,input string low_name);
  foreach (paths[i]) if (pair79(paths[i],high_name,low_name)) return 1;
  return 0;
endfunction
function automatic bit cartesian79(ref uvm_hdl_path_concat paths[$],input string separator);
  bit valid;
  string prefix;
  valid=paths.size()==8;
  for (int root_index=0;root_index<2;root_index++)
    for (int bank_index=0;bank_index<2;bank_index++) begin
      prefix={$sformatf("dut%0d",root_index),separator,
              $sformatf("bank%0d",bank_index),separator};
      valid &= has_pair79(paths,{prefix,"a_hi"},{prefix,"a_lo"}) &&
               has_pair79(paths,{prefix,"b_hi"},{prefix,"b_lo"});
    end
  return valid;
endfunction
