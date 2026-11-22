{ config, lib, ... }:
let
  # Each name is a key in secrets/secrets.yaml and is exported as an env var.
  # To add one: `sops secrets/secrets.yaml`, add the key, add its name here, `hms`.
  envSecrets = [
    "OPENAI_API_KEY"
    "ANTHROPIC_API_KEY"
    "PERPLEXITY_API_KEY"
  ];
in
{
  sops = {
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/secrets.yaml;
    secrets = lib.genAttrs envSecrets (_: { });
  };

  programs.bash.initExtra = lib.mkBefore (lib.concatMapStrings (name: ''
    [ -r "${config.sops.secrets.${name}.path}" ] && export ${name}="$(<"${config.sops.secrets.${name}.path}")"
  '') envSecrets);
}
