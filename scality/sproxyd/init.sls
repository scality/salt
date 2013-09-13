include:
  - scality.req
  - scality.repo
  - scality.cs

sproxyd:
  pkg:
    - installed
{%- if pillar['scality:version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
{%- endif %}
    - names:
{%- if grains['os_family'] == 'Debian' %}
        - scality-sproxyd-apache2
{%- endif %}
{%- if grains['os_family'] == 'RedHat' %}
        - scality-sproxyd-httpd
{%- endif %}
    - require:
      - pkgrepo: scality-repository
  service:
    - running
    - name: scality-sproxyd
    - watch:
      - file: sproxyd
{%- if grains['os_family'] == 'RedHat' %}
      - file: /etc/httpd/conf/httpd.conf
      - file: /etc/httpd/conf.d/fastcgi.conf
{%- endif %}
  file:
    - managed
    - name: /etc/sproxyd.conf
    - template: jinja
    - source: {{ salt['pillar.get']('scality:sproxyd_conf_tmpl', 'salt://scality/sproxyd/sproxyd.conf.tmpl') }}
    - require:
      - pkg: python-scalitycs

{%- if grains['os_family'] == 'RedHat' %}
/etc/httpd/conf/httpd.conf:
  file:
    - managed
    - source : salt://scality/sproxyd/httpd.conf
     
/etc/httpd/conf.d/fastcgi.conf:
  file:
    - managed
    - source : salt://scality/sproxyd/fastcgi.conf
{%- endif %}

