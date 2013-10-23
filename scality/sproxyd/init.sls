
# do not include this state directly, use either scality.sproxyd.lighttpd or scality.sproxyd.apache instead

include:
  - scality.req
  - scality.repo
  - scality.python

sproxyd:
  pkg:
    - installed
{%- if pillar['scality'] is defined and pillar['scality']['version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
{%- endif %}
    - name: scality-sproxyd
    - require:
      - pkgrepo: scality-repository
  service:
    - running
    - name: scality-sproxyd
    - watch:
      - file: sproxyd
  file:
    - managed
    - name: /etc/sproxyd.conf
    - template: jinja
    - source: salt://scality/sproxyd/sproxyd.conf.tmpl
    - require:
      - pkg: python-scalitycs

