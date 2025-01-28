make clean 
CC=clang++ make sp CLASS=A

cd bin
./sp.A > dp_execute_out.txt
grep "Verification    =               SUCCESSFUL" dp_execute_out.txt
return $?
