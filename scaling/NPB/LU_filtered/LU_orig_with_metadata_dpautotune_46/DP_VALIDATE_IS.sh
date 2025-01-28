make clean 
rm -rf bin/*
CC=clang++ make is CLASS=A

cd bin
./is.A > dp_execute_out.txt
grep "Verification    =               SUCCESSFUL" dp_execute_out.txt
return $?
