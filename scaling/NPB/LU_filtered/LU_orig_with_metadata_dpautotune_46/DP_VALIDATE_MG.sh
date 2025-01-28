make clean
rm -rf bin/* 
CC=clang++ make mg CLASS=A

cd bin
./mg.A > dp_execute_out.txt
grep "Verification    =               SUCCESSFUL" dp_execute_out.txt
return $?
