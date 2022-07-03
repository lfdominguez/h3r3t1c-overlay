self: super: {
  linuxkernel.packages.linux_5_15.nvidia_x11 = (super.linuxKernel.packages.linux_5_15.nvidia_x11.override {}).overrideAttrs
    (oldAttrs: rec {
      src = /home/luis/Downloads/NVIDIA-Linux-x86_64-515.48.07.run;
    });
}
