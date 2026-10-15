{ pkgs, ... }:
{
  # Поддержка 32-битной графики для совместимости с 32-битными Windows-приложениями и играми
  hardware.graphics.enable32Bit = true;

  # Регистрация бинарного формата PE (.exe) в binfmt_misc:
  # позволяет запускать .exe напрямую как исполняемые файлы (например, `./app.exe`)
  boot.binfmt.registrations.wine = {
    recognitionType = "magic";
    magicOrExtension = "MZ";
    interpreter = "${pkgs.wineWow64Packages.waylandFull}/bin/wine";
  };

  # Пакеты для запуска и управления Windows-приложениями (.exe)
  environment.systemPackages = with pkgs; [
    # Wine 64-bit + 32-bit (WoW64) с полной поддержкой Wayland и X11, Gecko и Mono
    wineWow64Packages.waylandFull

    # Скрипт для доустановки необходимых библиотек Windows (DirectX, VC++ redist, шрифты и др.)
    winetricks

    # Быстрый и удобный GUI-лаунчер для запуска игр и сторонних .exe файлов
    # (поддерживает Wine-GE, Proton-GE, DXVK и загрузку раннеров в 1 клик)
    heroic

    # Утилиты, необходимые для GUI-диалогов и распаковки установщиков в Wine/Winetricks
    zenity
    cabextract
    p7zip
  ];
}
