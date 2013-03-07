include:
  - scality.sagentd

scality-rest-connector:
{%- if grains['os_family'] == 'Debian' %}
  file:
    - managed
    - template: jinja
    - name: /tmp/rest-connector.selections
    - source: salt://scality/rest-connector/rest-connector.selections
{%- endif %}
  pkg:
    - installed
    - require:
        - pkg: scality-sagentd
{%- if grains['os_family'] == 'Debian' %}
        - file: /tmp/rest-connector.selections
    - debconf: file:///tmp/rest-connector.selections
{%- endif %}
{%- if grains['os_family'] == 'RedHat' %}
  cmd.run:
    - name: echo -e "y\n" | /usr/local/bin/scality-rest-connector-config -m '{{ grains['id'] }}-c' -i {{ salt['network.ip_addrs']()[0] }} > /tmp/rinstall.log 2>&1
    - template: jinja
    - unless: test -d /etc/scality-rest-connector
    - require:
      - pkg: scality-rest-connector
{%- endif %}
  service:
    - enabled
#    - running
#    - enable: true
#    - watch:
#      - pkg: scality-rest-connector

scality-rest-connector-config:
  file:
    - managed
    - template: jinja
    - name: /tmp/rest-connector-conf.tmpl
    - source: salt://scality/rest-connector/conf.tmpl
  cmd.run:
    - watch:
      - file: /tmp/rest-connector-conf.tmpl
    - name: /usr/local/bin/ringsh -f /tmp/rest-connector-conf.tmpl
    #- name: cat /tmp/rest-connector-conf.tmpl
