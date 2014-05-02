
include:
  - scality.repo

extend:
  scality-supervisor:
    cmd.run:
      - name: echo "y" | /usr/local/bin/scality-supervisor-config && sleep 5
      - template: jinja
      - unless: test -d /etc/scality-supervisor
      - env:
        - SCALITY_AUTH_FILE: /tmp/scality-installer-credentials
      - require:
        - pkg: scality-supervisor
        - file: /tmp/scality-installer-credentials
    service:
    - require:
      - cmd: scality-supervisor

