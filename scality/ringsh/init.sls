
scality-ringsh:
  pkg:
    - installed
{%- if pillar['scality:version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
{%- endif %}
    - names:
        - scality-ringsh
    - require:
      - pkgrepo: scality-repository
  file:
    - managed
    - name: /usr/local/scality-ringsh/ringsh/config.py
    - template: jinja
    - source: salt://scality/ringsh/config.py

