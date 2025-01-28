make clean 
CC=clang++ make ft CLASS=A

cd bin
./ft.A > dp_execute_out.txt
grep "Verification    =               SUCCESSFUL" dp_execute_out.txt
return $?
