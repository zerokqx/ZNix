{
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      # ── Изображения → Loupe ────────────────────────────────────────────
      "image/jpeg"                = [ "org.gnome.Loupe.desktop" ];
      "image/jpg"                 = [ "org.gnome.Loupe.desktop" ];
      "image/png"                 = [ "org.gnome.Loupe.desktop" ];
      "image/gif"                 = [ "org.gnome.Loupe.desktop" ];
      "image/webp"                = [ "org.gnome.Loupe.desktop" ];
      "image/avif"                = [ "org.gnome.Loupe.desktop" ];
      "image/tiff"                = [ "org.gnome.Loupe.desktop" ];
      "image/bmp"                 = [ "org.gnome.Loupe.desktop" ];
      "image/svg+xml"             = [ "org.gnome.Loupe.desktop" ];
      "image/heif"                = [ "org.gnome.Loupe.desktop" ];
      "image/heic"                = [ "org.gnome.Loupe.desktop" ];
      "image/x-portable-pixmap"   = [ "org.gnome.Loupe.desktop" ];
      "image/x-portable-bitmap"   = [ "org.gnome.Loupe.desktop" ];
      "image/x-portable-graymap"  = [ "org.gnome.Loupe.desktop" ];
      "image/x-bmp"               = [ "org.gnome.Loupe.desktop" ];
      "image/x-tga"               = [ "org.gnome.Loupe.desktop" ];
      "image/vnd.microsoft.icon"  = [ "org.gnome.Loupe.desktop" ];

      # ── Видео → Totem ──────────────────────────────────────────────────
      "video/mp4"                 = [ "org.gnome.Totem.desktop" ];
      "video/mkv"                 = [ "org.gnome.Totem.desktop" ];
      "video/x-matroska"          = [ "org.gnome.Totem.desktop" ];
      "video/webm"                = [ "org.gnome.Totem.desktop" ];
      "video/avi"                 = [ "org.gnome.Totem.desktop" ];
      "video/x-msvideo"           = [ "org.gnome.Totem.desktop" ];
      "video/quicktime"           = [ "org.gnome.Totem.desktop" ];
      "video/x-flv"               = [ "org.gnome.Totem.desktop" ];
      "video/mpeg"                = [ "org.gnome.Totem.desktop" ];
      "video/x-mpeg"              = [ "org.gnome.Totem.desktop" ];
      "video/3gpp"                = [ "org.gnome.Totem.desktop" ];
      "video/3gpp2"               = [ "org.gnome.Totem.desktop" ];
      "video/ogg"                 = [ "org.gnome.Totem.desktop" ];
      "video/x-ogm+ogg"           = [ "org.gnome.Totem.desktop" ];
      "video/x-theora+ogg"        = [ "org.gnome.Totem.desktop" ];
      "video/vnd.avi"             = [ "org.gnome.Totem.desktop" ];

      # ── Аудио → Totem ──────────────────────────────────────────────────
      "audio/mpeg"                = [ "org.gnome.Totem.desktop" ];
      "audio/mp3"                 = [ "org.gnome.Totem.desktop" ];
      "audio/ogg"                 = [ "org.gnome.Totem.desktop" ];
      "audio/flac"                = [ "org.gnome.Totem.desktop" ];
      "audio/x-flac"              = [ "org.gnome.Totem.desktop" ];
      "audio/wav"                 = [ "org.gnome.Totem.desktop" ];
      "audio/x-wav"               = [ "org.gnome.Totem.desktop" ];
      "audio/aac"                 = [ "org.gnome.Totem.desktop" ];
      "audio/mp4"                 = [ "org.gnome.Totem.desktop" ];
      "audio/x-m4a"               = [ "org.gnome.Totem.desktop" ];
      "audio/opus"                = [ "org.gnome.Totem.desktop" ];
      "audio/webm"                = [ "org.gnome.Totem.desktop" ];

      # ── Браузер → Firefox Nightly ───────────────────────────────────────
      "text/html"                 = [ "firefox-nightly.desktop" ];
      "application/xhtml+xml"     = [ "firefox-nightly.desktop" ];
      "application/xml"           = [ "firefox-nightly.desktop" ];
      "x-scheme-handler/http"     = [ "firefox-nightly.desktop" ];
      "x-scheme-handler/https"    = [ "firefox-nightly.desktop" ];
      "x-scheme-handler/about"    = [ "firefox-nightly.desktop" ];
      "x-scheme-handler/unknown"  = [ "firefox-nightly.desktop" ];

      # ── PDF → Zathura ──────────────────────────────────────────────────
      "application/pdf"           = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];

      # ── Документы → LibreOffice ────────────────────────────────────────
      "application/vnd.oasis.opendocument.text"                                   = [ "writer.desktop" ];
      "application/vnd.oasis.opendocument.spreadsheet"                            = [ "calc.desktop" ];
      "application/vnd.oasis.opendocument.presentation"                           = [ "impress.desktop" ];
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"   = [ "writer.desktop" ];
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"         = [ "calc.desktop" ];
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [ "impress.desktop" ];
      "application/msword"        = [ "writer.desktop" ];
      "application/vnd.ms-excel"  = [ "calc.desktop" ];
      "application/vnd.ms-powerpoint" = [ "impress.desktop" ];
      "application/rtf"           = [ "writer.desktop" ];
      "text/csv"                  = [ "calc.desktop" ];

      # ── Текст → Neovim ─────────────────────────────────────────────────
      "text/plain"                = [ "nvim.desktop" ];
    };

    associations.removed = {
      "application/pdf" = [ "writer.desktop" "libreoffice-writer.desktop" ];
    };
  };
}
