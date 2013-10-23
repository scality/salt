include:
  - scality.req
  - scality.repo
  - scality.python

{% set http_frontend = salt['pillar.get']('scality:http_frontend', 'apache') %}

{%- if grains['os_family'] == 'RedHat' %}
mod_fastcgi:
  pkg.installed
{%- endif %}

sproxyd:
  pkg:
    - installed
{%- if pillar['scality'] is defined and pillar['scality']['version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
{%- endif %}
    - names:
{%- if http_frontend == 'lighttpd' %}
        - scality-sproxyd-lighttpd
{%- else %}
{%- if grains['os_family'] == 'Debian' %}
        - scality-sproxyd-apache2
{%- endif %}
{%- if grains['os_family'] == 'RedHat' %}
        - scality-sproxyd-httpd
{%- endif %}
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
    - source: salt://scality/sproxyd/sproxyd.conf.tmpl
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
    - require:
      - pkg: mod_fastcgi
{%- endif %}

