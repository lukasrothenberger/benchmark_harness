all: cpu

cpu: clean copy_code execute_dynamic_analysis create_code_version_with_metadata create_code_version_without_metadata execute_pattern_analysis_with_metadata execute_pattern_analysis_without_metadata 

clean:
	rm -rvf orig*

copy_code:
	
	cp -r ../../clean_code/counter_example orig 

execute_hotspot_detection:
	cd orig &&  discopop_hotspot_cxx -o out code.cpp
	
	cd orig && ./out
	cd orig/.discopop && hotspot_analyzer

execute_dynamic_analysis:
	cd orig && discopop_cxx -o out code.cpp
	cd orig && ./out

create_code_version_with_metadata:
	cp -r orig orig_with_metadata
# correct the copied FileMapping.txt
	sed -i 's/\/orig\//\/orig_with_metadata\//g' orig_with_metadata/.discopop/FileMapping.txt

create_code_version_without_metadata:
	cp -r orig orig_without_metadata
# correct the copied FileMapping.txt
	sed -i 's/\/orig\//\/orig_without_metadata\//g' orig_without_metadata/.discopop/FileMapping.txt

execute_pattern_analysis_with_metadata:
	cd orig_with_metadata/.discopop && discopop_explorer --enable-patterns doall,reduction --profiling profile.txt
	cd orig_with_metadata/.discopop && discopop_patch_generator  --log info

execute_pattern_analysis_without_metadata:
	cd orig_without_metadata/.discopop && rm -f profiler/dependency_metadata.txt
	cd orig_without_metadata/.discopop && discopop_explorer --enable-patterns doall,reduction
	cd orig_without_metadata/.discopop && discopop_patch_generator