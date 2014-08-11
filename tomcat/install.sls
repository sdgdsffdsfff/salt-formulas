{%- from 'tomcat/settings.sls' import tomcat with context %}

include:
  - tomcat.env
  - tomcat.user

unpack-tomcat-tarball:
  file.managed:
    - name: {{ tomcat.home }}/{{ tomcat.package }}
    - source: salt://tomcat/pkgs/{{ tomcat.package }}
    - user: tomcat
    - group: tomcat
    - require:
      - user: tomcat-user
  cmd.run:
    - name: tar xf {{ tomcat.home }}/{{ tomcat.package }} -C {{ tomcat.home }}
    - user: tomcat
    - group: tomcat
    - require:
      - file: unpack-tomcat-tarball

symlink-tomcat:
  file.symlink:
    - name: {{ tomcat.home }}/{{ tomcat.name }}
    - target: {{ tomcat.home }}/{{ tomcat.versionPath }}
    - user: tomcat
    - group: tomcat
    - require:
      - cmd: unpack-tomcat-tarball
  cmd.run:
    - name: rm {{ tomcat.home }}/{{ tomcat.package }}
    - user: tomcat
    - group: tomcat
    - require:
      - cmd: unpack-tomcat-tarball

{% for dir in ['webapps', 'temp', 'LICENSE', 'NOTICE', 'RELEASE-NOTES', 'RUNNING.txt'] %}
delete-tomcat-{{ dir }}:
  file.absent:
    - name: {{ tomcat.home }}/{{ tomcat.name }}/{{ dir }}
{% endfor %}

delete-tomcat-users.xml:
  file.absent:
    - name: {{ tomcat.home }}/{{ tomcat.name }}/conf/tomcat-users.xml

copy-env.conf:
  file.managed:
    - name: {{ tomcat.home }}/{{ tomcat.name }}/conf/env.conf
    - source: salt://tomcat/files/env.conf
    - user: tomcat
    - group: tomcat
    - force: False
    - template: jinja
    - defaults:
      tomcatHome: {{ tomcat.home }}

{{ tomcat.home }}/{{ tomcat.name }}/bin/catalina.sh:
  file.blockreplace:
    - marker_start: "# ----- Execute The Requested Command -----"
    - marker_end: "# Bugzilla 37848"
    - content: CATALINA_OPTS=`sed 's/"//g' $CATALINA_BASE/conf/env.conf |awk '/^[^#]/'| tr "\n" ' '`


# move to os.security
# limits_conf:
#   file.append:
#     - name: /etc/security/limits.conf
#     - text:
#       - {{ tomcat.name }} soft nofile {{ tomcat.limitSoft }}
#       - {{ tomcat.name }} hard nofile {{ tomcat.limitHard }}
