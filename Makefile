CONFIG_PATH=./reconstruction_system/config/realsense.json

record:
	python3 ./reconstruction_system/scripts/record.py
run_pipeline:
	python3 ./reconstruction_system/run_system.py --make --register --refine --integrate ${CONFIG_PATH}
	python ./pipelines/color_map_optimization_for_reconstruction_system.py  --config ${CONFIG_PATH}
