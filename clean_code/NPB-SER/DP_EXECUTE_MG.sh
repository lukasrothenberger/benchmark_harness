cd bin
./mg.C > dp_execute_out.txt
grep "Verification    =               SUCCESSFUL" dp_execute_out.txt
return $?
