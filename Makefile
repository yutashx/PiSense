CONFIG_PATH=./reconstruction_system/config/realsense.json
ADDRESS=10.42.0.185

record:
	python3 ./reconstruction_system/scripts/record.py
run_pipeline:
	python3 ./reconstruction_system/run_system.py --make --register --refine --integrate ${CONFIG_PATH}
	python ./pipelines/color_map_optimization_for_reconstruction_system.py  --config ${CONFIG_PATH}
run_client:
	python3 ./realsense_client/EtherSenseClient.py ${ADDRESS}
run_server:
	python3 ./realsense_server/EtherSenseServer.py
