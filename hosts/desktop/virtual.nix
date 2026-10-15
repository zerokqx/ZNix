{ config, pkgs, ... }: {
  # Включение модуля libvirt / KVM
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu;
      runAsRoot = true;
      # Поддержка общих папок через virtiofs (опционально)
      vhostUserPackages = with pkgs; [ virtiofsd ];
    };
  };

  # Включение поддержки KVM в ядре
  boot.kernelModules = [
    "kvm-amd"
    "kvm-intel"
  ];

  # Добавление пользователя в группы для доступа к виртуализации
  users.groups.vmuser = {};
  users.users.vmuser = {
    # Указываем, что это обычный (не системный) пользователь
    isNormalUser = true;


    # Создаем и привязываем основную группу для этого пользователя
    group = "vmuser";

    # Добавляем в нужные группы для виртуализации (libvirtd, kvm)
    extraGroups = [
      "wheel"
      "libvirtd"
      "kvm"
    ];
  };

  # Установка GUI-утилиты управления и утилит QEMU
  environment.systemPackages = with pkgs; [
    virt-manager
    virtiofsd
    spice
    spice-gtk
    virt-viewer
  ];
}
