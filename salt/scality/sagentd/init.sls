include:
  - debconf

{%- if grains['os_family'] == 'Debian' %}
scality-sagentd-debconf:
  debconf.set:
    - name: scality-sagentd
    - data:
        scality-sagentd/supervisor-ip: {'type': 'string', 'value': {{pillar['supervisor_ip']}}}
    - require:
      - pkg: debconf-utils
{%- endif %}
scality-sagentd:
  pkg:
    - installed
{%- if grains['os_family'] == 'Debian' %}
    - require:
      - debconf: scality-sagentd-debconf
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

