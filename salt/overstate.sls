1generate:
    match: dc03scalitystr0*
    sls:
        - scality.sproxyd.sproxyd-genconf
2deploy:
    match: dc03scalitystr0*
    sls:
        - scality.sproxyd
    require:
        - 1generate
