'''
Created on 17 juin 2013

@author: Christophe Vedel <christophe.vedel@scality.com>
'''

def present(name, 
            supervisor=None):
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
           'comment': 'Ring {0} already exists'.format(name)}

    if __salt__['scality.ring_exists'](name, supervisor):  # @UndefinedVariable
        return ret
   
    if __opts__['test']:  # @UndefinedVariable
        ret['result'] = None
        ret['comment'] = ('Ring {0} does not exists at {1} and needs to be created'
                ).format(name, supervisor)
        return ret

    if __salt__['scality.ringsh_at_least']('4.2'):  # @UndefinedVariable
        if __salt__['scality.create_ring'](name, supervisor):  # @UndefinedVariable
            ret['comment'] = 'Ring {0} has been created at {1}'.format(name, supervisor)
            ret['changes'][name] = 'Present'
        else:
            ret['comment'] = 'Failed to create ring {0} at {1}'.format(name, supervisor)
            ret['result'] = False
    else:
        ret['comment'] = 'The method to create a ring is not supported by your version of ringsh/pyscality'
        ret['result'] = False

    return ret

def configured(ring,
               values,
               supervisor=None):
    ret = {'name': ring,
           'changes': {},
           'result': True,
           'comment': 'Ring configuration OK'}

    current = __salt__['scality.get_ring_config'](ring, supervisor)  # @UndefinedVariable
    # check specified values and bail out early if one is unknown
    changes = {}
    for (key, value) in values.iteritems():
        try:
            if current[key] != str(value):
                ret['changes'][key] = '{0} -> {1}'.format(current[key], value)
                changes[key] = value
        except KeyError:
            ret['changes'] = {}
            ret['result'] = False
            ret['comment'] = 'Ring configuration value {0} is unknown'.format(key)
            return ret
    if len(changes) > 0:
        __salt__['scality.set_ring_config'](ring, changes, supervisor)  # @UndefinedVariable
        ret['comment'] = 'Ring configuration changed'
    return ret
    
