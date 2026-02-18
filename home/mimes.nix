{
  xdg.mimeApps.defaultApplications = {
    "image/*" = [ "imv.desktop" ];
    "video/*" = [ "mpv.desktop" ];

    "text/html" = [ "firefox-nightly.desktop" ];
    "application/xhtml+xml" = [ "firefox-nightly.desktop" ];
    "application/xml" = [ "firefox-nightly.desktop" ];

    "x-scheme-handler/http" = [ "firefox-nightly.desktop" ];
    "x-scheme-handler/https" = [ "firefox-nightly.desktop" ];
    "x-scheme-handler/about" = [ "firefox-nightly.desktop" ];
    "x-scheme-handler/unknown" = [ "firefox-nightly.desktop" ];

    "application/pdf" = [
      "org.pwmt.zathura-pdf-mupdf.desktop"
      "writer.desktop"
    ];

    "application/vnd.oasis.opendocument.text" = [ "writer.desktop" ];
    "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ];
    "application/vnd.oasis.opendocument.presentation" = [ "impress.desktop" ];

    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ];
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "calc.desktop" ];
    "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [ "impress.desktop" ];

    "application/msword" = [ "writer.desktop" ];
    "application/vnd.ms-excel" = [ "calc.desktop" ];
    "application/vnd.ms-powerpoint" = [ "impress.desktop" ];

    "application/rtf" = [ "writer.desktop" ];
    "text/csv" = [ "calc.desktop" ];

    "text/plain" = [ "nvim.desktop" ];
  };
}
