self: super: {
  linuxPackages_5_15 = super.linuxPackages_5_15.extend (lpself: lpsuper: {
      nvidia_x11 = super.linuxPackages_5_15.nvidia_x11.overrideAttrs (oldAttrs: rec {
        src = /home/luis/Downloads/NVIDIA-Linux-x86_64-515.48.07.run;
        useGLVND = true;
      });
      nvidiaPackages = super.linuxPackages_5_15.nvidiaPackages.overrideAttrs (oldAttrs: rec {
        src = /home/luis/Downloads/NVIDIA-Linux-x86_64-515.48.07.run;
        useGLVND = true;
      });
  });
  linuxPackages = super.linuxPackages.extend (lpself: lpsuper: {
      nvidia_x11 = super.linuxPackages.nvidia_x11.overrideAttrs (oldAttrs: rec {
        src = /home/luis/Downloads/NVIDIA-Linux-x86_64-515.48.07.run;
        useGLVND = true;
      });
      nvidiaPackages = super.linuxPackages.nvidiaPackages.overrideAttrs (oldAttrs: rec {
        src = /home/luis/Downloads/NVIDIA-Linux-x86_64-515.48.07.run;
        useGLVND = true;
      });
  });
}
