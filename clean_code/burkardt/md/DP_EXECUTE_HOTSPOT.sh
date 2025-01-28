cd build
./prog 3 1000 100 > dp_execute_out.txt
grep ".*e-11" dp_execute_out.txt
return $?
