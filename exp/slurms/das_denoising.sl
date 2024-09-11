#!/bin/bash

#SBATCH --job-name=dasdeno
#SBATCH --qos=short
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=20
#SBATCH --output=dasdeno.out
#SBATCH --error=dasdeno.err
#SBATCH --time=60

export v1_config=/home/yzhang2018@ec-nantes.fr/IUS2024_Diffusion/configs/imagenet_256_1c.yml
export v1_modelPath=both1c
export MATLAB_PATH=/home/yzhang2018@ec-nantes.fr/IUS2024_Diffusion/matlabfiles/ 
echo DRUS_v1_config
echo DRUS_v1_modelPath
echo MATLAB_PATH

# activate micromamba
source ~/.bashrc
micromamba activate ddrm


# launch python script
# python -c "from PIL import Image; print('ok')" #no problem
echo $LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/micromamba/yzhang2018@ec-nantes.fr/envs/ddrm/lib/
echo $LD_LIBRARY_PATH

python -u /home/yzhang2018@ec-nantes.fr/DRUS-v1-glicid/main.py --ni --config $v1_config  --doc $v1_modelPath  --ckpt model004000.pt --matlab_path $MATLAB_PATH --timesteps 50 --deg Deno --image_folder dasdeno  --phansType linear

