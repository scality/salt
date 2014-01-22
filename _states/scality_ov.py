'''
Created on 22 janv. 2014

@author: Christophe Vedel <christophe.vedel@scality.com>
'''

import socket
import time

def _listening(name,
              address,
              port,
              max_retry=20):

    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': 'Process is listening on {0}:{1}'.format(address, port)}

    retry = 0
    while retry < max_retry:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        result = s.connect_ex((address, port))

        if result == 0:
            s.close()
            break
        retry = retry + 1
        time.sleep(5)
    else:
        ret['result'] = False
        ret['comment'] = 'No process is listening on {0}:{1} ({2})'.format(address, port, result)
    return ret

def _generate_config_getter(name, ring):
    def get_config(supervisor):
        return __salt__['scality.get_config_by_name'](name, ring, supervisor)  # @UndefinedVariable
    return get_config

def _generate_config_setter(name, ring):
    def set_config(supervisor, module, values):
        return __salt__['scality.set_config_by_name'](name, ring, module, values, supervisor)  # @UndefinedVariable
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
        if __opts__['test']:  # @UndefinedVariable
            ret['result'] = None
            ret['comment'] = '{0} configuration must be changed'.format(otype)
        else:
            setter(supervisor, module, diff)  # @UndefinedVariable
            ret['comment'] = '{0} configuration changed'.format(otype)
    return ret

