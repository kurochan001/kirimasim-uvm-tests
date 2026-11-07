`include "uvm_macros.svh"
// Original lexical scopes, with identical suffix arguments in each package.
package decl_a96;
  import uvm_pkg::*;
  `uvm_blocking_put_imp_decl(_shared96)
  `uvm_blocking_put_imp_decl(plain96)
  `uvm_nonblocking_get_imp_decl(_shared96)
  `uvm_nonblocking_get_imp_decl(plain96)
endpackage
package decl_b96;
  import uvm_pkg::*;
  `uvm_blocking_put_imp_decl(_shared96)
  `uvm_blocking_put_imp_decl(plain96)
  `uvm_nonblocking_get_imp_decl(_shared96)
  `uvm_nonblocking_get_imp_decl(plain96)
endpackage
