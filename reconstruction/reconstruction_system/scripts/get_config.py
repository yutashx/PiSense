import argparse
import json
import open3d as o3d


def get_config():
    device_lists = o3d.t.io.RealSenseSensor.list_devices()
    print(device_lists)

    return device_lists

if __name__ == "__main__":
    device_lists = get_config()
    """
    parser = argparse.ArgumentParser(description="Record Rosbag")
    parser.add_argument("config", help="path to the config file")

    args = parser.parse_args()

    config_filepath = "../config/realsense.json"
    """
