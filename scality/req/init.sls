include:
  - .hosts
  - .credentials
  - .kernel
  - .ntp
  - .rsyslog
  - .logrotate
  - .selinux.disabled
{%- if grains['os_family'] == 'Debian' %}
  - .debconf
{%- endif -%}

