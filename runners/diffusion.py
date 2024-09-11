import os
from math import sqrt, pi, ceil
import numpy as np
import torch
from functions.ckpt_util import download
from functions.denoising import efficient_generalized_steps
from guided_diffusion.script_util import create_model
import mat73
from scipy.io import savemat


def get_beta_schedule(beta_schedule, *, beta_start, beta_end, num_diffusion_timesteps):
    def sigmoid(x):
        return 1 / (np.exp(-x) + 1)

    if beta_schedule == "quad":
        betas = (
                np.linspace(
                    beta_start ** 0.5,
                    beta_end ** 0.5,
                    num_diffusion_timesteps,
                    dtype=np.float64,
                )
                ** 2
        )
    elif beta_schedule == "linear":
        betas = np.linspace(
            beta_start, beta_end, num_diffusion_timesteps, dtype=np.float64
        )
    elif beta_schedule == "const":
        betas = beta_end * np.ones(num_diffusion_timesteps, dtype=np.float64)
    elif beta_schedule == "jsd":  # 1/T, 1/(T-1), 1/(T-2), ..., 1
        betas = 1.0 / np.linspace(
            num_diffusion_timesteps, 1, num_diffusion_timesteps, dtype=np.float64
        )
    elif beta_schedule == "sigmoid":
        betas = np.linspace(-6, 6, num_diffusion_timesteps)
        betas = sigmoid(betas) * (beta_end - beta_start) + beta_start
    else:
        raise NotImplementedError(beta_schedule)
    assert betas.shape == (num_diffusion_timesteps,)
    return betas


class Diffusion(object):
    def __init__(self, args, config, device=None):
        self.args = args
        self.config = config
        if device is None:
            device = (
                torch.device("cuda")
                if torch.cuda.is_available()
                else torch.device("cpu")
            )
        self.device = device

        self.model_var_type = config.model.var_type
        betas = get_beta_schedule(
            beta_schedule=config.diffusion.beta_schedule,
            beta_start=config.diffusion.beta_start,
            beta_end=config.diffusion.beta_end,
            num_diffusion_timesteps=config.diffusion.num_diffusion_timesteps,
        )
        betas = self.betas = torch.from_numpy(betas).float().to(self.device)
        self.num_timesteps = betas.shape[0]

        alphas = 1.0 - betas
        alphas_cumprod = alphas.cumprod(dim=0)
        alphas_cumprod_prev = torch.cat(
            [torch.ones(1).to(device), alphas_cumprod[:-1]], dim=0
        )
        self.alphas_cumprod_prev = alphas_cumprod_prev
        posterior_variance = (
                betas * (1.0 - alphas_cumprod_prev) / (1.0 - alphas_cumprod)
        )
        if self.model_var_type == "fixedlarge":
            self.logvar = betas.log()
            # torch.cat(
            # [posterior_variance[1:2], betas[1:]], dim=0).log()
        elif self.model_var_type == "fixedsmall":
            self.logvar = posterior_variance.clamp(min=1e-20).log()

    def sample(self):
        cls_fn = None

        config_dict = vars(self.config.model)
        model = create_model(**config_dict)
        if self.config.model.use_fp16:
            model.convert_to_fp16()
        ckpt = os.path.join(self.args.log_path, self.args.ckpt)
        print('Path of the current ckpt: ' + ckpt)
        if not os.path.exists(ckpt):
            print('The model does not exist, downloading an Imagenet 3c ckpt...')
            download(
                'https://openaipublic.blob.core.windows.net/diffusion/jul-2021/%dx%d_diffusion_uncond.pt' % (
                    self.config.data.image_size, self.config.data.image_size), ckpt)
        model.load_state_dict(torch.load(ckpt, map_location=self.device))
        model.to(self.device)
        model.eval()
        model = torch.nn.DataParallel(model)
        self.sample_sequence(model, cls_fn)

    def sample_sequence(self, model, cls_fn=None):
        args, config = self.args, self.config

        # ** get SVD results of the model matrix **
        print(f'Loading the degradation function/matrix  and it\'s svd (' + self.args.deg + ')')
        if self.args.deg == "Deno":
            from functions.svd_replacement import Denoising
            H_funcs = Denoising(config.data.channels, self.config.data.image_size, self.device)
        else:
            print("ERROR: problem_model (--deg) type not supported")
            quit()

        # ** create the observation **
        print("data channels : " + str(config.data.channels))
        print("model in_channels : " + str(config.model.in_channels))
        print('The corresponding MATLAB path: ' + args.matlab_path)

        repeat = 20
        timestepsLst = [50] * repeat  # 1 img, 20 repeat
        for phanIdx in range(4, 6):   # EC , CC
            if phanIdx == 4:
                phaname = 'contrast_expe'
            elif phanIdx == 5:
                phaname = 'carotid_cross'
            else:
                print("ERROR: problem at phanname")
                quit()
            # if it already exists, the code proceeds without any errors.
            # This is particularly useful when setting up directories for
            # storing files and you want to ensure the directory structure
            # exists without worrying about whether the directories already exist.
            os.makedirs(os.path.join(args.image_folder, phaname), exist_ok=True)
            print('----------------------------------------------------------------------------')
            print(phaname)
            print('----------------------------------------------------------------------------')
            Bypath = 'data/By/' + phaname + '0.mat'  # replace '0' with '_das' to use the das-beamformed RF image instead
            observ = torch.from_numpy(mat73.loadmat(args.matlab_path + Bypath)['By'])
            observ = (observ.view(1, -1)).to(self.device)  # (1,65536)
            gamma = 0.03   # for das-beamformed images, gamma=0.04 leads to a better result.
            idx_so_far = 0
            print(f'Start restoration')
            print('len(timestepsLst) = ', len(timestepsLst))
            for _ in range(len(timestepsLst)):
                timesteps = timestepsLst[idx_so_far]
                # ** Begin DDRM **
                x = torch.randn(
                    observ.shape[0],
                    config.data.channels,
                    config.data.image_size,
                    config.data.image_size,
                    device=self.device,
                )
                with torch.no_grad():
                    x, _ = self.sample_image(x, model, H_funcs, observ, float(gamma), last=False, cls_fn=cls_fn, timesteps=timesteps)
                # ** save the DDRM restored image as .mat **
                savemat(os.path.join(args.image_folder, phaname, f"{idx_so_far + 1}_{-1}.mat"),
                        {'x': x[-1][0].detach().cpu().numpy()})

                idx_so_far += observ.shape[0]  # iterate multiple images
                print(f'Finish {idx_so_far}')

    def sample_image(self, x, model, H_funcs, y_0, gamma, last=False, cls_fn=None, classes=None, timesteps=50):
        skip = self.num_timesteps // timesteps
        seq = range(0, self.num_timesteps, skip)
        x = efficient_generalized_steps(x, seq, model, self.betas, H_funcs, y_0, gamma, etaB=self.args.etaB,
                                        etaA=self.args.eta, etaC=self.args.eta, cls_fn=cls_fn,
                                        classes=classes)
        if last:
            x = x[0][-1]
        return x
