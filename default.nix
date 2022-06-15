self: super: {
  nvidia_x11 = (super.nvidia_x11.override {}).overrideAttrs
    (oldAttrs: rec {
      pname = "nvidia";
      src = /home/luis/Downloads/NVIDIA-Linux-x86_64-515.48.07.run;
    });
}
