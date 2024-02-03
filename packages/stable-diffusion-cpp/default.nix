{ lib
, cmake
, darwin
, fetchFromGitHub
, nix-update-script
, stdenv

, config
, cudaSupport ? config.cudaSupport
, cudaPackages ? { }

, rocmSupport ? config.rocmSupport
, rocmPackages ? { }

, blasSupport ? !rocmSupport && !cudaSupport
, openblas
, pkg-config
, metalSupport ? stdenv.isDarwin && stdenv.isAarch64
, patchelf
}:

let
  # It's necessary to consistently use backendStdenv when building with CUDA support,
  # otherwise we get libstdc++ errors downstream.
  # cuda imposes an upper bound on the gcc version, e.g. the latest gcc compatible with cudaPackages_11 is gcc11
  effectiveStdenv = if cudaSupport then cudaPackages.backendStdenv else stdenv;
in
effectiveStdenv.mkDerivation (finalAttrs: {
  pname = "stable-diffusion-cpp";
  version = "349439f239c4f5e27d414719ba8ac7340270ca6d";

  src = fetchFromGitHub {
    owner = "leejet";
    repo = "stable-diffusion.cpp";
    rev = "${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-ywxNHxHSMIqvSfo62TNyfLwAO55tDzrhVsedqnDiHPY=";
  };

  # postPatch = ''
  #   substituteInPlace ./ggml-metal.m \
  #     --replace '[bundle pathForResource:@"ggml-metal" ofType:@"metal"];' "@\"$out/bin/ggml-metal.metal\";"
  # '';

  nativeBuildInputs = [ cmake ] ++ lib.optionals blasSupport [ pkg-config ] ++ lib.optionals cudaSupport [
    cudaPackages.cuda_nvcc

    # TODO: Replace with autoAddDriverRunpath
    # once https://github.com/NixOS/nixpkgs/pull/275241 has been merged
    cudaPackages.autoAddOpenGLRunpathHook
  ];

  buildInputs = lib.optionals effectiveStdenv.isDarwin
    (with darwin.apple_sdk.frameworks; [
      Accelerate
      CoreGraphics
      CoreVideo
      Foundation
    ])
  ++ lib.optionals metalSupport (with darwin.apple_sdk.frameworks; [
    MetalKit
  ])
  ++ lib.optionals cudaSupport (with cudaPackages; [
    cuda_cccl.dev # <nv/target>

    # A temporary hack for reducing the closure size, remove once cudaPackages
    # have stopped using lndir: https://github.com/NixOS/nixpkgs/issues/271792
    cuda_cudart.dev
    cuda_cudart.lib
    cuda_cudart.static
    libcublas.dev
    libcublas.lib
    libcublas.static
  ]) ++ lib.optionals rocmSupport [
    rocmPackages.clr
    rocmPackages.hipblas
    rocmPackages.rocblas
  ] ++ lib.optionals blasSupport [
    openblas
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" false)
    (lib.cmakeBool "CMAKE_SKIP_BUILD_RPATH" true)
  ]
  ++ lib.optionals metalSupport [
    (lib.cmakeOptionType "STRING" "CMAKE_C_FLAGS" "-D__ARM_FEATURE_DOTPROD=1" )
    (lib.cmakeBool "SD_METAL" true)
    (lib.cmakeBool "SD_FLASH_ATTN" true)
  ]
  ++ lib.optionals cudaSupport [
    (lib.cmakeBool "DS_CUBLAS" true)
  ]
  ++ lib.optionals rocmSupport [
    (lib.cmakeBool "SD_HIPBLAS" true)
    (lib.cmakeOptionType "STRING" "CMAKE_C_COMPILER" "hipcc" )
    (lib.cmakeOptionType "STRING" "CMAKE_CXX_COMPILER" "hipcc" )
    (lib.cmakeBool "CMAKE_POSITION_INDEPENDENT_CODE" true)
    (lib.cmakeOptionType "STRING" "AMDGPU_TARGETS" "gfx1100" )
    (lib.cmakeBool "SD_FLASH_ATTN" true)
  ]
  ++ lib.optionals blasSupport [
    (lib.cmakeBool "GGML_OPENBLAS" true)
    (lib.cmakeBool "SD_FLASH_ATTN" true)
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    cp bin/sd $out/bin/sd

    ${lib.optionalString metalSupport "cp ./bin/ggml-metal.metal $out/bin/ggml-metal.metal"}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Stable Diffusion in pure C/C++";
    homepage = "https://github.com/leejet/stable-diffusion.cpp";
    license = licenses.mit;
    mainProgram = "sd";
    maintainers = with maintainers; [ lfdominguez ];
    broken = (effectiveStdenv.isDarwin && effectiveStdenv.isx86_64) || lib.count lib.id [blasSupport rocmSupport cudaSupport] == 0;
    platforms = platforms.unix;
  };
})