'''
Created on 30 oct. 2013

@author: Christophe Vedel <christophe.vedel@scality.com>
'''

def listening(name,
              max_retry=20):
    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': 'Process is listening on 127.0.0.1:5580'}
    result = __salt__['scality.check_process_listening']('127.0.0.1', 5580, max_retry) # @UndefinedVariable
    if result < 0:
        ret['result'] = False
        ret['comment'] = 'No process is listening on {0}:{1} ({2})'.format('127.0.0.1', 5580, -result)
    return ret


def _get_supervisor_config(supervisor):
    return __salt__['scality.get_supervisor_config'](supervisor)  # @UndefinedVariable

def _set_supervisor_config(supervisor, module, values):
    return __salt__['scality.set_supervisor_config'](module, values, supervisor)  # @UndefinedVariable

def configured(name,
               values,
               supervisor=None):
    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': 'Supervisor configuration OK'}
    try:
        ret['changes'] = __salt__['scality.ov_configure'](name, supervisor, values, getter=_get_supervisor_config, setter=_set_supervisor_config, test=__opts__['test']) # @UndefinedVariable
        if len(ret['changes']) > 0:
            if __opts__['test']: # @UndefinedVariable
                ret['result'] = None
                ret['comment'] = 'Supervisor configuration must be changed'
            else:
                ret['comment'] = 'Supervisor configuration changed'
    except Exception, exc:
        ret['result'] = False
        ret['comment'] = repr(exc)
    return ret
