{% if grains['os_family'] == 'Debian' %}
debconf-utils:
  pkg.installed
{% endif %}
