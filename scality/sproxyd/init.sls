
# do not include this state directly, use either scality.sproxyd.lighttpd or scality.sproxyd.apache instead

include:
  - scality.req
  - scality.repo
  - scality.python
  - .log

{% from "scality/map.jinja" import scality with context %}

{%- set prod_ip = salt['network.ip_addrs'](interface=scality.prod_iface)[0] %}

scality-sproxyd:
  pkg:
{%- if pillar['scality'] is defined and pillar['scality']['version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
    - installed
{%- else %}
    - latest
{%- endif %}
    - require:
      - pkgrepo: scality-repository
  service:
    - running
    - enable: True
    - watch:
      - file: scality-sproxyd
  file:
    - managed
    - name: /etc/sproxyd.conf
    - template: jinja
    - source: salt://scality/sproxyd/sproxyd.conf.tmpl
    - require:
      - pkg: python-scalitycs
      - pkg: scality-sproxyd
  grains.present:
    - name: scality_sproxyd_address
    - value: {{ prod_ip }}:81

