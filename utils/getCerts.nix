{ service, host }:

let
  base = ../certs;
  certName = [ "cert.pem" "key.pem" ];
  pathToServiceCerst =
    builtins.concatStringsSep "/" [ (toString base) service host ];
  certPem =
    map (name: builtins.concatStringsSep "/" [ pathToServiceCerst name ])
    certName;
in {
  cert = builtins.elemAt certPem 0;
  key = builtins.elemAt certPem 1;
}
