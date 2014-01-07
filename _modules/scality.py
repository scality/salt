'''
Scality Module

:depends:   - python-scalitycs convenience module
'''

# Import python libs
from collections import namedtuple
from salt.utils.decorators import depends
from salt.exceptions import CommandExecutionError
import logging
logger = logging.getLogger(__name__)
import yaml
from distutils.version import LooseVersion
import time

try:
    import scalitycs
except ImportError:
    pass

ringsh_version = LooseVersion('0.0')
try:
    import imp
    r = imp.load_source('r', '/usr/local/scality-ringsh/ringsh/r.py')
    ringsh_version = LooseVersion(r.RING_SVN_VERSION)
except:
    pass

INITIAL_DELAY = 2
MAX_RETRY = 7

#__outputter__ = {
#  'compactionstats': 'txt',
#  'tpstats': 'txt',
#  'netstats': 'txt',
#  'info': 'txt',
#  'ring': 'txt',
#}

def __virtual__():
    return 'scality'

def ringsh_at_least(version):
    return ringsh_version >= LooseVersion(version)

def conf_uses_json(package):
    version = __salt__['pillar.get']('scality:version') or __salt__['pkg.latest_version'](package) or __salt__['pkg.version'](package) # @UndefinedVariable
    if 'sfused' in package:
        return LooseVersion(version) > LooseVersion('4.2')
    else:
        return LooseVersion(version) > LooseVersion('4.3')

def _empty_string(*args, **kwargs):
    return ""

@depends('scalitycs', fallback_function=_empty_string)
def bootstrap_list(supervisor, ring, max_size=10):
    '''
    Return a bootstrap list for nodes of the specified ring.
    This list is suitable for insertion in a chord driver (sfused.conf, sproxyd.conf).

    CLI Example::

        salt '*' scality.bootstrap_list <supervisor> <ring>
        salt '*' scality.bootstrap_list <supervisor> <ring> <max_size>
    '''
    s = scalitycs.get_supervisor(supervisor)
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

def _format_num(num, maxv):
    return str(num).zfill(len(str(maxv)))

def nodes(ring=None):
    '''
    Iterate on all nodes or on nodes of the specified ring.
    '''
    Node = namedtuple('Node', ['name', 'ring', 'mgmt_port'])
    name_prefix = __salt__['pillar.get']('scality:name_prefix').split(',') # @UndefinedVariable
    nb_nodes = __salt__['pillar.get']('scality:nb_nodes') # @UndefinedVariable
    try:
        process_count = [int(v) for v in nb_nodes.split(',')]
    except AttributeError:
        process_count = [nb_nodes]
    rings = __salt__['pillar.get']('scality:rings').split(',') # @UndefinedVariable
    nodes = [ '%s%s' % (prefix, _format_num(num,count)) for prefix, count in zip(name_prefix, process_count) for num in range(1, count+1) ]
    ring_list = [ p for p, n in zip(rings, process_count)  for num in range(1, n+1)]
    mgmt_ports = [ 8084 + n for n in range(sum(process_count))]
    nodes_list = [ Node._make(x) for x in zip(nodes, ring_list, mgmt_ports)]
    for n in nodes_list:
            if not ring or n.ring is ring:
                    yield n

@depends('scalitycs')
def ring_exists(name, supervisor):
    '''
    '''
    s = scalitycs.get_supervisor(supervisor)
    return name in s.get_ring_list()
    
@depends('scalitycs')
def create_ring(name, supervisor):
    '''
    '''
    s = scalitycs.get_supervisor(supervisor)
    return s.create_ring(name)

@depends('scalitycs')
def delete_ring(name, supervisor):
    '''
    '''
    s = scalitycs.get_supervisor(supervisor)
    return s.delete_ring(name)

@depends('scalitycs')
def list_servers(supervisor=None, sfilter='.*'):
    """ serverList [regex]
    Display the list of servers and their current info
    You can filter the result according to the optional argument 'regex'
    """

    s = scalitycs.get_supervisor(supervisor)
    return s.list_servers(sfilter)

@depends('scalitycs')
def add_server(name, address, supervisor, port=7084, ssl=False, wait=True):
    """    serverAdd <name> <address> <cmpport> [<nossl>]
     Register a new server to this supervisor
    """
    s = scalitycs.get_supervisor(supervisor)
    try:
        if s.add_server(name, address, port, ssl):
            if wait:
                delay = INITIAL_DELAY
                retry = 0
                while retry < MAX_RETRY:
                    time.sleep(delay)
                    for x in s.list_servers(name):
                        if x['name'] == name and x['version']:
                            return x['version']
                    retry += 1
                    delay *= 2
                else:
                    return False
            return True
        else:
            return False
    except Exception, e:
        logger.error(str(e))
        return False

@depends('scalitycs')
def remove_server(address, supervisor, port=7084):
    """    serverAdd <name> <address> <cmpport> [<nossl>]
     Register a new server to this supervisor
    """
    s = scalitycs.get_supervisor(supervisor)
    try:
        return s.remove_server(address, port)
    except Exception, e:
        logger.error(str(e))
        return False

@depends('scalitycs')
def get_node_ring(name, supervisor):
    s = scalitycs.get_supervisor(supervisor)
    sagentd = yaml.load(open('/etc/sagentd.yaml', 'r'))
    for ring in s.get_ring_list():
        r = s.get_ring(ring)
        for n, value in sagentd['daemons'].iteritems():
            if name == n and r.has_node(value['address'], value['port']):
                return ring
    return None

@depends('scalitycs')
def ring_has_node(name, ring, supervisor):
    s = scalitycs.get_supervisor(supervisor)
    r = s.get_ring(ring)
    sagentd = yaml.load(open('/etc/sagentd.yaml', 'r'))
    for n, value in sagentd['daemons'].iteritems():
        if name == n:
            return r.has_node(value['address'], value['port'])
    return False
    
@depends('scalitycs')
def add_node(name, ring, supervisor, wait=True):
    s = scalitycs.get_supervisor(supervisor)
    sagentd = yaml.load(open('/etc/sagentd.yaml', 'r'))
    for n, value in sagentd['daemons'].iteritems():
        if name == n:
            s.add_node_to_ring(value['address'], value['port'], ring)
            if wait:
                r = s.get_ring(ring)
                delay = INITIAL_DELAY
                retry = 0
                while retry < MAX_RETRY:
                    time.sleep(delay)
                    if r.has_node(value['address'], value['port']): 
                        return True
                    retry += 1
                    delay *= 2
                else: return False
            return True
    return False

@depends('scalitycs')
def remove_node(name, ring, supervisor, wait=True):
    s = scalitycs.get_supervisor(supervisor)
    sagentd = yaml.load(open('/etc/sagentd.yaml', 'r'))
    for n, value in sagentd['daemons'].iteritems():
        if name == n:
            s.remove_node_from_ring(value['address'], value['port'], ring)
            if wait:
                r = s.get_ring(ring)
                delay = INITIAL_DELAY
                retry = 0
                while retry < MAX_RETRY:
                    time.sleep(delay)
                    if not r.has_node(value['address'], value['port']): 
                        return True
                    retry += 1
                    delay *= 2
                else: return False
            return True
    return False

@depends('scalitycs')
def get_rest_connector_ring(name, supervisor):
    s = scalitycs.get_supervisor(supervisor)
    sagentd = yaml.load(open('/etc/sagentd.yaml', 'r'))
    for ring in s.get_ring_list():
        r = s.get_ring(ring)
        for n, value in sagentd['daemons'].iteritems():
            if name == n and r.has_rest_connector(value['address'], value['port']):
                return ring
    return None

@depends('scalitycs')
def ring_has_rest_connector(name, ring, supervisor):
    s = scalitycs.get_supervisor(supervisor)
    r = s.get_ring(ring)
    sagentd = yaml.load(open('/etc/sagentd.yaml', 'r'))
    for n, value in sagentd['daemons'].iteritems():
        if name == n:
            return r.has_rest_connector(value['address'], value['port'])
    return False

@depends('scalitycs')
def add_rest_connector(name, ring, supervisor, wait=True):
    s = scalitycs.get_supervisor(supervisor)
    sagentd = yaml.load(open('/etc/sagentd.yaml', 'r'))
    for n, value in sagentd['daemons'].iteritems():
        if name == n:
            s.add_rest_connector_to_ring(value['address'], str(value['port']), ring)
            if wait:
                r = s.get_ring(ring)
                delay = INITIAL_DELAY
                retry = 0
                while retry < MAX_RETRY:
                    time.sleep(delay)
                    if r.has_rest_connector(value['address'], value['port']): 
                        return True
                    retry += 1
                    delay *= 2
                else: return False
            return True
    return False

@depends('scalitycs')
def remove_rest_connector(name, ring, supervisor, wait=True):
    s = scalitycs.get_supervisor(supervisor)
    sagentd = yaml.load(open('/etc/sagentd.yaml', 'r'))
    for n, value in sagentd['daemons'].iteritems():
        if name == n:
            s.remove_rest_connector_from_ring(value['address'], value['port'], ring)
            if wait:
                r = s.get_ring(ring)
                delay = INITIAL_DELAY
                retry = 0
                while retry < MAX_RETRY:
                    time.sleep(delay)
                    if not r.has_rest_connector(value['address'], value['port']): 
                        return True
                    retry += 1
                    delay *= 2
                else: return False
            return True
    return False

@depends('scalitycs')
def get_ring_config(ring, supervisor):
    s = scalitycs.get_supervisor(supervisor)
    status = s.supervisorConfigDso(action="view", dsoname=ring)
    return dict(status["params"])

@depends('scalitycs')
def set_ring_config(ring, supervisor, values):
    s = scalitycs.get_supervisor(supervisor)
    s.supervisorConfigDso(action="params", dsoname=ring, extra_params=values, doparse=False)

@depends('scalitycs')
def get_supervisor_config(supervisor, module=None):
    s = scalitycs.get_supervisor(supervisor)
    all_modules = s.configViewModule()
    if module:
        return all_modules.get(module, {})
    else:
        return all_modules

@depends('scalitycs')
def set_supervisor_config(supervisor, module, values):
    s = scalitycs.get_supervisor(supervisor)
    s.configUpdateModule(module, values)

@depends('scalitycs')
def get_config_by_name(name, ring, supervisor, module=None):
    s = scalitycs.get_supervisor(supervisor)
    r = s.get_ring(ring)
    o = r.by_name(name)
    if not o:
        raise ValueError('Could not find {0} in ring {1}'.format(name, ring))
    all_modules = o.configViewModule()
    if module:
        return all_modules.get(module, {})
    else:
        return all_modules

@depends('scalitycs')
def set_config_by_name(name, ring, supervisor, module, values):
    s = scalitycs.get_supervisor(supervisor)
    r = s.get_ring(ring)
    o = r.by_name(name)
    if not o:
        raise ValueError('Could not find {0} in ring {1}'.format(name, ring))
    o.configUpdateModule(module, values)

@depends('scalitycs')
def get_node_config(address, number, module=None):
    n = scalitycs.get_node(address, number)
    all_modules = n.configViewModule()
    if module:
        return all_modules.get(module, {})
    else:
        return all_modules

@depends('scalitycs')
def set_node_config(address, number, module, values):
    n = scalitycs.get_node(address, number)
    n.configUpdateModule(module, values)

