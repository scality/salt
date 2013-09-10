include:
  - scality.cs

sproxyd:
  pkg:
    - installed
    - names:
{%- if grains['os_family'] == 'Debian' %}
        - scality-sproxyd
{%- endif %}
{%- if grains['os_family'] == 'RedHat' %}
        - scality-sproxyd-httpd
{%- endif %}
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
    - source: {{pillar['sproxyd_conf_tmpl']|default('salt://scality/sproxyd/sproxyd.conf.tmpl')}}
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

