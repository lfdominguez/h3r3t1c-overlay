self: super: {
  nvidia_x11 = super.nvidia_x11.overrideAttrs
    (old: {
      src = /home/luis/Downloads/NVIDIA-Linux-x86_64-515.48.07.run;
    });
}