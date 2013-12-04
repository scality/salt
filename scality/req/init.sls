include:
  - .hosts
  - .kernel
  - .ntp
  - .rsyslog
  - .logrotate
  - .selinux.disabled
{%- if grains['os_family'] == 'Debian' %}
  - .debconf
{%- endif -%}

