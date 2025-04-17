{ pkgs, ... }:

let
  mkFishScript = name: path:
    pkgs.writeScriptBin name ''
      #!/usr/bin/env fish
      ${builtins.readFile path}
    '';

  mkPythonScript = name: path:
    pkgs.writers.writePython3Bin name
      {
        libraries = [
          pkgs.python312Packages.openai
          pkgs.python312Packages.pydantic
        ];
      }
      (builtins.readFile path);

in
{
  inherit mkFishScript mkPythonScript;
} 
