let
  nixpkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/20.09-alpha.tar.gz";
    sha256 = "0dxrfr0w5ksvpjwz0d2hy7x7dirnc2xk9nw1np3wr6kvdlzhs3ik";
  }) { };
  jechol = import (fetchTarball {
    url = "https://github.com/jechol/nur-packages/archive/v2.1.tar.gz";
    sha256 = "17svxz3ycgniql54cf1gry8ias6cng3krzibb93nlk0b71rh3vki";
  }) { };
in nixpkgs.mkShell {
  buildInputs = [
    jechol.beam.main.erlangs.erlang_22_0
    jechol.beam.main.packages.erlang_22_0.elixirs.elixir_1_10_0
    nixpkgs.nodejs-14_x
    nixpkgs.ruby_2_7
    nixpkgs.rubyPackages_2_7.rubocop
    nixpkgs.rubyPackages_2_7.pry
    nixpkgs.python39
  ];
}
