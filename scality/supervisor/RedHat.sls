
include:
  - scality.repo

extend:
  scality-supervisor:
    cmd.run:
      - name: echo "y" | /usr/local/bin/scality-supervisor-config && sleep 5
      - template: jinja
      - unless: test -d /etc/scality-supervisor
      - env:
        - SCALITY_AUTH_FILE: /root/default_credentials.json
      - require:
        - pkg: scality-supervisor
        - file: /root/default_credentials.json
    service:
    - require:
      - cmd: scality-supervisor

