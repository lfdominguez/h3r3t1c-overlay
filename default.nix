self: super: {
  
  nvidia_x11 = super.nvidia_x11.overrideAttrs
    (old: {
      src = /home/luis/Downloads/NVIDIA-Linux-x86_64-515.48.07.run;
    });
  "nvidia-x11-515.48.07-5.15.43" = super.nvidia_x11.overrideAttrs
    (old: {
      src = /home/luis/Downloads/NVIDIA-Linux-x86_64-515.48.07.run;
    });
  linuxPackages_5_15.nvidia_x11 = super.linuxPackages_5_15.nvidia_x11.overrideAttrs
    (oldAttrs: rec {
      src = /home/luis/Downloads/NVIDIA-Linux-x86_64-515.48.07.run;
      useGLVND = true;
    });
}
