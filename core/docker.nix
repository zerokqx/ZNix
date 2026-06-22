{

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      # registry-mirrors = [
      #   "https://mirror.gcr.io" # Зеркало от Google (работает в РФ выборочно)
      #   "https://daocloud.io" # Известный китайский миррор
      #   "https://docker.m.daocloud.io"
      #   "https://cr.yandex/mirror" # Зеркало Яндекса (иногда требует авторизации, но базовые образы отдает)
      #   "https://huecker.io" # Популярное альтернативное зеркало для РФ
      #   "https://dockerhub.timeweb.cloud" # Зеркало от хостинга Timeweb
      # ];
      dns = [
        "1.1.1.1"
        "8.8.8.8"
      ];
    };
  };
}
