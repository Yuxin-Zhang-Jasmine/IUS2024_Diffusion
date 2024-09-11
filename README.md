# Ultrasound Image Enhancement with the Variance of Diff usion Models 

The Diffusion Model that was fine-tuned on high-quality ultrasound RF images is on [GoogleDrive](https://drive.google.com/drive/folders/1xqKNKCDEFFdo2HMUEKPfsusIFme4stwB?usp=drive_link), 

The repository's structure:
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

### For simply displaying the figures in the paper
Only `matlabfiles` is required, and then you can simply run the scripts
- `matlabfiles > images.m ` for Fig.2 and Fig.5
- `matlabfiles > images_score.m` for Fig.4
- `matlabfiles > histogramDisplay.m` for Fig.3


### Inputs of DDRM
The inputs for diffusion denoising sampling are saved in the folder `matlabfiles/data/By/`. These inputs were calculated by using DAS and EBMV (USTB toolbox)


## If you find this work interesting, please consider citing it:
```
@misc{zhangIUS2024Diffusion,
    title={Ultrasound Image Enhancement with the Variance of Diffusion Models},
    author={Yuxin Zhang and Clément Huneau and Jérôme Idier and Diana Mateus},
    archivePrefix={arXiv}
```

This implementation is based on / inspired by:
- [https://ddrm-ml.github.io/](https://ddrm-ml.github.io/) (the DDRM repo)
