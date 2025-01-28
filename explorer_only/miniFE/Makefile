all: cpu

cpu: clean copy_code execute_hotspot_detection execute_dynamic_analysis create_code_version_with_metadata create_code_version_without_metadata execute_pattern_analysis_with_metadata execute_pattern_analysis_without_metadata

clean:
	rm -rvf miniFE_*

copy_code:
	cp -r ../../clean_code/miniFE/ref miniFE_orig 

execute_hotspot_detection:
	echo "MINIFE_DIR: ${MINIFE_DIR}"
	cd miniFE_orig/src && DP_PROJECT_ROOT_DIR=${MINIFE_DIR} make -f Makefile.discopop.hotspots
	cd miniFE_orig/src && ./miniFE.x --nx 5 --ny 5 --nz 5
	cd miniFE_orig/src && ./miniFE.x --nx 25 --ny 25 --nz 25
	cd miniFE_orig/src && ./miniFE.x --nx 40 --ny 40 --nz 40
	cd miniFE_orig/src/.discopop && hotspot_analyzer

execute_dynamic_analysis:
	cd miniFE_orig/src && make clean
	cd miniFE_orig/src && DP_PROJECT_ROOT_DIR=${MINIFE_DIR} make -f Makefile.discopop.patterns
	cd miniFE_orig/src && ./miniFE.x --nx 10 --ny 10 --nz 10 

create_code_version_with_metadata:
	cp -r miniFE_orig miniFE_orig_with_metadata
# correct the copied FileMapping.txt
	sed -i 's/\/miniFE_orig\//\/miniFE_orig_with_metadata\//g' miniFE_orig_with_metadata/src/.discopop/FileMapping.txt

create_code_version_without_metadata:
	cp -r miniFE_orig miniFE_orig_without_metadata
# correct the copied FileMapping.txt
	sed -i 's/\/miniFE_orig\//\/miniFE_orig_without_metadata\//g' miniFE_orig_without_metadata/src/.discopop/FileMapping.txt

execute_pattern_analysis_with_metadata:
	cd miniFE_orig_with_metadata/src/.discopop && discopop_explorer --enable-patterns doall,reduction --plot-pet
	cd miniFE_orig_with_metadata/src/.discopop && discopop_patch_generator --log info

execute_pattern_analysis_without_metadata:
	cd miniFE_orig_without_metadata/src/.discopop && rm -f profiler/dependency_metadata.txt
	cd miniFE_orig_without_metadata/src/.discopop && discopop_explorer --enable-patterns doall,reduction
	cd miniFE_orig_without_metadata/src/.discopop && discopop_patch_generator --log info