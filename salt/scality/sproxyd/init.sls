
sproxyd:
  pkg:
    - installed
    - names:
        - scality-ringsh
        - python-scalitycs
  service:
    - running
    - name: scality-sproxyd
    - watch:
      - file: sproxyd
      - file: /etc/httpd/conf/httpd.conf
      - file: /etc/httpd/conf.d/fastcgi.conf
  file:
    - managed
    - name: /etc/sproxyd.conf
    - template: jinja
    - source: {{pillar['sproxyd_conf_tmpl']|default('salt://scality/sproxyd/sproxyd.conf.tmpl')}}

/etc/httpd/conf/httpd.conf:
  file:
    - managed
    - source : salt://scality/sproxyd/httpd.conf
     
/etc/httpd/conf.d/fastcgi.conf:
  file:
    - managed
    - source : salt://scality/sproxyd/fastcgi.conf
