all: cpu

cpu: clean copy_code execute_hotspot_detection execute_dynamic_analysis create_code_version_with_metadata create_code_version_without_metadata execute_pattern_analysis_with_metadata execute_pattern_analysis_without_metadata execute_auto_tuner_with_metadata execute_auto_tuner_without_metadata execute_parallel_reference # execute_sanity_checker_with_metadata execute_sanity_checker_without_metadata 

clean:
	rm -rvf md_*

copy_code:
	cp -r ../../../clean_code/burkardt/md md_orig 

execute_hotspot_detection:
	cd md_orig && mkdir build
	cd md_orig/build && cmake -DCMAKE_CXX_COMPILER=discopop_hotspot_cxx -DCMAKE_CXX_FLAGS="-fopenmp" ..
	cd md_orig/build && make 
	cd md_orig/build && ./prog 3 40 40
	cd md_orig/build && ./prog 3 300 100
	cd md_orig/build && ./prog 3 600 100
	cd md_orig/build/.discopop && hotspot_analyzer

execute_dynamic_analysis:
	cd md_orig/build && rm -r CMakeCache.txt CMakeFiles cmake_install.cmake
	cd md_orig/build && cmake -DCMAKE_CXX_COMPILER=discopop_cxx -DCMAKE_CXX_FLAGS="-fopenmp" ..
	cd md_orig/build && make 
	cd md_orig/build && ./prog 3 40 40 

create_code_version_with_metadata:
	cp -r md_orig md_orig_with_metadata
# correct the copied FileMapping.txt
	sed -i 's/\/md_orig\//\/md_orig_with_metadata\//g' md_orig_with_metadata/build/.discopop/FileMapping.txt

create_code_version_without_metadata:
	cp -r md_orig md_orig_without_metadata
# correct the copied FileMapping.txt
	sed -i 's/\/md_orig\//\/md_orig_without_metadata\//g' md_orig_without_metadata/build/.discopop/FileMapping.txt

execute_pattern_analysis_with_metadata:
	cd md_orig_with_metadata/build/.discopop && discopop_explorer --enable-patterns doall,reduction --enable-statistics

execute_pattern_analysis_without_metadata:
	cd md_orig_without_metadata/build/.discopop && rm -f profiler/dependency_metadata.txt
	cd md_orig_without_metadata/build/.discopop && discopop_explorer --enable-patterns doall,reduction --enable-statistics

execute_auto_tuner_with_metadata:
	cd md_orig_with_metadata && echo "$$(pwd)"
	cd md_orig_with_metadata && discopop_auto_tuner --log debug --project-path $$(pwd) --dot-dp-path $$(pwd)/build/.discopop

execute_auto_tuner_without_metadata:
	cd md_orig_without_metadata && echo "$$(pwd)"
	cd md_orig_without_metadata && discopop_auto_tuner --log debug --project-path $$(pwd) --dot-dp-path $$(pwd)/build/.discopop

execute_sanity_checker_with_metadata:
	cd md_orig_with_metadata && echo "$$(pwd)"
	cd md_orig_with_metadata && discopop_sanity_checker --log debug --project-path $$(pwd) --dot-dp-path $$(pwd)/build/.discopop

execute_sanity_checker_without_metadata:
	cd md_orig_without_metadata && echo "$$(pwd)"
	cd md_orig_without_metadata && discopop_sanity_checker --log debug --project-path $$(pwd) --dot-dp-path $$(pwd)/build/.discopop

execute_parallel_reference:
	cp -r ../../../clean_code/burkardt/md_parallel md_PAR
	cd md_PAR && ./DP_COMPILE.sh
	cd md_PAR && /usr/bin/time --append --format="REF; %e; %x;" -o ../md_orig_with_metadata/measurements.csv ./DP_EXECUTE.sh
	cd md_PAR && /usr/bin/time --append --format="REF; %e; %x;" -o ../md_orig_without_metadata/measurements.csv ./DP_EXECUTE.sh
