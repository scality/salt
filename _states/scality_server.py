'''
Created on 24 oct. 2013

@author: Christophe Vedel <christophe.vedel@scality.com>
'''

import logging

log = logging.getLogger(__name__)

def registered(name,
               address,
               supervisor=None,
               port=7084):
    '''
    Ensure that a server is registered with the given supervisor
    
    name
        the name of the server to register
        
    address
        the IP address of the server to register
        
    supervisor
        the IP address or host name of the supervisor to register with
            
    port
        the port to use to register the server (defaults to 7084/sagentd)
        
    '''
    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': 'Server {0} ({1}:{2}) is already registered'.format(name, address, port)}

    if not __salt__['scality.ringsh_at_least']('4.2'):  # @UndefinedVariable
        ret['comment'] = 'Server registration is not supported by your version of ringsh/pyscality'
        ret['result'] = False
        return ret

    servers = __salt__['scality.list_servers'](supervisor=supervisor)  # @UndefinedVariable
    matched = None
    for s in servers:
        match_name = s['name'] == name
        match_id = s['hostname'] == '{0}:{1}'.format(address, port)
        if match_name and match_id:
            return ret
        if match_name or match_id:
            matched = s

    if __opts__['test']:  # @UndefinedVariable
        msg = 'Server {0} ({1}:{2}) must be registered'.format(name, address, port)
        if matched:
            msg += ' ({0} ({1}:{2}) must be unregistered first)'.format(matched['name'], matched['ip'], matched['port'])
        ret['result'] = None
        ret['comment'] = msg
        return ret
    
    if matched:
        # remove the already registered server
        __salt__['scality.remove_server'](address, supervisor, port)  # @UndefinedVariable

    version = __salt__['scality.add_server'](name, address, supervisor, port)  # @UndefinedVariable
    if version:
        ret['comment'] = 'Server {0} ({1}:{2}) has been registered'.format(name, address, port)
        ret['changes'][name] = 'Registered (connected)'
        log.info('Supervisor connected to %s, reported version is %s' % (name, version))
    else:
        ret['comment'] = 'Failed to register server {0} ({1}:{2})'.format(name, address, port)
        ret['result'] = False
        
    return ret
    
