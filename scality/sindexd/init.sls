
# do not include this state directly, use either scality.sindexd.lighttpd or scality.sindexd.apache instead

include:
  - scality.req
  - scality.repo
  - scality.python

scality-sindexd:
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
      - file: scality-sindexd
  file:
    - managed
    - name: /etc/sindexd.conf
    - template: jinja
    - source: salt://scality/sindexd/sindexd.conf.tmpl
    - require:
      - pkg: python-scalitycs

