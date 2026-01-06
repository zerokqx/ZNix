{ pkgs, inputs, ... }:
{

  # =======================================================================
  # 📦 СИСТЕМНЫЕ ПАКЕТЫ
  # =======================================================================
  environment.systemPackages = with pkgs; [
    inputs.znvim.packages.${system}.default
    inputs.rofishot.packages.${system}.default
    nix-ld
    quickshell
    prismlauncher
    antigravity
    alacritty
    typescript # Для ваших React Typescript проектов
    dualsensectl
    nodejs_22 # Node.js
    pnpm # Менеджер пакетов
    git
    gcc # Компилятор
    sqlite
    vtsls

    google-chrome
    ncpamixer
    #
    # --- Терминальные Утилиты и Файловая Система ---
    btop # Монитор ресурсов
    eza # Современная замена 'ls'
    bat # Замена 'cat' с подсветкой синтаксиса
    ripgrep # Быстрый поиск (замена 'grep')
    fd # Простой поиск файлов (замена 'find')
    fzf # Интерактивный поиск
    yazi # Файловый менеджер
    tree # Просмотр дерева каталогов
    atool # Универсальная утилита для архивов
    unzip
    unrar
    p7zip

    chromium
    firefox-devedition # Браузер для разработки
    qbittorrent
    zathura # Просмотр PDF
    libreoffice
    obsidian # Для заметок (как программисту, вам пригодится!)
    steam

    # --- Мультимедиа и Сеть ---
    pipewire # Аудиосистема
    pulseaudio
    alsa-utils
    ffmpeg
    playerctl # Управление плеерами
    syncthing # Синхронизация файлов
    wget

    # --- Интерфейс и Окружение Sway/Wayland ---
    # Решает проблему Marksman!
    icu
    mako # Уведомления (Wayland)
    swaylock # Блокировщик экрана (Wayland)
    wl-clipboard # Буфер обмена (Wayland)
    cliphist # История буфера обмена (Wayland)
    libnotify # Отправка уведомлений
    polkit_gnome # Агент аутентификации
    xorg.libxkbfile # Зависимость для некоторых X-утилит
    xorg.xrandr # Для управления экранами
    xdg-utils # Открытие файлов через XDG

    # --- Bluetooth, GPG, Прочее ---
    bluez # Bluetooth-стек
    bluetuith # Консольный Bluetooth-менеджер
    gnupg
    gemini-cli # Клиент Gemini (консольный)
    virtualbox
    wf-recorder
    vscode

    freerdp
    nixd
    # --- Шрифты ---
    maple-mono.CN
    maple-mono."CN-unhinted"
    maple-mono.NF
    maple-mono."NF-CN"
    nerd-fonts._0xproto
    apple-cursor # Курсор
    rofi
    rofi-calc
    rofi-bluetooth

    prismlauncher
    rofi-power-menu
    rofi-network-manager
    bc
    # --- Интерфейс команд (для экспериментов, обычно не нужны в systemPackages) ---
    alacritty-theme
    impala
    bluetui
    interception-tools
    keybinder3
    ayugram-desktop
    insomnia
  ];

  # =======================================================================
  # 🐚 ОБОЛОЧКИ
  # =======================================================================
  environment.shells = with pkgs; [ fish ];

}
