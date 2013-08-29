openssh:
  pkg.installed:
    {% if grains['os'] == 'RedHat' or grains['os'] == 'CentOS' %}
    - name: ssh
    {% elif grains['os'] == 'Debian' or grains['os'] == 'Ubuntu' %}
    - name: openssh
    {% endif %}

