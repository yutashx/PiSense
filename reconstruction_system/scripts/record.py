import json
import open3d as o3d
import argparse
import time

def main(config_filepath, bagfile_filepath, frame_range):
    with open(config_filepath) as cf:
        rs_cfg = o3d.t.io.RealSenseSensorConfig(json.load(cf))

    rs = o3d.t.io.RealSenseSensor()
    rs.init_sensor(rs_cfg, 0, bagfile_filepath)
    rs.start_capture(True)  # true: start recording with capture
    for fid in range(frame_range):
        print(f"Frame No.{fid}")
        im_rgbd = rs.capture_frame(True, True)  # wait for frames and align them
        # process im_rgbd.depth and im_rgbd.color

    rs.stop_capture()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Record Rosbag")
    parser.add_argument("--config", help="path to the config file")
    parser.add_argument("--bagfile", help="path to the bag file")
    parser.add_argument("--range", help="frame range to take")

    args = parser.parse_args()

    now = int(time.time())
    config_filepath = "./config/realsense.json"
    bagfile_filepath = f"./dataset/{now}.bag"
    frame_range = 150

    if args.config:
        config_filepath = args.config
    if args.bagfile:
        bagfile_filepath = args.bagfile
    if args.range:
        frame_range = args.range

    main(config_filepath, bagfile_filepath, frame_range)
