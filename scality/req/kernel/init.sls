
vm.swappiness:
    sysctl:
      - present
      - value: 0

# cap min_free_kbytes to 1/8 of the available memory to avoid freezing machines with not much RAM
{% set mem_total_8 = grains['mem_total'] * 128 %}
{% set min_free_kbytes = 2000000 if 2000000 < mem_total_8 else mem_total_8 %}

vm.min_free_kbytes:
    sysctl:
        - present
        - value: {{ min_free_kbytes|int }}

kernel.sem:
    sysctl:
        - present
        - value: 250  32000 32  256

