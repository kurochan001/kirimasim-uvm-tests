/*
:name: test_pinned_core_extra_hook_control_dispatches_all_twenty_six_standard_methods
:description: An explicit pinned-hook control dispatches the twenty-six standard methods
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.4.1.2 F.4.1.1 F.4 F.4.1.3 F.4.1.4.1 F.4.1.4.2 F.4.1.4.3 F.4.1.4.4 F.4.1.4.5 F.4.1.4.6 F.4.1.4.7 F.4.1.4.8 F.4.1.4.9 F.4.1.4.10 F.4.1.4.11 F.4.1.4.12 F.4.1.4.13 F.4.1.4.14 F.4.1.4.15 F.4.1.4.16 F.4.1.4.17 F.4.1.4.18 F.4.1.4.19 F.4.1.4.20 F.4.1.4.21 F.4.1.4.22 F.4.1.4.23 F.4.1.4.24 F.4.1.4.25 F.4.1.4.26 1800-2023 6.21 8.20 8.21 13.5.2 18.13.3 18.13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers64_decl_control/core_decl_control_bodies64.svh
:expected_exit: 0
:expected_stdout: @test_pinned_core_extra_hook_control_dispatches_all_twenty_six_standard_methods.expected
*/
// What it checks:
// It is a control: it supports the setup or conditions of these duties, which
// other tests check directly:
// 1. A concrete core-service extension must implement the pure get_root
//    method.
// 2. The printed get_root declaration can be implemented and dispatched
//    through the core-service base view.
// 3. A concrete core-service extension must implement the pure get_factory
//    method.
// 4. The printed get_factory declaration can be implemented and dispatched
//    through the core-service base view.
// 5. A concrete core-service extension must implement the pure set_factory
//    method.
// 6. The printed set_factory declaration can be implemented and dispatched
//    through the core-service base view.
// 7. A concrete core-service extension must implement the pure
//    get_report_server method.
// 8. The printed get_report_server declaration can be implemented and
//    dispatched through the core-service base view.
// 9. A concrete core-service extension must implement the pure
//    set_report_server method.
// 10. The printed set_report_server declaration can be implemented and
//     dispatched through the core-service base view.
// 11. A concrete core-service extension must implement the pure
//     get_default_tr_database method.
// 12. The printed get_default_tr_database declaration can be implemented and
//     dispatched through the core-service base view.
// 13. A concrete core-service extension must implement the pure
//     set_default_tr_database method.
// 14. The printed set_default_tr_database declaration can be implemented and
//     dispatched through the core-service base view.
// 15. A concrete core-service extension must implement the pure
//     get_component_visitor method.
// 16. The printed get_component_visitor declaration can be implemented and
//     dispatched through the core-service base view.
// 17. A concrete core-service extension must implement the pure
//     set_component_visitor method.
// 18. The printed set_component_visitor declaration can be implemented and
//     dispatched through the core-service base view.
// 19. A concrete core-service extension must implement the pure
//     set_phase_max_ready_to_end method.
// 20. The printed set_phase_max_ready_to_end declaration can be implemented
//     and dispatched through the core-service base view.
// 21. A concrete core-service extension must implement the pure
//     get_phase_max_ready_to_end method.
// 22. The printed get_phase_max_ready_to_end declaration can be implemented
//     and dispatched through the core-service base view.
// 23. A concrete core-service extension must implement the pure
//     set_default_printer method.
// 24. The printed set_default_printer declaration can be implemented and
//     dispatched through the core-service base view.
// 25. A concrete core-service extension must implement the pure
//     get_default_printer method.
// 26. The printed get_default_printer declaration can be implemented and
//     dispatched through the core-service base view.
// 27. A concrete core-service extension must implement the pure
//     set_default_packer method.
// 28. The printed set_default_packer declaration can be implemented and
//     dispatched through the core-service base view.
// 29. A concrete core-service extension must implement the pure
//     get_default_packer method.
// 30. The printed get_default_packer declaration can be implemented and
//     dispatched through the core-service base view.
// 31. A concrete core-service extension must implement the pure
//     set_default_comparer method.
// 32. The printed set_default_comparer declaration can be implemented and
//     dispatched through the core-service base view.
// 33. A concrete core-service extension must implement the pure
//     get_default_comparer method.
// 34. The printed get_default_comparer declaration can be implemented and
//     dispatched through the core-service base view.
// 35. A concrete core-service extension must implement the pure
//     set_default_copier method.
// 36. The printed set_default_copier declaration can be implemented and
//     dispatched through the core-service base view.
// 37. A concrete core-service extension must implement the pure
//     get_default_copier method.
// 38. The printed get_default_copier declaration can be implemented and
//     dispatched through the core-service base view.
// 39. A concrete core-service extension must implement the pure
//     get_global_seed method.
// 40. The printed get_global_seed declaration can be implemented and
//     dispatched through the core-service base view.
// 41. A concrete core-service extension must implement the pure
//     set_resource_pool method.
// 42. The printed set_resource_pool declaration can be implemented and
//     dispatched through the core-service base view.
// 43. A concrete core-service extension must implement the pure
//     get_resource_pool method.
// 44. The printed get_resource_pool declaration can be implemented and
//     dispatched through the core-service base view.
// 45. A concrete core-service extension must implement the pure
//     set_resource_pool_default_precedence method.
// 46. The printed set_resource_pool_default_precedence declaration can be
//     implemented and dispatched through the core-service base view.
// 47. A concrete core-service extension must implement the pure
//     get_resource_pool_default_precedence method.
// 48. The printed get_resource_pool_default_precedence declaration can be
//     implemented and dispatched through the core-service base view.
// 49. A concrete core-service extension must implement the pure
//     get_uvm_seeding method.
// 50. The printed get_uvm_seeding declaration can be implemented and
//     dispatched through the core-service base view.
// 51. A concrete core-service extension must implement the pure
//     set_uvm_seeding method.
// 52. The printed set_uvm_seeding declaration can be implemented and
//     dispatched through the core-service base view.
// 53. An original complete core-service subclass can call the no-argument base
//     constructor.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.4.1.4.1 (UVM-CORE-DECL-AUDIT-GET-ROOT-PURE) gives rule 1
//    above. Setup: An original extension implements the other twenty-five
//    printed pure methods and the pinned release extra phase-hopper hook,
//    omitting only this selected printed method. Expected: Compilation rejects
//    the concrete extension and identifies this input and get_root; no runtime
//    binary is executed.
// 2. 1800.2-2020 F.4.1.4.1 (UVM-CORE-DECL-AUDIT-GET-ROOT-DECLARATION) gives
//    rule 2 above. Setup: An original concrete service implements all
//    twenty-six printed methods with exact formal names and the selected
//    uvm_root return type; arguments are (). It is not installed as the global
//    service. Expected: Calling the selected slot through the base view
//    reaches its original implementation once and retains the chosen
//    type/argument/return identity.
// 3. 1800.2-2020 F.4.1.4.2 (UVM-CORE-DECL-AUDIT-GET-FACTORY-PURE) gives rule 3
//    above. Setup: An original extension implements the other twenty-five
//    printed pure methods and the pinned release extra phase-hopper hook,
//    omitting only this selected printed method. Expected: Compilation rejects
//    the concrete extension and identifies this input and get_factory; no
//    runtime binary is executed.
// 4. 1800.2-2020 F.4.1.4.2 (UVM-CORE-DECL-AUDIT-GET-FACTORY-DECLARATION) gives
//    rule 4 above. Setup: An original concrete service implements all
//    twenty-six printed methods with exact formal names and the selected
//    uvm_factory return type; arguments are (). It is not installed as the
//    global service. Expected: Calling the selected slot through the base view
//    reaches its original implementation once and retains the chosen
//    type/argument/return identity.
// 5. 1800.2-2020 F.4.1.4.3 (UVM-CORE-DECL-AUDIT-SET-FACTORY-PURE) gives rule 5
//    above. Setup: An original extension implements the other twenty-five
//    printed pure methods and the pinned release extra phase-hopper hook,
//    omitting only this selected printed method. Expected: Compilation rejects
//    the concrete extension and identifies this input and set_factory; no
//    runtime binary is executed.
// 6. 1800.2-2020 F.4.1.4.3 (UVM-CORE-DECL-AUDIT-SET-FACTORY-DECLARATION) gives
//    rule 6 above. Setup: An original concrete service implements all
//    twenty-six printed methods with exact formal names and the selected void
//    return type; arguments are (uvm_factory f). It is not installed as the
//    global service. Expected: Calling the selected slot through the base view
//    reaches its original implementation once and retains the chosen
//    type/argument/return identity.
// 7. 1800.2-2020 F.4.1.4.4 (UVM-CORE-DECL-AUDIT-GET-REPORT-SERVER-PURE) gives
//    rule 7 above. Setup: An original extension implements the other
//    twenty-five printed pure methods and the pinned release extra
//    phase-hopper hook, omitting only this selected printed method. Expected:
//    Compilation rejects the concrete extension and identifies this input and
//    get_report_server; no runtime binary is executed.
// 8. 1800.2-2020 F.4.1.4.4 (UVM-CORE-DECL-AUDIT-GET-REPORT-SERVER-DECLARATION)
//    gives rule 8 above. Setup: An original concrete service implements all
//    twenty-six printed methods with exact formal names and the selected
//    uvm_report_server return type; arguments are (). It is not installed as
//    the global service. Expected: Calling the selected slot through the base
//    view reaches its original implementation once and retains the chosen
//    type/argument/return identity.
// 9. 1800.2-2020 F.4.1.4.5 (UVM-CORE-DECL-AUDIT-SET-REPORT-SERVER-PURE) gives
//    rule 9 above. Setup: An original extension implements the other
//    twenty-five printed pure methods and the pinned release extra
//    phase-hopper hook, omitting only this selected printed method. Expected:
//    Compilation rejects the concrete extension and identifies this input and
//    set_report_server; no runtime binary is executed.
// 10. 1800.2-2020 F.4.1.4.5
//     (UVM-CORE-DECL-AUDIT-SET-REPORT-SERVER-DECLARATION) gives rule 10 above.
//     Setup: An original concrete service implements all twenty-six printed
//     methods with exact formal names and the selected void return type;
//     arguments are (uvm_report_server server). It is not installed as the
//     global service. Expected: Calling the selected slot through the base
//     view reaches its original implementation once and retains the chosen
//     type/argument/return identity.
// 11. 1800.2-2020 F.4.1.4.6 (UVM-CORE-DECL-AUDIT-GET-DEFAULT-TR-DATABASE-PURE)
//     gives rule 11 above. Setup: An original extension implements the other
//     twenty-five printed pure methods and the pinned release extra
//     phase-hopper hook, omitting only this selected printed method. Expected:
//     Compilation rejects the concrete extension and identifies this input and
//     get_default_tr_database; no runtime binary is executed.
// 12. 1800.2-2020 F.4.1.4.6
//     (UVM-CORE-DECL-AUDIT-GET-DEFAULT-TR-DATABASE-DECLARATION) gives rule 12
//     above. Setup: An original concrete service implements all twenty-six
//     printed methods with exact formal names and the selected uvm_tr_database
//     return type; arguments are (). It is not installed as the global
//     service. Expected: Calling the selected slot through the base view
//     reaches its original implementation once and retains the chosen
//     type/argument/return identity.
// 13. 1800.2-2020 F.4.1.4.7 (UVM-CORE-DECL-AUDIT-SET-DEFAULT-TR-DATABASE-PURE)
//     gives rule 13 above. Setup: An original extension implements the other
//     twenty-five printed pure methods and the pinned release extra
//     phase-hopper hook, omitting only this selected printed method. Expected:
//     Compilation rejects the concrete extension and identifies this input and
//     set_default_tr_database; no runtime binary is executed.
// 14. 1800.2-2020 F.4.1.4.7
//     (UVM-CORE-DECL-AUDIT-SET-DEFAULT-TR-DATABASE-DECLARATION) gives rule 14
//     above. Setup: An original concrete service implements all twenty-six
//     printed methods with exact formal names and the selected void return
//     type; arguments are (uvm_tr_database db). It is not installed as the
//     global service. Expected: Calling the selected slot through the base
//     view reaches its original implementation once and retains the chosen
//     type/argument/return identity.
// 15. 1800.2-2020 F.4.1.4.8 (UVM-CORE-DECL-AUDIT-GET-COMPONENT-VISITOR-PURE)
//     gives rule 15 above. Setup: An original extension implements the other
//     twenty-five printed pure methods and the pinned release extra
//     phase-hopper hook, omitting only this selected printed method. Expected:
//     Compilation rejects the concrete extension and identifies this input and
//     get_component_visitor; no runtime binary is executed.
// 16. 1800.2-2020 F.4.1.4.8
//     (UVM-CORE-DECL-AUDIT-GET-COMPONENT-VISITOR-DECLARATION) gives rule 16
//     above. Setup: An original concrete service implements all twenty-six
//     printed methods with exact formal names and the selected
//     uvm_visitor#(uvm_component) return type; arguments are (). It is not
//     installed as the global service. Expected: Calling the selected slot
//     through the base view reaches its original implementation once and
//     retains the chosen type/argument/return identity.
// 17. 1800.2-2020 F.4.1.4.9 (UVM-CORE-DECL-AUDIT-SET-COMPONENT-VISITOR-PURE)
//     gives rule 17 above. Setup: An original extension implements the other
//     twenty-five printed pure methods and the pinned release extra
//     phase-hopper hook, omitting only this selected printed method. Expected:
//     Compilation rejects the concrete extension and identifies this input and
//     set_component_visitor; no runtime binary is executed.
// 18. 1800.2-2020 F.4.1.4.9
//     (UVM-CORE-DECL-AUDIT-SET-COMPONENT-VISITOR-DECLARATION) gives rule 18
//     above. Setup: An original concrete service implements all twenty-six
//     printed methods with exact formal names and the selected void return
//     type; arguments are (uvm_visitor#(uvm_component) v). It is not installed
//     as the global service. Expected: Calling the selected slot through the
//     base view reaches its original implementation once and retains the
//     chosen type/argument/return identity.
// 19. 1800.2-2020 F.4.1.4.10
//     (UVM-CORE-DECL-AUDIT-SET-PHASE-MAX-READY-TO-END-PURE) gives rule 19
//     above. Setup: An original extension implements the other twenty-five
//     printed pure methods and the pinned release extra phase-hopper hook,
//     omitting only this selected printed method. Expected: Compilation
//     rejects the concrete extension and identifies this input and
//     set_phase_max_ready_to_end; no runtime binary is executed.
// 20. 1800.2-2020 F.4.1.4.10
//     (UVM-CORE-DECL-AUDIT-SET-PHASE-MAX-READY-TO-END-DECLARATION) gives rule
//     20 above. Setup: An original concrete service implements all twenty-six
//     printed methods with exact formal names and the selected void return
//     type; arguments are (int max). It is not installed as the global
//     service. Expected: Calling the selected slot through the base view
//     reaches its original implementation once and retains the chosen
//     type/argument/return identity.
// 21. 1800.2-2020 F.4.1.4.11
//     (UVM-CORE-DECL-AUDIT-GET-PHASE-MAX-READY-TO-END-PURE) gives rule 21
//     above. Setup: An original extension implements the other twenty-five
//     printed pure methods and the pinned release extra phase-hopper hook,
//     omitting only this selected printed method. Expected: Compilation
//     rejects the concrete extension and identifies this input and
//     get_phase_max_ready_to_end; no runtime binary is executed.
// 22. 1800.2-2020 F.4.1.4.11
//     (UVM-CORE-DECL-AUDIT-GET-PHASE-MAX-READY-TO-END-DECLARATION) gives rule
//     22 above. Setup: An original concrete service implements all twenty-six
//     printed methods with exact formal names and the selected int return
//     type; arguments are (). It is not installed as the global service.
//     Expected: Calling the selected slot through the base view reaches its
//     original implementation once and retains the chosen type/argument/return
//     identity.
// 23. 1800.2-2020 F.4.1.4.12 (UVM-CORE-DECL-AUDIT-SET-DEFAULT-PRINTER-PURE)
//     gives rule 23 above. Setup: An original extension implements the other
//     twenty-five printed pure methods and the pinned release extra
//     phase-hopper hook, omitting only this selected printed method. Expected:
//     Compilation rejects the concrete extension and identifies this input and
//     set_default_printer; no runtime binary is executed.
// 24. 1800.2-2020 F.4.1.4.12
//     (UVM-CORE-DECL-AUDIT-SET-DEFAULT-PRINTER-DECLARATION) gives rule 24
//     above. Setup: An original concrete service implements all twenty-six
//     printed methods with exact formal names and the selected void return
//     type; arguments are (uvm_printer printer). It is not installed as the
//     global service. Expected: Calling the selected slot through the base
//     view reaches its original implementation once and retains the chosen
//     type/argument/return identity.
// 25. 1800.2-2020 F.4.1.4.13 (UVM-CORE-DECL-AUDIT-GET-DEFAULT-PRINTER-PURE)
//     gives rule 25 above. Setup: An original extension implements the other
//     twenty-five printed pure methods and the pinned release extra
//     phase-hopper hook, omitting only this selected printed method. Expected:
//     Compilation rejects the concrete extension and identifies this input and
//     get_default_printer; no runtime binary is executed.
// 26. 1800.2-2020 F.4.1.4.13
//     (UVM-CORE-DECL-AUDIT-GET-DEFAULT-PRINTER-DECLARATION) gives rule 26
//     above. Setup: An original concrete service implements all twenty-six
//     printed methods with exact formal names and the selected uvm_printer
//     return type; arguments are (). It is not installed as the global
//     service. Expected: Calling the selected slot through the base view
//     reaches its original implementation once and retains the chosen
//     type/argument/return identity.
// 27. 1800.2-2020 F.4.1.4.14 (UVM-CORE-DECL-AUDIT-SET-DEFAULT-PACKER-PURE)
//     gives rule 27 above. Setup: An original extension implements the other
//     twenty-five printed pure methods and the pinned release extra
//     phase-hopper hook, omitting only this selected printed method. Expected:
//     Compilation rejects the concrete extension and identifies this input and
//     set_default_packer; no runtime binary is executed.
// 28. 1800.2-2020 F.4.1.4.14
//     (UVM-CORE-DECL-AUDIT-SET-DEFAULT-PACKER-DECLARATION) gives rule 28
//     above. Setup: An original concrete service implements all twenty-six
//     printed methods with exact formal names and the selected void return
//     type; arguments are (uvm_packer packer). It is not installed as the
//     global service. Expected: Calling the selected slot through the base
//     view reaches its original implementation once and retains the chosen
//     type/argument/return identity.
// 29. 1800.2-2020 F.4.1.4.15 (UVM-CORE-DECL-AUDIT-GET-DEFAULT-PACKER-PURE)
//     gives rule 29 above. Setup: An original extension implements the other
//     twenty-five printed pure methods and the pinned release extra
//     phase-hopper hook, omitting only this selected printed method. Expected:
//     Compilation rejects the concrete extension and identifies this input and
//     get_default_packer; no runtime binary is executed.
// 30. 1800.2-2020 F.4.1.4.15
//     (UVM-CORE-DECL-AUDIT-GET-DEFAULT-PACKER-DECLARATION) gives rule 30
//     above. Setup: An original concrete service implements all twenty-six
//     printed methods with exact formal names and the selected uvm_packer
//     return type; arguments are (). It is not installed as the global
//     service. Expected: Calling the selected slot through the base view
//     reaches its original implementation once and retains the chosen
//     type/argument/return identity.
// 31. 1800.2-2020 F.4.1.4.16 (UVM-CORE-DECL-AUDIT-SET-DEFAULT-COMPARER-PURE)
//     gives rule 31 above. Setup: An original extension implements the other
//     twenty-five printed pure methods and the pinned release extra
//     phase-hopper hook, omitting only this selected printed method. Expected:
//     Compilation rejects the concrete extension and identifies this input and
//     set_default_comparer; no runtime binary is executed.
// 32. 1800.2-2020 F.4.1.4.16
//     (UVM-CORE-DECL-AUDIT-SET-DEFAULT-COMPARER-DECLARATION) gives rule 32
//     above. Setup: An original concrete service implements all twenty-six
//     printed methods with exact formal names and the selected void return
//     type; arguments are (uvm_comparer comparer). It is not installed as the
//     global service. Expected: Calling the selected slot through the base
//     view reaches its original implementation once and retains the chosen
//     type/argument/return identity.
// 33. 1800.2-2020 F.4.1.4.17 (UVM-CORE-DECL-AUDIT-GET-DEFAULT-COMPARER-PURE)
//     gives rule 33 above. Setup: An original extension implements the other
//     twenty-five printed pure methods and the pinned release extra
//     phase-hopper hook, omitting only this selected printed method. Expected:
//     Compilation rejects the concrete extension and identifies this input and
//     get_default_comparer; no runtime binary is executed.
// 34. 1800.2-2020 F.4.1.4.17
//     (UVM-CORE-DECL-AUDIT-GET-DEFAULT-COMPARER-DECLARATION) gives rule 34
//     above. Setup: An original concrete service implements all twenty-six
//     printed methods with exact formal names and the selected uvm_comparer
//     return type; arguments are (). It is not installed as the global
//     service. Expected: Calling the selected slot through the base view
//     reaches its original implementation once and retains the chosen
//     type/argument/return identity.
// 35. 1800.2-2020 F.4.1.4.18 (UVM-CORE-DECL-AUDIT-SET-DEFAULT-COPIER-PURE)
//     gives rule 35 above. Setup: An original extension implements the other
//     twenty-five printed pure methods and the pinned release extra
//     phase-hopper hook, omitting only this selected printed method. Expected:
//     Compilation rejects the concrete extension and identifies this input and
//     set_default_copier; no runtime binary is executed.
// 36. 1800.2-2020 F.4.1.4.18
//     (UVM-CORE-DECL-AUDIT-SET-DEFAULT-COPIER-DECLARATION) gives rule 36
//     above. Setup: An original concrete service implements all twenty-six
//     printed methods with exact formal names and the selected void return
//     type; arguments are (uvm_copier copier). It is not installed as the
//     global service. Expected: Calling the selected slot through the base
//     view reaches its original implementation once and retains the chosen
//     type/argument/return identity.
// 37. 1800.2-2020 F.4.1.4.19 (UVM-CORE-DECL-AUDIT-GET-DEFAULT-COPIER-PURE)
//     gives rule 37 above. Setup: An original extension implements the other
//     twenty-five printed pure methods and the pinned release extra
//     phase-hopper hook, omitting only this selected printed method. Expected:
//     Compilation rejects the concrete extension and identifies this input and
//     get_default_copier; no runtime binary is executed.
// 38. 1800.2-2020 F.4.1.4.19
//     (UVM-CORE-DECL-AUDIT-GET-DEFAULT-COPIER-DECLARATION) gives rule 38
//     above. Setup: An original concrete service implements all twenty-six
//     printed methods with exact formal names and the selected uvm_copier
//     return type; arguments are (). It is not installed as the global
//     service. Expected: Calling the selected slot through the base view
//     reaches its original implementation once and retains the chosen
//     type/argument/return identity.
// 39. 1800.2-2020 F.4.1.4.20 (UVM-CORE-DECL-AUDIT-GET-GLOBAL-SEED-PURE) gives
//     rule 39 above. Setup: An original extension implements the other
//     twenty-five printed pure methods and the pinned release extra
//     phase-hopper hook, omitting only this selected printed method. Expected:
//     Compilation rejects the concrete extension and identifies this input and
//     get_global_seed; no runtime binary is executed.
// 40. 1800.2-2020 F.4.1.4.20 (UVM-CORE-DECL-AUDIT-GET-GLOBAL-SEED-DECLARATION)
//     gives rule 40 above. Setup: An original concrete service implements all
//     twenty-six printed methods with exact formal names and the selected int
//     unsigned return type; arguments are (). It is not installed as the
//     global service. Expected: Calling the selected slot through the base
//     view reaches its original implementation once and retains the chosen
//     type/argument/return identity.
// 41. 1800.2-2020 F.4.1.4.21 (UVM-CORE-DECL-AUDIT-SET-RESOURCE-POOL-PURE)
//     gives rule 41 above. Setup: An original extension implements the other
//     twenty-five printed pure methods and the pinned release extra
//     phase-hopper hook, omitting only this selected printed method. Expected:
//     Compilation rejects the concrete extension and identifies this input and
//     set_resource_pool; no runtime binary is executed.
// 42. 1800.2-2020 F.4.1.4.21
//     (UVM-CORE-DECL-AUDIT-SET-RESOURCE-POOL-DECLARATION) gives rule 42 above.
//     Setup: An original concrete service implements all twenty-six printed
//     methods with exact formal names and the selected void return type;
//     arguments are (uvm_resource_pool pool). It is not installed as the
//     global service. Expected: Calling the selected slot through the base
//     view reaches its original implementation once and retains the chosen
//     type/argument/return identity.
// 43. 1800.2-2020 F.4.1.4.22 (UVM-CORE-DECL-AUDIT-GET-RESOURCE-POOL-PURE)
//     gives rule 43 above. Setup: An original extension implements the other
//     twenty-five printed pure methods and the pinned release extra
//     phase-hopper hook, omitting only this selected printed method. Expected:
//     Compilation rejects the concrete extension and identifies this input and
//     get_resource_pool; no runtime binary is executed.
// 44. 1800.2-2020 F.4.1.4.22
//     (UVM-CORE-DECL-AUDIT-GET-RESOURCE-POOL-DECLARATION) gives rule 44 above.
//     Setup: An original concrete service implements all twenty-six printed
//     methods with exact formal names and the selected uvm_resource_pool
//     return type; arguments are (). It is not installed as the global
//     service. Expected: Calling the selected slot through the base view
//     reaches its original implementation once and retains the chosen
//     type/argument/return identity.
// 45. 1800.2-2020 F.4.1.4.23
//     (UVM-CORE-DECL-AUDIT-SET-RESOURCE-POOL-DEFAULT-PRECEDENCE-PURE) gives
//     rule 45 above. Setup: An original extension implements the other
//     twenty-five printed pure methods and the pinned release extra
//     phase-hopper hook, omitting only this selected printed method. Expected:
//     Compilation rejects the concrete extension and identifies this input and
//     set_resource_pool_default_precedence; no runtime binary is executed.
// 46. 1800.2-2020 F.4.1.4.23
//     (UVM-CORE-DECL-AUDIT-SET-RESOURCE-POOL-DEFAULT-PRECEDENCE-DECLARATION)
//     gives rule 46 above. Setup: An original concrete service implements all
//     twenty-six printed methods with exact formal names and the selected void
//     return type; arguments are (int unsigned precedence). It is not
//     installed as the global service. Expected: Calling the selected slot
//     through the base view reaches its original implementation once and
//     retains the chosen type/argument/return identity.
// 47. 1800.2-2020 F.4.1.4.24
//     (UVM-CORE-DECL-AUDIT-GET-RESOURCE-POOL-DEFAULT-PRECEDENCE-PURE) gives
//     rule 47 above. Setup: An original extension implements the other
//     twenty-five printed pure methods and the pinned release extra
//     phase-hopper hook, omitting only this selected printed method. Expected:
//     Compilation rejects the concrete extension and identifies this input and
//     get_resource_pool_default_precedence; no runtime binary is executed.
// 48. 1800.2-2020 F.4.1.4.24
//     (UVM-CORE-DECL-AUDIT-GET-RESOURCE-POOL-DEFAULT-PRECEDENCE-DECLARATION)
//     gives rule 48 above. Setup: An original concrete service implements all
//     twenty-six printed methods with exact formal names and the selected int
//     unsigned return type; arguments are (). It is not installed as the
//     global service. Expected: Calling the selected slot through the base
//     view reaches its original implementation once and retains the chosen
//     type/argument/return identity.
// 49. 1800.2-2020 F.4.1.4.25 (UVM-CORE-DECL-AUDIT-GET-UVM-SEEDING-PURE) gives
//     rule 49 above. Setup: An original extension implements the other
//     twenty-five printed pure methods and the pinned release extra
//     phase-hopper hook, omitting only this selected printed method. Expected:
//     Compilation rejects the concrete extension and identifies this input and
//     get_uvm_seeding; no runtime binary is executed.
// 50. 1800.2-2020 F.4.1.4.25 (UVM-CORE-DECL-AUDIT-GET-UVM-SEEDING-DECLARATION)
//     gives rule 50 above. Setup: An original concrete service implements all
//     twenty-six printed methods with exact formal names and the selected bit
//     return type; arguments are (). It is not installed as the global
//     service. Expected: Calling the selected slot through the base view
//     reaches its original implementation once and retains the chosen
//     type/argument/return identity.
// 51. 1800.2-2020 F.4.1.4.26 (UVM-CORE-DECL-AUDIT-SET-UVM-SEEDING-PURE) gives
//     rule 51 above. Setup: An original extension implements the other
//     twenty-five printed pure methods and the pinned release extra
//     phase-hopper hook, omitting only this selected printed method. Expected:
//     Compilation rejects the concrete extension and identifies this input and
//     set_uvm_seeding; no runtime binary is executed.
// 52. 1800.2-2020 F.4.1.4.26 (UVM-CORE-DECL-AUDIT-SET-UVM-SEEDING-DECLARATION)
//     gives rule 52 above. Setup: An original concrete service implements all
//     twenty-six printed methods with exact formal names and the selected void
//     return type; arguments are (bit enable). It is not installed as the
//     global service. Expected: Calling the selected slot through the base
//     view reaches its original implementation once and retains the chosen
//     type/argument/return identity.
// 53. 1800.2-2020 F.4.1.2 (UVM-CORE-DECL-AUDIT-CORE-NOARG-CONSTRUCTOR) gives
//     rule 53 above. Setup: Use fresh simulation state, exact public base
//     views and original objects; do not install an extra custom global
//     service or assume an implementation default concrete type. Expected: The
//     original base-typed instance exists and all selected dispatch
//     observations complete.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Control-only: the extra pinned hook permits the original methods to run.
// It does not pass the listed-only constructor or define any builtin algorithm.
module test_pinned_core_extra_hook_control_dispatches_all_twenty_six_standard_methods;
  import uvm_pkg::*;
  class complete_service extends uvm_coreservice_t;
    `include "core_decl_control_bodies64.svh"
  endclass
  class original_visitor extends uvm_visitor#(uvm_component);
    virtual function void visit(uvm_component node); endfunction
  endclass
  initial begin
    automatic complete_service original=new();
    automatic uvm_coreservice_t base=original;
    automatic uvm_coreservice_t selected=uvm_coreservice_t::get();
    automatic uvm_default_factory factory=new();
    automatic uvm_default_report_server server=new();
    automatic uvm_text_tr_database database=new("original64");
    automatic original_visitor visitor=new();
    automatic uvm_line_printer printer=new("original64");
    automatic uvm_packer packer=new("original64");
    automatic uvm_comparer comparer=new("original64");
    automatic uvm_copier copier=new("original64");
    automatic uvm_resource_pool pool=new();
    automatic bit exact=1, once=1;
    exact &= base.get_root()==uvm_root::get();
    base.set_factory(factory); exact &= base.get_factory()==factory;
    base.set_report_server(server); exact &= base.get_report_server()==server;
    base.set_default_tr_database(database);
    exact &= base.get_default_tr_database()==database;
    base.set_component_visitor(visitor); exact &= base.get_component_visitor()==visitor;
    base.set_phase_max_ready_to_end(17); exact &= base.get_phase_max_ready_to_end()==17;
    base.set_default_printer(printer); exact &= base.get_default_printer()==printer;
    base.set_default_packer(packer); exact &= base.get_default_packer()==packer;
    base.set_default_comparer(comparer); exact &= base.get_default_comparer()==comparer;
    base.set_default_copier(copier); exact &= base.get_default_copier()==copier;
    exact &= base.get_global_seed()==233;
    base.set_resource_pool(pool); exact &= base.get_resource_pool()==pool;
    base.set_resource_pool_default_precedence(317);
    exact &= base.get_resource_pool_default_precedence()==317;
    base.set_uvm_seeding(1); exact &= base.get_uvm_seeding();
    foreach (original.calls[i]) begin
      once &= original.calls[i]==1;
      $display("UT: core_dispatch slot %0d calls %0d",i+1,original.calls[i]);
    end
    $display("UT: core_dispatch exact %0d once %0d selected_unchanged %0d",exact,once,
      uvm_coreservice_t::get()==selected && base!=selected);
    $finish;
  end
endmodule
