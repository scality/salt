'''
Scality Module

:depends:   - python-scalitycs convenience module
'''

# Import python libs
from salt.exceptions import CommandExecutionError
import logging
log = logging.getLogger(__name__)

has_scalitycs = False
try:
    from scalitycs import Supervisor
    has_scalitycs = True
except ImportError:
    pass

#__outputter__ = {
#  'compactionstats': 'txt',
#  'tpstats': 'txt',
#  'netstats': 'txt',
#  'info': 'txt',
#  'ring': 'txt',
#}

def __virtual__():
    '''
    Only load if scalitycs is available and the system is configured
    '''
    if not has_scalitycs:
        return False

    return 'scality'
    #host = __salt__['config.option']('cassandra.host')

    #if nt and host and thrift_port:
    #    return 'cassandra'
    #return False



def bootstrap_list(ring, max_size=10):
    '''
    Return a bootstrap list for nodes of the specified ring.
    This list is suitable for insertion in a chord driver (sfused.conf, sproxyd.conf).

    CLI Example::

        salt '*' scality.bootstrap_list <ring>
        salt '*' scality.bootstrap_list <ring> <max_size>
    '''
    s = Supervisor()
    if ring not in s.get_ring_list():
        msg = 'Ring {0} is not known by the supervisor'
        raise CommandExecutionError(msg.format(ring))
    try:
        max_size = int(max_size)
    except ValueError:
        msg = '{0} is not a valid value for max_size'
        raise CommandExecutionError(msg.format(max_size))

    # sort by chorport first to retain a maximum number of distinct servers
    addrs = sorted([(n['chordport'], n['ip']) for n in s.get_ring(ring).get_info()['nodes']])[0:max_size]

    return ','.join(['%s:%s' % (addr[1], addr[0]) for addr in addrs])

