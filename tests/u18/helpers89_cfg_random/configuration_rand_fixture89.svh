initial begin
  automatic uvm_mem_mam_cfg cfg=new();
  automatic uvm_mem_mam_cfg peer=new();
  uvm_mem_mam::alloc_mode_e wanted_mode;
  uvm_mem_mam::locality_e wanted_locality;
  bit opposite,accepted,selected,peer_ok;
  peer.n_bytes=2;
  peer.start_offset=0;
  peer.end_offset=7;
  peer.mode=uvm_mem_mam::THRIFTY;
  peer.locality=uvm_mem_mam::NEARBY;
  for (int transition=0;transition<2;transition++) begin
    wanted_mode=transition==0 ? uvm_mem_mam::THRIFTY : uvm_mem_mam::GREEDY;
    wanted_locality=transition==0 ? uvm_mem_mam::NEARBY : uvm_mem_mam::BROAD;
    if (MODE==0) begin
      cfg.mode=transition==0 ? uvm_mem_mam::GREEDY : uvm_mem_mam::THRIFTY;
      opposite=cfg.mode!=wanted_mode;
      accepted=cfg.randomize() with {
        mode==wanted_mode;
        locality==uvm_mem_mam::BROAD;
        n_bytes==1;
        start_offset==64;
        end_offset==95;
      };
      selected=cfg.mode==wanted_mode && cfg.locality==uvm_mem_mam::BROAD;
    end else begin
      cfg.locality=transition==0 ? uvm_mem_mam::BROAD : uvm_mem_mam::NEARBY;
      opposite=cfg.locality!=wanted_locality;
      accepted=cfg.randomize() with {
        locality==wanted_locality;
        mode==uvm_mem_mam::GREEDY;
        n_bytes==1;
        start_offset==64;
        end_offset==95;
      };
      selected=cfg.locality==wanted_locality && cfg.mode==uvm_mem_mam::GREEDY;
    end
    selected &= cfg.n_bytes==1 && cfg.start_offset==64 && cfg.end_offset==95;
    peer_ok=peer.n_bytes==2 && peer.start_offset==0 && peer.end_offset==7 &&
      peer.mode==uvm_mem_mam::THRIFTY && peer.locality==uvm_mem_mam::NEARBY;
    $display("UT: cfg_rand89 %s transition %0d opposite %0d accepted %0d selected %0d peer %0d",
      CASE_NAME,transition,opposite,accepted,selected,peer_ok);
  end
  $finish;
end
