# Ultrasound Image Enhancement with the Variance of Diffusion Models 

The Diffusion Model that was fine-tuned on high-quality ultrasound RF images is on [GoogleDrive](https://drive.google.com/drive/folders/1xqKNKCDEFFdo2HMUEKPfsusIFme4stwB?usp=drive_link). The ultrasound datasets and the code for fine-tuning can be found in [this repository](https://gitlab.univ-nantes.fr/zhang-y-7/guided-diffusion-us).

Repository Structure:
```bash
├── configs           # contains a configuration file for diffusion sampling
├── functions         # for Diffusion Models
├── guided_diffusion  # for Diffusion Models
├── runners           # contains 'diffusion.py' which is called in 'main.py'. 
├── environmental.yml # useful for reproducing the virtual environment
├── main.py           # main file for diffusion sampling
├── exp               
│   ├── logs/both1c   # the employed fine-tuned Diffusion Model is save here (model004000.pt ~2.2GB) 
│   ├── image_samples # save the generated denoised samples
│   ├── slurms        # the slurm files if use HPC 
├── matlabfiles        
│   ├── data          # there is another readme in this folder explaining the details
│   ├── pic           # the figures in the paper are saved here
│   ├── scores        # the evaluated scores and the corresponding figure are saved here
│   ├── src           # tools
├── dasdeno.err, dasdeno.out, ebmv.err, ebmv.out  # log of the sampling process
```

### For simply displaying the figures in the paper
Only `matlabfiles` is required, and then you can simply run the scripts
- `matlabfiles > images.m` for Fig.2 and Fig.5
- `matlabfiles > images_score.m` for Fig.4
- `matlabfiles > histogramDisplay.m` for Fig.3


### Inputs
The inputs for diffusion denoising sampling are saved in the folder `matlabfiles/data/By/`. These inputs were calculated by using DAS and EBMV (we used [USTB toolbox](https://bitbucket.org/ustb/ustb/src/master/) to do the EBMV beamforming)

### Sampling
The general command to do the restoration is as follows:
```
python main.py --ni --config {CONFIG.yml} --doc {MODELFOLDER} --ckpt {MODELCKPT.pt} --matlab_path {MATLABPATH} --timesteps {STEPS}  --deg {TASK} --image_folder {RESULTFOLDER}
```

where
- `CONFIG` is the name of the config file (see `configs/`), including hyperparameters such as batch size and network architectures;
- `MODELFOLDER` is the name of the folder saving the diffusion model checkpoints;
- `MATLABPATH` is the path of the folder `<matlabfiles>`;
- `STEPS` controls how many timesteps (in [1,1000]) used in the sampling process. (e.g. 50);
- `TASK` is Deno in this paper, means denoising;
- `RESULTFOLDER` is the folder name to save the generated denoised samples.

For example
```
python main.py --ni --config imagenet_256_1c.yml --doc both1c --ckpt model004000.pt --matlab_path /IUS2024_Diffusion/matlabfiles/ --timesteps 50 --deg Deno --image_folder ebmvdeno
```

### Citation
If you find our work interesting, please consider citing:
```
@misc{zhangIUS2024Diffusion,
    title={Ultrasound Image Enhancement with the Variance of Diffusion Models},
    author={Yuxin Zhang and Clément Huneau and Jérôme Idier and Diana Mateus},
    archivePrefix={arXiv}
```

This implementation is based on / inspired by:
- [https://ddrm-ml.github.io/](https://ddrm-ml.github.io/) (the DDRM repo)
