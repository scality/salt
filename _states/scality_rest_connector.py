'''
Created on 24 oct. 2013

@author: Christophe Vedel <christophe.vedel@scality.com>
'''

import scality_node

 
def added(name,
          ring,
          supervisor):   
    '''
    Ensure that a rest connector is added to a ring
    
    name
        the name of the connector to register (as defined in sagentd)
        
    ring
        the name of the ring

    supervisor
        the IP address or host name of the supervisor to register with            
        
    '''
    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': 'RS2 connector belongs to ring {0}'.format(ring)}
    
    current_ring = __salt__['scality.get_rest_connector_ring'](name, supervisor)  # @UndefinedVariable
    if ring == current_ring:  # @UndefinedVariable
        return ret
    
    if __opts__['test']:  # @UndefinedVariable
        msg = 'RS2 connector must be added to ring {0}'.format(ring)
        if current_ring:
            msg += ' (must be removed from ring {0} first)'.format(current_ring)
        ret['result'] = None
        ret['comment'] = msg
        return ret
    
    if current_ring:
        if not __salt__['scality.remove_rest_connector'](name, current_ring, supervisor):  # @UndefinedVariable
            ret['comment'] = 'Failed to remove RS2 connector from ring {0}'.format(current_ring)
            ret['result'] = False
            return ret

    if __salt__['scality.add_rest_connector'](name, ring, supervisor):  # @UndefinedVariable
        if current_ring:
            ret['comment'] = 'RS2 connector has been moved from ring {1} to ring {0}'.format(ring, current_ring)
            ret['changes'][name] = 'Moved'
        else:
            ret['comment'] = 'RS2 connector has been added to ring {0}'.format(ring)
            ret['changes'][name] = 'Added'
    else:
        ret['comment'] = 'Failed to add RS2 connector to ring {0}'.format(ring)
        ret['result'] = False

    return ret

configured = scality_node.configured

