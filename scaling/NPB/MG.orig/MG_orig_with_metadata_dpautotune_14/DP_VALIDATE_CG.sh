make clean 
CC=clang++ make cg CLASS=A

cd bin
./cg.A > dp_execute_out.txt
grep "Verification    =               SUCCESSFUL" dp_execute_out.txt
return $?
