
#  mitsuba2-docker

A ready to run [mitsuba2](https://github.com/mitsuba-renderer/mitsuba2) docker image with installed:
- Optix 7
- CUDA 10.2
- Conda 
- Jupyter Lab 
- Mitsuba2

Enabled [variants](https://mitsuba2.readthedocs.io/en/latest/src/getting_started/variants.html):
* scalar_rgb
* scalar_spectral
* gpu_autodiff_spectral
* gpu_autodiff_rgb
* gpu_autodiff_mono

## Usage
Run it on any vast.ai, paperspace or other gpu instance.

1. Visit [vast.ai](https://vast.ai/console/create/) create an account and upload your ssh keys
2. Choose a sufficient machine (CUDA >10.2, more memory the better)
3. Create with the image `bonsaielectric/mitsuba2-docker:pathreparam-optix7` 
4. Connect `ssh -p <PORT> <USER>@<HOST> -L 8080:localhost:8080`
5. Lunch `jupyter lab --ip 0.0.0.0  --allow-root --port 8080`

Please bear in mind `bonsaielectric/mitsuba2-docker:pathreparam-optix7` might be out of date, but you should be able to use this dockerfile to build one for your use.