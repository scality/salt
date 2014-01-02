
/root/default_credentials.json:
  file.managed:
    - mode: 0600
    - source : salt://scality/req/credentials/default.json
