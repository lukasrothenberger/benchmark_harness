make clean 
CC=clang++ make lu CLASS=A

cd bin
./lu.A > dp_execute_out.txt
grep "Verification    =               SUCCESSFUL" dp_execute_out.txt
return $?
