'''
Created on 17 juin 2013

@author: Christophe Vedel <christophe.vedel@scality.com>
'''

import logging
from scality_ov import _listening
from scality_ov import _generate_config_getter, _generate_config_setter, _configured

log = logging.getLogger(__name__)

def listening(name,
              address,
              port=8084,
              max_retry=20):
    return _listening(name, address, port, max_retry)

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
    getter = _generate_config_getter(name, ring)
    setter = _generate_config_setter(name, ring)
    return _configured(getter, setter, 'Node', name, supervisor, values)
