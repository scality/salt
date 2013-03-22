base:
   'dc03scalitystr0*':
       - rsyslog
       - ntp
       - scality.repo
       - scality.ringsh
       - scality.sproxyd
       - scality.node
       - kernel
   'salt' :
       - scality.supervisor
   'dc03scalityfe*':
       - rsyslog
       - ntp
       - scality.repo
       - scality.ringsh
       - scality.rest-connector
       - scality.sindexd
   'dc03scalitybck*':
       - rsyslog
       - ntp
       - scality.repo
       - scality.ringsh
       - scality.rest-connector
       - scality.sindexd
