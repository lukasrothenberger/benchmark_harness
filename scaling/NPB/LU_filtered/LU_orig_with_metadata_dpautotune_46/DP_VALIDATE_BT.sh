make clean 
rm -rf bin/*
CC=clang++ make bt CLASS=A

cd bin
./bt.A > dp_execute_out.txt
grep "Verification    =               SUCCESSFUL" dp_execute_out.txt
return $?
