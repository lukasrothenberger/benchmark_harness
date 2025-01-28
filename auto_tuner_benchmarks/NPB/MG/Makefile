BENCHMARK_NAME=$$(basename ${CURDIR})
BENCHMARK_NAME_LOWERCASE=$$(echo ${BENCHMARK_NAME} | tr '[:upper:]' '[:lower:]')

all: cpu

cpu: clean copy_code execute_hotspot_detection execute_dynamic_analysis create_code_version_with_metadata create_code_version_without_metadata execute_pattern_analysis_with_metadata execute_pattern_analysis_without_metadata execute_auto_tuner_with_metadata execute_auto_tuner_without_metadata execute_parallel_reference # execute_sanity_checker_with_metadata execute_sanity_checker_without_metadata

clean: 
	rm -rvf ${BENCHMARK_NAME}_*

copy_code:
	cp -r ../../../clean_code/NPB-SER ${BENCHMARK_NAME}_orig

execute_hotspot_detection:
	cd ${BENCHMARK_NAME}_orig && make clean
	cd ${BENCHMARK_NAME}_orig && DOT_DISCOPOP=$$(pwd)/bin/.discopop CXX=discopop_hotspot_cxx CC=discopop_hotspot_cc make ${BENCHMARK_NAME_LOWERCASE} CLASS=S
	cd ${BENCHMARK_NAME}_orig && DOT_DISCOPOP=$$(pwd)/bin/.discopop CXX=discopop_hotspot_cxx CC=discopop_hotspot_cc make ${BENCHMARK_NAME_LOWERCASE} CLASS=A
	cd ${BENCHMARK_NAME}_orig/bin && ./${BENCHMARK_NAME_LOWERCASE}.S
	cd ${BENCHMARK_NAME}_orig/bin && ./${BENCHMARK_NAME_LOWERCASE}.A
	cd ${BENCHMARK_NAME}_orig/bin/.discopop && hotspot_analyzer

execute_dynamic_analysis:
	cd ${BENCHMARK_NAME}_orig && make clean
	cd ${BENCHMARK_NAME}_orig && DOT_DISCOPOP=$$(pwd)/bin/.discopop CXX=discopop_cxx CC=discopop_cc make ${BENCHMARK_NAME_LOWERCASE} CLASS=S
	cd ${BENCHMARK_NAME}_orig/bin && ./${BENCHMARK_NAME_LOWERCASE}.S
	cd ${BENCHMARK_NAME}_orig/bin/.discopop && discopop_preprocessor --log info

create_code_version_with_metadata:
	cp -r ${BENCHMARK_NAME}_orig ${BENCHMARK_NAME}_orig_with_metadata
# correct the copied FileMapping.txt
	sed -i "s/\/${BENCHMARK_NAME}_orig\//\/${BENCHMARK_NAME}_orig_with_metadata\//g" ${BENCHMARK_NAME}_orig_with_metadata/bin/.discopop/FileMapping.txt

create_code_version_without_metadata:
	cp -r ${BENCHMARK_NAME}_orig ${BENCHMARK_NAME}_orig_without_metadata
# correct the copied FileMapping.txt
	sed -i "s/\/${BENCHMARK_NAME}_orig\//\/${BENCHMARK_NAME}_orig_without_metadata\//g" ${BENCHMARK_NAME}_orig_without_metadata/bin/.discopop/FileMapping.txt

execute_pattern_analysis_with_metadata:
	cd ${BENCHMARK_NAME}_orig_with_metadata/bin/.discopop && discopop_explorer --enable-patterns doall,reduction --enable-statistics

execute_pattern_analysis_without_metadata:
	cd ${BENCHMARK_NAME}_orig_without_metadata/bin/.discopop && rm -f profiler/dependency_metadata.txt
	cd ${BENCHMARK_NAME}_orig_without_metadata/bin/.discopop && discopop_explorer --enable-patterns doall,reduction --enable-statistics

execute_auto_tuner_with_metadata:
	cd ${BENCHMARK_NAME}_orig_with_metadata && cp DP_COMPILE_${BENCHMARK_NAME}.sh DP_COMPILE.sh
	cd ${BENCHMARK_NAME}_orig_with_metadata && cp DP_COMPILE_HOTSPOT_${BENCHMARK_NAME}.sh DP_COMPILE_HOTSPOT.sh
	cd ${BENCHMARK_NAME}_orig_with_metadata && cp DP_EXECUTE_${BENCHMARK_NAME}.sh DP_EXECUTE.sh
	cd ${BENCHMARK_NAME}_orig_with_metadata && cp DP_EXECUTE_HOTSPOT_${BENCHMARK_NAME}.sh DP_EXECUTE_HOTSPOT.sh
	cd ${BENCHMARK_NAME}_orig_with_metadata && echo "$$(pwd)"
	cd ${BENCHMARK_NAME}_orig_with_metadata && discopop_auto_tuner --log debug --project-path $$(pwd) --dot-dp-path $$(pwd)/bin/.discopop

execute_auto_tuner_without_metadata:
	cd ${BENCHMARK_NAME}_orig_without_metadata && cp DP_COMPILE_${BENCHMARK_NAME}.sh DP_COMPILE.sh
	cd ${BENCHMARK_NAME}_orig_without_metadata && cp DP_COMPILE_HOTSPOT_${BENCHMARK_NAME}.sh DP_COMPILE_HOTSPOT.sh
	cd ${BENCHMARK_NAME}_orig_without_metadata && cp DP_EXECUTE_${BENCHMARK_NAME}.sh DP_EXECUTE.sh
	cd ${BENCHMARK_NAME}_orig_without_metadata && cp DP_EXECUTE_HOTSPOT_${BENCHMARK_NAME}.sh DP_EXECUTE_HOTSPOT.sh
	cd ${BENCHMARK_NAME}_orig_without_metadata && echo "$$(pwd)"
	cd ${BENCHMARK_NAME}_orig_without_metadata && discopop_auto_tuner  --log debug --project-path $$(pwd) --dot-dp-path $$(pwd)/bin/.discopop

execute_sanity_checker_with_metadata:
	cd ${BENCHMARK_NAME}_orig_with_metadata && cp DP_COMPILE_${BENCHMARK_NAME}.sh DP_COMPILE.sh
	cd ${BENCHMARK_NAME}_orig_with_metadata && cp DP_EXECUTE_${BENCHMARK_NAME}.sh DP_EXECUTE.sh
	cd ${BENCHMARK_NAME}_orig_with_metadata && cp DP_COMPILE_SANITIZE_${BENCHMARK_NAME}.sh DP_COMPILE_SANITIZE.sh
	cd ${BENCHMARK_NAME}_orig_with_metadata && cp DP_EXECUTE_SANITIZE_${BENCHMARK_NAME}.sh DP_EXECUTE_SANITIZE.sh
	cd ${BENCHMARK_NAME}_orig_with_metadata && cp DP_VALIDATE_${BENCHMARK_NAME}.sh DP_VALIDATE.sh
	cd ${BENCHMARK_NAME}_orig_with_metadata && echo "$$(pwd)"
	cd ${BENCHMARK_NAME}_orig_with_metadata && discopop_sanity_checker --log info --project-path $$(pwd) --dot-dp-path $$(pwd)/bin/.discopop

execute_sanity_checker_without_metadata:
	cd ${BENCHMARK_NAME}_orig_without_metadata && cp DP_COMPILE_${BENCHMARK_NAME}.sh DP_COMPILE.sh
	cd ${BENCHMARK_NAME}_orig_without_metadata && cp DP_EXECUTE_${BENCHMARK_NAME}.sh DP_EXECUTE.sh
	cd ${BENCHMARK_NAME}_orig_without_metadata && cp DP_COMPILE_SANITIZE_${BENCHMARK_NAME}.sh DP_COMPILE_SANITIZE.sh
	cd ${BENCHMARK_NAME}_orig_without_metadata && cp DP_EXECUTE_SANITIZE_${BENCHMARK_NAME}.sh DP_EXECUTE_SANITIZE.sh
	cd ${BENCHMARK_NAME}_orig_without_metadata && cp DP_VALIDATE_${BENCHMARK_NAME}.sh DP_VALIDATE.sh
	cd ${BENCHMARK_NAME}_orig_without_metadata && echo "$$(pwd)"
	cd ${BENCHMARK_NAME}_orig_without_metadata && discopop_sanity_checker --log info --project-path $$(pwd) --dot-dp-path $$(pwd)/bin/.discopop

execute_parallel_reference:
	cp -r ../../../clean_code/NPB-OMP ${BENCHMARK_NAME}_OMP
	cd ${BENCHMARK_NAME}_OMP && ./DP_COMPILE_${BENCHMARK_NAME}.sh
	- cd ${BENCHMARK_NAME}_OMP && /usr/bin/time --append --format="REF; %e; %x;" -o ../${BENCHMARK_NAME}_orig_with_metadata/measurements.csv ./DP_EXECUTE_${BENCHMARK_NAME}.sh
	- cd ${BENCHMARK_NAME}_OMP && /usr/bin/time --append --format="REF; %e; %x;" -o ../${BENCHMARK_NAME}_orig_without_metadata/measurements.csv ./DP_EXECUTE_${BENCHMARK_NAME}.sh

	
