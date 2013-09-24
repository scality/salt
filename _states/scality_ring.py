'''
Created on 17 juin 2013

@author: Christophe Vedel <christophe.vedel@scality.com>
'''

def present(name, 
            supervisor = '127.0.0.1'):
    '''
    Ensure that a ring is created in the supervisor.
    
    name
        the name of the ring to manage
        
    supervisor
        the IP address or host name of the supervisor that manages this ring
        
    '''
    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': 'Ring {0} already exists at {1}'.format(name, supervisor)}
    if __salt__['scality.ring_exists'](name, supervisor):  # @UndefinedVariable
        return ret
   
    if __opts__['test']:  # @UndefinedVariable
        ret['result'] = None
        ret['comment'] = ('Ring {0} does not exists at {1} and needs to be created'
                ).format(name, supervisor)
        return ret
    
    if __salt__['scality.create_ring'](name, supervisor):  # @UndefinedVariable
        ret['comment'] = 'Ring {0} has been created at {1}'.format(name, supervisor)
        ret['changes'][name] = 'Present'
    else:
        ret['comment'] = 'Failed to create ring {0} at {1}'.format(name, supervisor)
        ret['result'] = False

    return ret

    
