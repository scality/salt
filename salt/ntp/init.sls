ntp:
  pkg.installed

ntpd:
  service.running:
{% if grains['os_family'] == 'Debian' %}
    - name: ntp
{% endif %}
    - enable: True
    - require:
      - pkg: ntp
