include:
  - .hosts
  - .kernel
  - .ntp
  - .rsyslog
  - .selinux.disabled
{%- if grains['os_family'] == 'Debian' %}
  - .debconf
{%- endif -%}

