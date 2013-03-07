base:
   'dc03scalitystr0*':
       - scality.repo
       - scality.ringsh
       - scality.sproxyd
       - scality.node
       - rsyslog
       - ntp
       - kernel
   'salt' :
       - scality.supervisor
   'dc03scalityfe*':
       - rsyslog-conn
       - scality.repo
       - scality.ringsh
       - scality.rest-connector
       - scality.sindexd
       - ntp
   'dc03scalitybck*':
       - rsyslog-conn
       - scality.repo
       - scality.ringsh
       - scality.rest-connector
       - scality.sindexd
       - ntp
