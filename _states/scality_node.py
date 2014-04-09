'''
Created on 17 juin 2013

@author: Christophe Vedel <christophe.vedel@scality.com>
'''

import logging

log = logging.getLogger(__name__)

def listening(name,
              address,
              port=8084,
              max_retry=20):
    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': 'Process is listening on {0}:{1}'.format(address, port)}
    result = __salt__['scality.check_process_listening'](address, port, max_retry) # @UndefinedVariable
    if result < 0:
        ret['result'] = False
        ret['comment'] = 'No process is listening on {0}:{1} ({2})'.format(address, port, -result)
    return ret

def noop(name,
          ring,
          supervisor=None):
    return {'name': name,
           'changes': {},
           'result': True,
           'comment': 'Assuming node belongs to ring {0}'.format(ring)}

def added(name,
          ring,
          supervisor=None):
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
           'comment': 'Node belongs to ring {0}'.format(ring)}
    
    current_ring = __salt__['scality.get_node_ring'](name, supervisor)  # @UndefinedVariable
    if ring == current_ring:  # @UndefinedVariable
        return ret
    
    if __opts__['test']:  # @UndefinedVariable
        msg = 'Node must be added to ring {0}'.format(ring)
        if current_ring:
            msg += ' (must be removed from ring {0} first)'.format(current_ring)
        ret['result'] = None
        ret['comment'] = msg
        return ret
    
    if not __salt__['scality.ringsh_at_least']('4.2'):  # @UndefinedVariable
        ret['comment'] = 'Adding a node to a ring is not supported by your version of ringsh/pyscality'
        ret['result'] = False
        return ret

    if current_ring:
        if not __salt__['scality.remove_node'](name, current_ring, supervisor):  # @UndefinedVariable
            ret['comment'] = 'Failed to remove node from ring {0}'.format(current_ring)
            ret['result'] = False
            return ret

    if __salt__['scality.add_node'](name, ring, supervisor):  # @UndefinedVariable
        if current_ring:
            ret['comment'] = 'Node has been moved from ring {1} to ring {0}'.format(ring, current_ring)
            ret['changes'][name] = 'Moved'
        else:
            ret['comment'] = 'Node has been added to ring {0}'.format(ring)
            ret['changes'][name] = 'Added'
    else:
        ret['comment'] = 'Failed to add node to ring {0}'.format(ring)
        ret['result'] = False

    return ret

def configured(name,
               ring,
               values,
               supervisor=None):
    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': 'Node configuration OK'}
    try:
        ret['changes'] = __salt__['scality.ov_configure'](name, supervisor, values, ring=ring, test=__opts__['test']) # @UndefinedVariable
        if len(ret['changes']) > 0:
            if __opts__['test']: # @UndefinedVariable
                ret['result'] = None
                ret['comment'] = 'Node configuration must be changed'
            else:
                ret['comment'] = 'Node configuration changed'
    except Exception, exc:
        ret['result'] = False
        ret['comment'] = repr(exc)
    return ret
