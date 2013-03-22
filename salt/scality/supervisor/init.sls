include:
  - debconf

{%- if grains['os_family'] == 'Debian' %}
scality-supervisor-debconf:
  debconf.set:
    - name: scality-supervisor
    - data:
        scality-supervisor/accept-license: {'type': 'boolean', 'value': True}
    - require:
      - pkg: debconf-utils
{%- endif %}

scality-supervisor:
  pkg:
    - installed
{%- if grains['os_family'] == 'Debian' %}
    - require:
      - debconf: scality-supervisor-debconf
{%- endif %}
{%- if grains['os_family'] == 'RedHat' %}
  cmd.run:
    - name: echo "y\n" | /usr/local/bin/scality-supervisor-config 
    - template: jinja
    - unless: test -d /etc/scality-supervisor
    - require:
      - pkg: scality-supervisor
{%- endif %}
  service:
    - running
    - watch:
      - pkg: scality-supervisor


