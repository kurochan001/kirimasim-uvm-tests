/*
:name: test_package_file_type_preserves_real_file_and_multichannel_descriptors_and_standard_handles
:description: UVM_FILE carries actual file/MCD handles and standard stream constants retain their defined values
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.8 F.2.9 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_package_file_type_preserves_real_file_and_multichannel_descriptors_and_standard_handles.expected
*/
// Actual temporary files, created in the runner working directory.
module test_package_file_type_preserves_real_file_and_multichannel_descriptors_and_standard_handles;
  import uvm_pkg::*;
  function automatic bit contains_payload(string path,string expected);
    UVM_FILE fd=$fopen(path,"r");
    string line;
    int count;
    if (fd==0) return 0;
    count=$fgets(line,fd); $fclose(fd);
    return count>0 && line=={expected,"\n"};
  endfunction
  initial begin
    UVM_FILE fd,first_mcd,second_mcd,channels;
    fd=$fopen("file57.txt","w");
    first_mcd=$fopen("first57.txt"); second_mcd=$fopen("second57.txt");
    if (fd==0 || first_mcd==0 || second_mcd==0) $fatal(1,"file setup failed");
    $fdisplay(fd,"single57"); $fclose(fd);
    channels=first_mcd | second_mcd; $fdisplay(channels,"both57"); $fclose(channels);
    $display("UT: file_type descriptor %0d channel_one %0d channel_two %0d",
      contains_payload("file57.txt","single57"),contains_payload("first57.txt","both57"),
      contains_payload("second57.txt","both57"));
    $display("UT: standard_handles stdin %0d stdout %0d stderr %0d",
      UVM_STDIN==32'h80000000,UVM_STDOUT==32'h80000001,UVM_STDERR==32'h80000002);
    $fdisplay(UVM_STDOUT,"UT: standard_stdout delivered 1");
    $finish;
  end
endmodule
