CONFIG_PATH=./reconstruction_system/config/realsense.json
ADDRESS=224.0.0.1
REFERED_DIRECTORY_PATH=./reconstruction_system/dataset
SAVE_DATASET_PATH=./reconstruction_system/save_dataset

record:
	python3 ./reconstruction_system/scripts/record.py

run_pipeline:
	python3 ./reconstruction_system/run_system.py --make --register --refine --integrate ${CONFIG_PATH}
	python ./pipelines/color_map_optimization_for_reconstruction_system.py  --config ${CONFIG_PATH}

run_client:
	python3 ./realsense_client/EtherSenseClient.py ${ADDRESS}

run_server:
	python3 ./realsense_server/EtherSenseServer.py

mv_dataset:
	date "+%s" -r ${REFERED_DIRECTORY_PATH}
	$(eval DIRECTORY_NAME := $(shell date "+%s" -r ${REFERED_DIRECTORY_PATH}))
	mv ${REFERED_DIRECTORY_PATH} ${SAVE_DATASET_PATH}/$(DIRECTORY_NAME)
	mkdir -p ${REFERED_DIRECTORY_PATH}/color ${REFERED_DIRECTORY_PATH}/depth

