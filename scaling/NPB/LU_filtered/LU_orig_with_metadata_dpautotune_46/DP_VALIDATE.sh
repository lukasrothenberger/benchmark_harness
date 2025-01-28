make clean 
rm -rf bin/*
CC=clang++ make lu CLASS=S

cd bin
./lu.S > dp_execute_out.txt
grep "Verification    =               SUCCESSFUL" dp_execute_out.txt
return $?
