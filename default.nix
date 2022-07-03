self: super: {
  linuxPackages_latest = super.linuxPackages_latest.extend (lpself: lpsuper: {
      nvidia_x11 = super.linuxPackages_latest.nvidia_x11.overrideAttrs (oldAttrs: rec {
        src = /home/luis/Downloads/NVIDIA-Linux-x86_64-515.48.07.run;
        useGLVND = true;
      });
  })
}
