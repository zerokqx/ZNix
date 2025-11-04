{ ... }: {

  users.users.nixosvmtest = {
    extraGroups = [ "wheel" ];
    isSystemUser = false;
    isNormalUser = true;
    initialPassword = "1";
    group = "nixosvmtest";
  };
  users.groups.nixosvmtest = { };
  virtualisation.vmVariant.virtualisation = {
    memorySize = 2048;
    cores = 3;
  };
}
