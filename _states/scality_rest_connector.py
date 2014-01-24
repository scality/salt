'''
Created on 24 oct. 2013

@author: Christophe Vedel <christophe.vedel@scality.com>
'''

def listening(name,
              address,
              port=8184,
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

def added(name,
          ring,
          supervisor=None):
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
    
    if not __salt__['scality.ringsh_at_least']('4.2'):  # @UndefinedVariable
        ret['comment'] = 'Adding a rest connector to a ring is not supported by your version of ringsh/pyscality'
        ret['result'] = False
        return ret

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

def configured(name,
               ring,
               values,
               supervisor=None):
    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': 'RS2 connector configuration OK'}
    try:
        ret['changes'] = __salt__['scality.ov_configure'](name, supervisor, values, ring=ring, test=__opts__['test']) # @UndefinedVariable
        if len(ret['changes']) > 0:
            if __opts__['test']: # @UndefinedVariable
                ret['result'] = None
                ret['comment'] = 'RS2 connector configuration must be changed'
            else:
                ret['comment'] = 'RS2 connector configuration changed'
    except Exception, exc:
        ret['result'] = False
        ret['comment'] = repr(exc)
    return ret
