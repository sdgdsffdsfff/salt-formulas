{%- from 'elasticsearch/settings.sls' import elasticsearch with context %}

tar:
  pkg.installed

unpack-elasticsearch-tarball:
  file.managed:
    - name: {{ elasticsearch.base }}/{{ elasticsearch.package }}
    - source: salt://elasticsearch/pkgs/{{ elasticsearch.package }}
    - saltenv: base
    - user: elasticsearch
    - group: elasticsearch
  cmd.run:
    - name: tar xf {{ elasticsearch.base }}/{{ elasticsearch.package }} -C {{ elasticsearch.base }}
    - user: elasticsearch
    - require:
      - pkg: tar
      - file: unpack-elasticsearch-tarball

elasticsearch_config:
  file.managed:
    - name: {{ elasticsearch.home }}/config/elasticsearch.yml
    - template: jinja
    - source: salt://elasticsearch/files/elasticsearch.yml
    - user: elasticsearch

unpack_service_tarball:
  file.managed:
    - name: {{ elasticsearch.base }}/service.tar.gz
    - source: salt://elasticsearch/pkgs/service.tar.gz
    - saltenv: base
    - user: elasticsearch
    - group: elasticsearch
  cmd.run:
    - name: tar xf {{ elasticsearch.base }}/service.tar.gz -C {{ elasticsearch.home }}/bin
    - user: elasticsearch
    - require:
      - pkg: tar
      - file: unpack_service_tarball

elasticsearch_service_config_add_xmod:
  file.managed:
    - name: {{ elasticsearch.home }}/bin/service/elasticsearch.conf
    - source: salt://elasticsearch/files/elasticsearch.conf
    - template: jinja
    - user: elasticsearch
    - require:
      - cmd: unpack_service_tarball
  cmd.run:
    - name: chmod +x *
    - cwd: {{ elasticsearch.home }}/bin/service/exec
    - user: elasticsearch
    - require:
      - file: elasticsearch_service_config_add_xmod

include:
  - elasticsearch.user