let
  nixpkgs = import
    (fetchTarball {
      url = "https://github.com/jechol/nixpkgs/archive/22.05-otp25-no-jit-elixir-1.14.tar.gz";
      sha256 = "sha256:0lpbrmmqfnn875mhmxbhl962jxjkar1dcq37mrmh8vb907f0l9pd";
    })
    { };
  platform =
    if nixpkgs.stdenv.isDarwin then [
      nixpkgs.darwin.apple_sdk.frameworks.CoreServices
      nixpkgs.darwin.apple_sdk.frameworks.Foundation
    ] else if nixpkgs.stdenv.isLinux then
      [ nixpkgs.inotify-tools ]
    else
      [ ];
in
nixpkgs.mkShell {
  buildInputs = with nixpkgs;
    [
      elixir_1_13
    ] ++ platform;
}
