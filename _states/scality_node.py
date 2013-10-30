'''
Created on 17 juin 2013

@author: Christophe Vedel <christophe.vedel@scality.com>
'''

import logging

log = logging.getLogger(__name__)

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

def _generate_config_getter(name, ring):
    def get_config(supervisor):
        return __salt__['scality.get_config_by_name'](name, ring, supervisor)  # @UndefinedVariable
    return get_config

def _generate_config_setter(name, ring):
    def set_config(supervisor, module, values):
        return __salt__['scality.set_config_by_name'](name, ring, supervisor, module, values)  # @UndefinedVariable
    return set_config

def _configured(getter,
               setter,
               otype,
               name,
               supervisor,
               values):
    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': '{0} configuration OK'.format(otype)}

    current = getter(supervisor)  # @UndefinedVariable
    # check specified modules and bail out early if one is unknown
    for (module, set_values) in values.iteritems():
        if not current.has_key(module):
            ret['result'] = False
            ret['comment'] = '{0} configuration module {1} is unknown'.format(otype, module)
            return ret
    # check specified values and bail out early if one is unknown
    for (module, set_values) in values.iteritems():
        cur_values = current[module]
        for key in set_values.iterkeys():
            if not cur_values.has_key(key):
                ret['result'] = False
                ret['comment'] = '{0} configuration value {1}.{2} is unknown'.format(otype, module, key)
                return ret
    for (module, set_values) in values.iteritems():
        cur_values = current[module]
        diff = {}
        for (key, set_value) in set_values.iteritems():
            cur_value = cur_values.get(key, {'value': ''})['value']
            if cur_value != str(set_value):
                diff[key] = (cur_value, str(set_value))
        if len(diff) is 0: continue
        ret['changes'][module] = ', '.join(['%s: %s -> %s' % (key, v[0], v[1]) for key, v in diff.iteritems()])
        diff = dict((key, v[1]) for key, v in diff.iteritems())
        setter(supervisor, module, diff)  # @UndefinedVariable
        ret['comment'] = '{0} configuration changed'.format(otype)
    return ret

def configured(name,
               ring,
               supervisor,
               values):
    getter = _generate_config_getter(name, ring)
    setter = _generate_config_setter(name, ring)
    return _configured(getter, setter, 'Node', name, supervisor, values)
