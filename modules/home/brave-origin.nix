{ pkgs, vimium, ... }:
let
  vimiumExtension = pkgs.runCommand "vimium-${vimium.shortRev}" { } ''
    mkdir -p "$out"
    cp -r ${vimium}/. "$out/"
    chmod u+w "$out/manifest.json"

    substituteInPlace "$out/manifest.json" \
      --replace-fail '"manifest_version": 3,' \
        '"manifest_version": 3, "key": "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCavizCZ9EnBGbtcRmMErcaxD2WUHJ9ME8IYGQhUBlFgIvchJjAO8koyak3AM95dqu3sOLdtIYD+75T82V1Wl5fLnHAeij2/IWL2VViTHeZhXZl1+rD9sRDaEYd7aZetpJ29+XXfhVphKArCCfwbYCtoJhTIr6S6DYsXuRevoV0EwIDAQAB",'
  '';
in
{
  programs.brave-origin = {
    enable = true;

    commandLineArgs = [ "--load-extension=${vimiumExtension}" ];
  };
}
