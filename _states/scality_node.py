'''
Created on 17 juin 2013

@author: Christophe Vedel <christophe.vedel@scality.com>
'''

import logging
import time

log = logging.getLogger(__name__)

def registered(name,
               address,
               supervisor,
               port=7084):
    '''
    Ensure that a server is registered with its supervisor
    
    name
        the name of the server to register
        
    address
        the IP address of the server to register
        
    supervisor
        the IP address or host name of the supervisor to register with
            
    port
        the port to use to register the server (7084 is sagentd)
        
    '''
    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': 'Server {0} ({1}:{2}) is already registered with {3}'.format(name, address, port, supervisor)}
    servers = __salt__['scality.list_servers'](supervisor)  # @UndefinedVariable
    matched = None
    for s in servers:
        match_name = s['name'] == name
        match_id = s['hostname'] == '{0}:{1}'.format(address, port)
        if match_name and match_id:
            return ret
        if match_name or match_id:
            matched = s
    
    if __opts__['test']:  # @UndefinedVariable
        msg = 'Server {0} ({1}:{2}) must be registered with {3}'.format(name, address, port, supervisor)
        if matched:
            msg += ' ({0} ({1}:{2}) must be unregistered first)'.format(matched['name'], matched['ip'], matched['port'])
        ret['result'] = None
        ret['comment'] = msg
        return ret
    
    if matched:
        # remove the already registered server
        __salt__['scality.remove_server'](address, supervisor, port)  # @UndefinedVariable
        
    if __salt__['scality.add_server'](name, address, supervisor, port):  # @UndefinedVariable
        ret['comment'] = 'Server {0} ({1}:{2}) has been registered with {3}'.format(name, address, port, supervisor)
        ret['changes'][name] = 'Registered'
	retry = 0
	wait = 2
	while retry < 3:
	    time.sleep(wait)
	    servers = __salt__['scality.list_servers'](supervisor)
	    for server in servers:
                if server['name'] == name and len(server['version']) > 0:
		    ret['changes'][name] = 'Registered (connected)'
	            log.info('Supervisor connected to %s, reported version is %s' % (name, server['version']))
		    return ret
	    retry = retry  + 1
	    wait = wait * 2
	    log.warning('%s not found or not connected in server list: %s, waiting %d seconds' % (name, repr(servers), wait))
    else:
        ret['comment'] = 'Failed to register server {0} ({1}:{2}) with {3}'.format(name, address, port, supervisor)
        ret['result'] = False
        
    return ret
    
def added(name,
          ring,
          supervisor):   
    '''
    Ensure that a node is added to a ring
    
    name
        the name of the node to register (as defined in sagentd)
        
    ring
        the name of the ring

    supervisor
        the IP address or host name of the supervisor to register with            
        
    '''
    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': 'Node {0} already belongs to ring {1}'.format(name, ring)}
    
    current_ring = __salt__['scality.get_node_ring'](name, supervisor)  # @UndefinedVariable
    if ring == current_ring:  # @UndefinedVariable
        return ret
    
    if __opts__['test']:  # @UndefinedVariable
        msg = 'Node {0} must be added to ring {1}'.format(name, ring)
        if current_ring:
            msg += ' (must be removed from ring {0} first)'.format(current_ring)
        ret['result'] = None
        ret['comment'] = msg
        return ret
    
    if current_ring:
        if not __salt__['scality.remove_node'](name, current_ring, supervisor):  # @UndefinedVariable
            ret['comment'] = 'Failed to remove node {0} from ring {1}'.format(name, current_ring)
            ret['result'] = False
            return ret

    if __salt__['scality.add_node'](name, ring, supervisor):  # @UndefinedVariable
        if current_ring:
            ret['comment'] = 'Node {0} has been moved from ring {2} to ring {1}'.format(name, ring, current_ring)
            ret['changes'][name] = 'Moved'
        else:
            ret['comment'] = 'Node {0} has been added to ring {1}'.format(name, ring)
            ret['changes'][name] = 'Added'
    else:
        ret['comment'] = 'Failed to add node {0} to ring {1}'.format(name, ring)
        ret['result'] = False

    return ret
