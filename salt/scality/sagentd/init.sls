scality-sagentd:
{%- if grains['os_family'] == 'Debian' %}
  file:
    - managed
    - template: jinja
    - name: /tmp/sagentd.selections
    - source: salt://scality/sagentd/sagentd.selections
{%- endif %}
  pkg:
    - installed
{%- if grains['os_family'] == 'Debian' %}
    - debconf: file:///tmp/sagentd.selections
    - require:
        - file: /tmp/sagentd.selections
{%- endif %}
{%- if grains['os_family'] == 'RedHat' %}
  cmd.run:
    - name: /usr/local/bin/scality-sagentd-config -u {{ pillar['supervisor_ip'] }}
    - template: jinja
    - unless: grep -q {{ pillar['supervisor_ip'] }} /etc/sagentd.yaml
    - require:
      - pkg: scality-sagentd
{%- endif %}
  file:
    - exists
    - name: /etc/sagentd.yaml
    - require:
      - pkg: scality-sagentd
  service:
    - running
    - watch:
      - pkg: scality-sagentd
      - file: /etc/sagentd.yaml

