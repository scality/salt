
# helper for all scality.s*d.apache states

# the managed httpd.conf is there:
# - to listen on port 81
# - to move User/Group definition before modules are included (fastcgi breaks if this is not the case)

{% from "scality/map.jinja" import scality with context %}

sd-apache-frontend:
  service.running:
    - name: {{ scality.apache_name }}
    - enable: True
{%- if grains['os_family'] == 'RedHat' %}
    - watch:
        - file: /etc/httpd/conf/httpd.conf
        - file: /etc/httpd/conf.d/fastcgi.conf
  file.managed:
    - name: /etc/httpd/conf/httpd.conf
    - source: salt://scality/sd/httpd.conf
{%- endif %}

# make sure Apache loads the fastcgi module
{%- if grains['os_family'] == 'RedHat' %}
sd-apache-fastcgi:
  file.uncomment:
    - name: /etc/httpd/conf.d/fastcgi.conf
    - regex: LoadModule
{%- endif %}

