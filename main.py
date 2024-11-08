import argparse
import traceback
import shutil
import logging
import yaml
import sys
import os
import torch
import numpy as np

from runners.diffusion import Diffusion

torch.set_printoptions(sci_mode=False)


def parse_args_and_config():
    parser = argparse.ArgumentParser(description=globals()["__doc__"])

    parser.add_argument(
        "--config", type=str, required=True, help="Path to the config file"
    )
    parser.add_argument(
        "--doc",
        type=str,
        required=True,
        help="the folder name of the current type of CKPTs",
    )
    parser.add_argument(
        "--ckpt",
        type=str,
        required=True,
        help="A name string of the diffusion model checkpoint. "
             "model006000.pt for DRUS/WDRUS(picmus), model000000.pt for HtH/CHtH(synthetic)",
    )
    parser.add_argument(
        "-i",
        "--image_folder",
        type=str,
        default="us",
        help="The folder name of samples",
    )
    parser.add_argument(
        "--deg", type=str, required=True,
        help="Degradation Model select from [DRUS || WDRUS || HtH || CHtH || DRUSdeno]",
    )
    # parser.add_argument(
    #     "--phaname", type=str, required=True,
    #     help="phantom name",
    # )
    parser.add_argument(
        "--timesteps", type=int, default=1000, help="number of steps involved"
    )
    # parser.add_argument(
    #     "--classIdx", type=int, required=True, help="0: positive || 1: signed"
    # )
    parser.add_argument(
        "--imgIdx", type=int, default=5, help="0--7"
    )
    parser.add_argument(
        "--nratio", type=float, default=0.002, help="~0.002--~0.008"
    )
    parser.add_argument(
        "--sigma", type=float, default=1.2, help="pdf kernal std"
    )
    # parser.add_argument(
    #     "--gamma", type=float, required=True, help="value of std(n)"
    # )
    parser.add_argument(
        "--norm_y0", type=float, default=1, help="The normalization factor of y_0"
    )

    parser.add_argument("--seed", type=int, default=1234, help="Random seed")
    parser.add_argument(
        "--exp", type=str, default="exp", help="Path for saving running related data."
    )
    parser.add_argument(
        "--matlab_path",
        type=str,
        required=True,
        help="MATLAB path where the measurements are stored"
    )
    parser.add_argument(
        "--comment", type=str, default="", help="A string for experiment comment"
    )
    parser.add_argument(
        "--verbose",
        type=str,
        default="info",
        help="Verbose level: info | debug | warning | critical",
    )
    parser.add_argument(
        "--sample",
        action="store_true",
        help="Whether to produce samples from the model",
    )
    parser.add_argument(
        "--ni",
        action="store_true",
        help="No interaction. Suitable for Slurm Job launcher",
    )
    # parser.add_argument(
    #     "--sigma_0", type=float, required=True, help="Sigma_0"
    # )
    parser.add_argument(
        "--eta", type=float, default=0.85, help="Eta"
    )
    parser.add_argument(
        "--etaB", type=float, default=1, help="Eta_b (before)"
    )
    parser.add_argument(
        '--subset_start', type=int, default=-1
    )
    parser.add_argument(
        '--subset_end', type=int, default=-1
    )

    args = parser.parse_args()
    args.log_path = os.path.join(args.exp, "logs", args.doc)

    # parse config file
    with open(os.path.join("configs", args.config), "r") as f:
        config = yaml.safe_load(f)
    new_config = dict2namespace(config)

    tb_path = os.path.join(args.exp, "tensorboard", args.doc)

    level = getattr(logging, args.verbose.upper(), None)
    if not isinstance(level, int):
        raise ValueError("level {} not supported".format(args.verbose))

    handler1 = logging.StreamHandler()
    formatter = logging.Formatter(
        "%(levelname)s - %(filename)s - %(asctime)s - %(message)s"
    )
    handler1.setFormatter(formatter)
    logger = logging.getLogger()
    logger.addHandler(handler1)
    logger.setLevel(level)

    os.makedirs(os.path.join(args.exp, "image_samples"), exist_ok=True)
    args.image_folder = os.path.join(
        args.exp, "image_samples", args.image_folder
    )
    if not os.path.exists(args.image_folder):
        os.makedirs(args.image_folder)
    else:
        overwrite = False
        if args.ni:
            overwrite = True
        # else:
        #     response = input(
        #         f"Image folder {args.image_folder} already exists. Overwrite? (Y/N)"
        #     )
        #     if response.upper() == "Y":
        #         overwrite = True

        if overwrite:
            shutil.rmtree(args.image_folder)
            os.makedirs(args.image_folder)
        else:
            print("Output image folder exists.")
            # print("Output image folder exists. Program halted.")
            # sys.exit(0)

    # add device
    device = torch.device("cuda") if torch.cuda.is_available() else torch.device("cpu")
    logging.info("Using device: {}".format(device))
    new_config.device = device

    # set random seed
    torch.manual_seed(args.seed)
    np.random.seed(args.seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed_all(args.seed)

    torch.backends.cudnn.benchmark = True

    return args, new_config


def dict2namespace(config):
    namespace = argparse.Namespace()
    for key, value in config.items():
        if isinstance(value, dict):
            new_value = dict2namespace(value)
        else:
            new_value = value
        setattr(namespace, key, new_value)
    return namespace


def main():
    args, config = parse_args_and_config()
    logging.info("Loading diffusion ckpt from folder {}".format(args.log_path))
    logging.info("Exp instance id = {}".format(os.getpid()))
    logging.info("Exp comment = {}".format(args.comment))

    try:
        runner = Diffusion(args, config)
        runner.sample()
    except Exception:
        logging.error(traceback.format_exc())

    return 0


if __name__ == "__main__":
    sys.exit(main())
