'''
Created on 30 oct. 2013

@author: Christophe Vedel <christophe.vedel@scality.com>
'''

from scality_node import _configured

def _get_supervisor_config(supervisor):
    return __salt__['scality.get_supervisor_config'](supervisor)  # @UndefinedVariable

def _set_supervisor_config(supervisor, module, values):
    return __salt__['scality.set_supervisor_config'](supervisor, module, values)  # @UndefinedVariable

def configured(supervisor,
               values):
    return _configured(_get_supervisor_config, _set_supervisor_config, 'Supervisor', supervisor, supervisor, values)
