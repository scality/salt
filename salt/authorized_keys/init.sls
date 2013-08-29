AAAAB3NzaC1yc2EAAAADAQABAAABAQCxV+EoMmrWWtO4pFizUohbc2apZS2/nP809n4zt+Q7C//FcX99fSM8S4uWf0agLW/pgD2v4o+pzjBCLw0p286eHjV7sdrvkGFje37qiuf0/Q5/5khREWxK4U19k/c4B7JJ2RrVsRANX3OGsXdbN55lCk/VAdlZYaAQ+MzmCm/SNsWh3xoUQMz/rmKhCAQB/ZhTIiaAZGp9FPQprfUgOHep1Tzna0kotjEwgBo444IvdRl6gjh5YHA5cPBAjQkRhn+FBOg57jbZzhLI17ttAx6eQ4BaVeL+9vMk5UI98eUlJzLb+UPrRrPgm5NPiZOzQj3/F43KPeFKQqxo1FffjQDt:
  ssh_auth:
    - present
    - user: root
    - enc: ssh-rsa
    - comment: support@scality
    - config: .ssh/authorized_keys2

/root/.ssh/support-id_rsa.pub:
  file.managed:
    - name: /root/.ssh/support-id_rsa.pub
    - owner: root
    - group: root
    - mode: 0600
    - source: salt://authorized_keys/support-id_rsa.pub
