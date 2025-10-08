{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    kubectl
    minikube
    k9s
  ];
}
