ntp:
  pkg.installed

{% set ntp_servers = salt['pillar.get']('scality:ntp:servers', ()) %}

{%- if ntp_servers %}
comment-existing-ntp-servers:
  file.comment:
    - name: /etc/ntp.conf
    - regex: ^(server[^#]*)$

add-new-ntp-servers:
  file.append:
    - name: /etc/ntp.conf
    - text:
{%- for ntp_server in ntp_servers %}
      - 'server {{ ntp_server }} # managed by Salt'
{%- endfor %}
    - require:
      - file: comment-existing-ntp-servers
{%- endif %}

ntpd:
  service.running:
{% if grains['os_family'] == 'Debian' or grains['os_family'] == 'Ubuntu' %}
    - name: ntp
{% elif grains['os_family'] == 'RedHat' or grains['os_family'] == 'CentOS' %}
    - name: ntpd
{% endif %}
    - enable: True
{%- if ntp_servers %}
      - file: add-new-ntp-servers
{%- endif %}
    - watch:
      - pkg: ntp
{%- if ntp_servers %}
      - file: add-new-ntp-servers
{%- endif %}
