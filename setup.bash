#!/bin/bash

# GCC
sudo apt update
sudo apt install -y build-essential
sudo apt-get install manpages-dev -y
sudo apt install -y --no-install-recommends cmake libzmqpp-dev libopencv-dev unzip

# Noetic ROS
echo "################################################################"
echo ""
echo ">>> {Uninstalling ROS Noetic Installation from your computer}"
echo ""
echo ">>> {It will take around few minutes to complete}"
echo ""
sudo apt-get purge ros-* -y
echo ""
echo "#################################################################"
echo ""
echo ">>> {Auto removing dependent packages}"
sudo apt-get autoremove -y
echo ""
echo ">>> {Done: ROS Noetic Uninstall}"
echo "#################################################################"

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt install curl -y
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
sudo apt update
sudo apt install ros-noetic-desktop-full -y
source /opt/ros/noetic/setup.bash
echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc

# Remove CUDA
sudo apt-get --purge remove "*cublas*" "*cufft*" "*curand*" \
"*cusolver*" "*cusparse*" "*npp*" "*nvjpeg*" "cuda*" "nsight*" -y
sudo apt-get --purge remove "*nvidia*" -y
sudo apt-get autoremove -y
sudo apt-get autoclean -y
sudo rm -rf /usr/local/cuda*

# CUDA 12.6
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get install cuda-toolkit-12-6 -y
sudo apt-get install -y nvidia-driver-535
rm cuda-keyring_1.1-1_all.deb
echo "export PATH=/usr/local/cuda-12.6/bin:$PATH" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=/usr/local/cuda-12.6/lib64:$LD_LIBRARY_PATH" >> ~/.bashrc

# Environment setup
sudo apt install -y python3-catkin-tools python3-vcstool
export ROS_VERSION=noetic
export CATKIN_WS=./ros_ws

# Remove old workspace
if [ -d $CATKIN_WS ]; then
    rm -rf $CATKIN_WS
fi
mkdir -p $CATKIN_WS/src
cd $CATKIN_WS
echo "source $PWD/devel/setup.bash" >> ~/.bashrc
catkin init
catkin config --extend /opt/ros/$ROS_VERSION
catkin config --merge-devel
catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-fdiagnostics-color

cd -
cp stereo.repos $CATKIN_WS/src
cd $CATKIN_WS/src
vcs import < stereo.repos
rm stereo.repos
cd midi
git submodule update --init --recursive

cd -
parent_path=$(dirname "$PWD/src")
echo "export FLIGHTMARE_PATH=$parent_path/flightmare" >> ~/.bashrc
echo "export PLANNER_PATH=$parent_path/midi" >> ~/.bashrc
echo "export OMP_CANCELLATION=true" >> ~/.bashrc
echo "export OMP_NUM_THREADS=4" >> ~/.bashrc

sudo apt install python3-pip -y

echo "Creating an conda environment from the environment.yaml file. Make sure you have anaconda installed"
conda env remove -n agileflight -y
conda env create -f $parent_path/midi/environment.yaml

echo "Source the anaconda environment. If errors, change to the right anaconda path."
source ~/anaconda3/etc/profile.d/conda.sh

echo "Activating the environment"
conda activate agileflight

echo "Compiling the agile flight environment and install the environment as python package"
cd $parent_path/flightmare/flightlib/build
cmake ..
make -j10
pip install .

echo "Install RPG baseline"
cd $parent_path/flightmare/flightpy/flightrl
pip install .
pip install flightgym rpg_baselines

echo "Making sure submodules are initialized and up-to-date"
git submodule update --init --recursive

echo "Using apt to install dependencies..."
echo "Will ask for sudo permissions:"
sudo apt-get install python3-catkin-tools ros-noetic-rqt ros-noetic-rqt-common-plugins ros-noetic-rqt-robot-plugins ros-noetic-mavros ros-noetic-grid-map-rviz-plugin -y

echo "Ignoring unused Flightmare folders!"
touch $parent_path/flightmare/flightros/CATKIN_IGNORE

# echo "Downloading Trajectories..."
wget "https://download.ifi.uzh.ch/rpg/Flightmare/trajectories.zip" --directory-prefix=$parent_path/flightmare/flightpy/configs/vision

echo "Unziping Trajectories... (this might take a while)"
unzip -o $parent_path/flightmare/flightpy/configs/vision/trajectories.zip -d $parent_path/flightmare/flightpy/configs/vision/ | awk 'BEGIN {ORS=" "} {if(NR%50==0)print "."}'

echo "Removing Trajectories zip file"
rm $parent_path/flightmare/flightpy/configs/vision/trajectories.zip

echo "Downloading Flightmare Unity standalone..."
if [ -f $parent_path/flightmare/flightrender/RPG_Flightmare_Data.zip ]; then
    rm $parent_path/flightmare/flightrender/RPG_Flightmare_Data.zip
fi
gdown https://drive.google.com/uc?id=1scWY4-PCGrZoO8HGgiUQ8arKGwiWt374 -O $parent_path/flightmare/flightrender/RPG_Flightmare_Data.zip
echo "Unziping Flightmare Unity Standalone... (this might take a while)"
unzip -o $parent_path/flightmare/flightrender/RPG_Flightmare_Data.zip -d $parent_path/flightmare/flightrender | awk 'BEGIN {ORS=" "} {if(NR%10==0)print "."}'
echo "Removing Flightmare Unity Standalone zip file"
rm $parent_path/flightmare/flightrender/RPG_Flightmare_Data.zip
chmod +x $parent_path/flightmare/flightrender/RPG_Flightmare.x86_64
echo "conda activate agileflight" >> ~/.bashrc

# CSCV
cd $parent_path/cscv
mkdir -p checkpoints
gdown https://drive.google.com/uc?id=14KvRDWU0oA9nP1fb6-R4P2Ymiu2dO4_n -O checkpoints/Demo_scaleflowpp.pth

echo "Done!"
echo "Have a save flight!"
