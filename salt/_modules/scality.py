'''
Scality Module

:depends:   - python-scalitycs convenience module
'''

# Import python libs
from salt.exceptions import CommandExecutionError
import logging
logger = logging.getLogger(__name__)
import yaml

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
    return 'scality' if has_scalitycs else False



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

def ring_exists(name, supervisor):
    '''
    '''
    s = Supervisor('https://{0}:2443'.format(supervisor))
    return name in s.get_ring_list()
    
def create_ring(name, supervisor):
    '''
    '''
    s = Supervisor('https://{0}:2443'.format(supervisor))
    return s.create_ring(name)

def delete_ring(name, supervisor):
    '''
    '''
    s = Supervisor('https://{0}:2443'.format(supervisor))
    return s.delete_ring(name)

def list_servers(supervisor, sfilter='.*'):
    """ serverList [regex]
    Display the list of servers and their current info
    You can filter the result according to the optional argument 'regex'
    """

    s = Supervisor('https://{0}:2443'.format(supervisor))
    return s.list_servers(sfilter)

def add_server(name, address, supervisor, port=7084, ssl=False):
    """    serverAdd <name> <address> <cmpport> [<nossl>]
     Register a new server to this supervisor
    """
    s = Supervisor('https://{0}:2443'.format(supervisor))
    try:
        return s.add_server(name, address, port, ssl)
    except Exception, e:
        logger.error(str(e))
        return False

def remove_server(address, supervisor, port=7084):
    """    serverAdd <name> <address> <cmpport> [<nossl>]
     Register a new server to this supervisor
    """
    s = Supervisor('https://{0}:2443'.format(supervisor))
    try:
        return s.remove_server(address, port)
    except Exception, e:
        logger.error(str(e))
        return False

def get_node_ring(name, supervisor):
    s = Supervisor('https://{0}:2443'.format(supervisor))
    sagentd = yaml.load(open('/etc/sagentd.yaml', 'r'))
    for ring in s.get_ring_list():
        r = s.get_ring(ring)
        for n, value in sagentd['daemons'].iteritems():
            if name == n and r.has_node(value['address'], value['port']):
                return ring
    return None

def ring_has_node(name, ring, supervisor):
    s = Supervisor('https://{0}:2443'.format(supervisor))
    r = s.get_ring(ring)
    sagentd = yaml.load(open('/etc/sagentd.yaml', 'r'))
    for n, value in sagentd['daemons'].iteritems():
        if name == n:
            return r.has_node(value['address'], value['port'])
    return False
    
def add_node(name, ring, supervisor):
    s = Supervisor('https://{0}:2443'.format(supervisor))
    sagentd = yaml.load(open('/etc/sagentd.yaml', 'r'))
    for n, value in sagentd['daemons'].iteritems():
        if name == n:
            s.add_node_to_ring(value['address'], value['port'], ring)
            return True
    return False

def remove_node(name, ring, supervisor):
    s = Supervisor('https://{0}:2443'.format(supervisor))
    sagentd = yaml.load(open('/etc/sagentd.yaml', 'r'))
    for n, value in sagentd['daemons'].iteritems():
        if name == n:
            s.remove_node_from_ring(value['address'], value['port'], ring)
            return True
    return False


