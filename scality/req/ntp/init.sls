ntp:
  pkg.installed

ntpd:
  service.running:
{% if grains['os_family'] == 'Debian' or grains['os_family'] == 'Ubuntu' %}
    - name: ntp
{% elif grains['os_family'] == 'RedHat' or grains['os_family'] == 'CentOS' %}
    - name: ntpd
{% endif %}
    - enable: True
    - require:
      - pkg: ntp
