cd bin
export TSAN_OPTIONS='ignore_noninstrumented_modules=1'
./cg.S
return $?
