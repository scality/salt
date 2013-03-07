vm.swappiness:
    sysctl:
      - present
      - value: 0

vm.min_free_kbytes:
    sysctl:
        - present
        - value: 2000000
