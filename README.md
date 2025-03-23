# Spatio-Temporal Trajectory Planning on Raw Sensor Observations for Quadrotor in Dynamic Environments

This repository contains the implementation code for the algorithm described in the submitted manuscript "Spatio-Temporal Trajectory Planning on Raw Sensor Observations for Quadrotor in Dynamic Environments". Please don't hesitate to contact the corresponding author [Thai Binh Nguyen](mailto:thethaibinh@gmail.com) if you have any requests.

## Demonstration video
[![STEREO](https://img.youtube.com/vi/-s8uMdpkfSI/0.jpg)](https://www.youtube.com/watch?v=-s8uMdpkfSI)

## Update
Detailed instructions are coming soon!

### Prerequisite

We currently support Ubuntu 20.04 with ROS Noetic. Other setups are likely to work as well but not actively supported.

1. Before continuing, make sure to have Github SSH connection.

2. Install [anaconda](https://www.anaconda.com/).

### Installation
Run the `setup.bash` in the folder, it will ask for sudo permissions. Then build the packages.
```bash
chmod +x setup.bash
./setup.bash
cd ros_ws/src
conda activate agileflight
source ~/.bashrc
catkin build
```

### Running the simulation

To run the the evaluation automatically, you can use the `./sim.bash N` script provided in this folder. It will automatically perform `N` rollouts and then create an `evaluation.yaml` file which summarizes the rollout statistics.
```
cd midi/
source ~/.bashrc
./sim.bash 10
```
