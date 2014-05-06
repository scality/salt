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
import socket
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

def _supervisor_from_pillar():
    return __salt__['pillar.get']('scality:supervisor_ip', '127.0.0.1') # @UndefinedVariable

def _production_ip_from_pillar():
    prod_iface = __salt__['pillar.get']('scality:prod_iface') # @UndefinedVariable
    if not prod_iface:
        raise CommandExecutionError('No address, pass it or set scality:prod_iface in the pillar')
    production_ip = __salt__['network.ip_addrs'](interface=prod_iface)[0] # @UndefinedVariable
    if not production_ip:
        raise CommandExecutionError('No address found for interface {0} defined in scality:prod_iface'.format(prod_iface))
    return production_ip

def _empty_string(*args, **kwargs):
    return ""

@depends('scalitycs', fallback_function=_empty_string)
def bootstrap_list(ring, max_size=10, supervisor=None):
    '''
    Return a bootstrap list for nodes of the specified ring.
    This list is suitable for insertion in a chord driver (in sfused.conf, sproxyd.conf)
    in opposition to an srest driver that requires sproxyd endpoints.

    CLI Example::

    .. code-block:: bash

        salt '*' scality.bootstrap_list <ring>
        salt '*' scality.bootstrap_list <ring> <max_size>
        salt '*' scality.bootstrap_list <ring> <max_size> supervisor=<supervisor>
    '''

    if not supervisor:
        supervisor = _supervisor_from_pillar()

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
    Node = namedtuple('Node', ['name', 'ring', 'mgmt_port', 'index'])
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
    nodes_list = [ Node._make(x) for x in zip(nodes, ring_list, mgmt_ports, range(1, len(nodes)+1))]
    for n in nodes_list:
        if not ring or n.ring == ring:
            yield n

@depends('scalitycs')
def ring_exists(name, supervisor=None):
    '''
    '''

    if not supervisor:
        supervisor = _supervisor_from_pillar()

    s = scalitycs.get_supervisor(supervisor)
    return name in s.get_ring_list()
    
@depends('scalitycs')
def create_ring(name, supervisor=None):
    '''
    '''

    if not supervisor:
        supervisor = _supervisor_from_pillar()

    s = scalitycs.get_supervisor(supervisor)
    return s.create_ring(name)

@depends('scalitycs')
def delete_ring(name, supervisor=None):
    '''
    '''

    if not supervisor:
        supervisor = _supervisor_from_pillar()

    s = scalitycs.get_supervisor(supervisor)
    return s.delete_ring(name)

@depends('scalitycs')
def list_servers(sfilter='.*', supervisor=None):
    """ serverList [regex]
    Display the list of servers and their current info
    You can filter the result according to the optional argument 'regex'
    """
    
    if not supervisor:
        supervisor = _supervisor_from_pillar()

    s = scalitycs.get_supervisor(supervisor)
    return s.list_servers(sfilter)

@depends('scalitycs')
def add_server(name, address, supervisor=None, port=7084, ssl=False, wait=True):
    """    serverAdd <name> <address> <cmpport> [<nossl>]
     Register a new server to this supervisor
    """
    if not supervisor:
        supervisor = _supervisor_from_pillar()

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
def remove_server(address, supervisor=None, port=7084):
    """    serverAdd <name> <address> <cmpport> [<nossl>]
     Register a new server to this supervisor
    """
    
    if not supervisor:
        supervisor = _supervisor_from_pillar()

    s = scalitycs.get_supervisor(supervisor)

    try:
        return s.remove_server(address, port)
    except Exception, e:
        logger.error(str(e))
        return False

@depends('scalitycs')
def get_node_ring(name, supervisor=None):

    if not supervisor:
        supervisor = _supervisor_from_pillar()

    s = scalitycs.get_supervisor(supervisor)
    sagentd = yaml.load(open('/etc/sagentd.yaml', 'r'))
    for ring in s.get_ring_list():
        r = s.get_ring(ring)
        for n, value in sagentd['daemons'].iteritems():
            if name == n and r.has_node(value['address'], value['port']):
                return ring
    return None

@depends('scalitycs')
def ring_has_node(name, ring, supervisor=None):
    if not supervisor:
        supervisor = _supervisor_from_pillar()

    s = scalitycs.get_supervisor(supervisor)
    r = s.get_ring(ring)
    sagentd = yaml.load(open('/etc/sagentd.yaml', 'r'))
    for n, value in sagentd['daemons'].iteritems():
        if name == n:
            return r.has_node(value['address'], value['port'])
    return False
    
@depends('scalitycs')
def add_node(name, ring, supervisor=None, wait=True):
    if not supervisor:
        supervisor = _supervisor_from_pillar()

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
def remove_node(name, ring, supervisor=None, wait=True):
    if not supervisor:
        supervisor = _supervisor_from_pillar()

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
def get_rest_connector_ring(name, supervisor=None):
    if not supervisor:
        supervisor = _supervisor_from_pillar()

    s = scalitycs.get_supervisor(supervisor)
    sagentd = yaml.load(open('/etc/sagentd.yaml', 'r'))
    for ring in s.get_ring_list():
        r = s.get_ring(ring)
        for n, value in sagentd['daemons'].iteritems():
            if name == n and r.has_rest_connector(value['address'], value['port']):
                return ring
    return None

@depends('scalitycs')
def ring_has_rest_connector(name, ring, supervisor=None):
    if not supervisor:
        supervisor = _supervisor_from_pillar()

    s = scalitycs.get_supervisor(supervisor)
    r = s.get_ring(ring)
    sagentd = yaml.load(open('/etc/sagentd.yaml', 'r'))
    for n, value in sagentd['daemons'].iteritems():
        if name == n:
            return r.has_rest_connector(value['address'], value['port'])
    return False

@depends('scalitycs')
def add_rest_connector(name, ring, supervisor=None, wait=True):
    if not supervisor:
        supervisor = _supervisor_from_pillar()

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
def remove_rest_connector(name, ring, supervisor=None, wait=True):
    if not supervisor:
        supervisor = _supervisor_from_pillar()

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
def get_ring_config(ring, supervisor=None):
    if not supervisor:
        supervisor = _supervisor_from_pillar()

    s = scalitycs.get_supervisor(supervisor)
    status = s.supervisorConfigDso(action="view", dsoname=ring)
    return dict(status["params"])

@depends('scalitycs')
def set_ring_config(ring, values, supervisor=None):
    if not supervisor:
        supervisor = _supervisor_from_pillar()

    s = scalitycs.get_supervisor(supervisor)
    s.supervisorConfigDso(action="params", dsoname=ring, extra_params=values, doparse=False)

@depends('scalitycs')
def get_supervisor_config(module=None, supervisor=None):
    if not supervisor:
        supervisor = _supervisor_from_pillar()

    s = scalitycs.get_supervisor(supervisor)
    all_modules = s.configViewModule()
    if module:
        return all_modules.get(module, {})
    else:
        return all_modules

@depends('scalitycs')
def set_supervisor_config(module, values, supervisor=None):
    if not supervisor:
        supervisor = _supervisor_from_pillar()

    s = scalitycs.get_supervisor(supervisor)
    s.configUpdateModule(module, values)

@depends('scalitycs')
def get_config_by_name(name, ring, module=None, supervisor=None):
    if not supervisor:
        supervisor = _supervisor_from_pillar()

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
def set_config_by_name(name, ring, module, values, supervisor=None):
    if not supervisor:
        supervisor = _supervisor_from_pillar()

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


@depends('scalitycs')
def wait_for_nodes_available(address=None,
              nb_nodes_expected=None,
              supervisor=None,
              max_retry=20):
    if not address:
        address = _production_ip_from_pillar()
    if not nb_nodes_expected:
        # by default, use the number of configured nodes
        nb_nodes = __salt__['pillar.get']('scality:nb_nodes') # @UndefinedVariable
        try:
            nb_nodes_expected = sum([int(v) for v in nb_nodes.split(',')])
        except AttributeError:
            nb_nodes_expected = nb_nodes
    if not supervisor:
        supervisor = _supervisor_from_pillar()
    s = scalitycs.get_supervisor(supervisor)
    rings = s.get_ring_list()
    delay = 30
    nb_try = 0
    while nb_try < max_retry:
        nb_nodes_available = 0
        for ring in rings:
            nodes = s.get_info(ring)['nodes']
            for node in nodes:
                states = node['state']
                if node['ip'] == address and ('RUN' in states or 'NEW' in states):
                    nb_nodes_available = nb_nodes_available + 1
        if nb_nodes_available == nb_nodes_expected:
            return True
        logger.info('Only {0} nodes out of {1} available, will check again in {2} seconds'.format(nb_nodes_available, nb_nodes_expected, delay))
        time.sleep(delay)
        delay = delay * 2
        nb_try = nb_try + 1
    return False

def generate_config_getter(name, ring):
    def get_config(supervisor):
        return get_config_by_name(name, ring, supervisor)
    return get_config

def generate_config_setter(name, ring):
    def set_config(supervisor, module, values):
        return set_config_by_name(name, ring, module, values, supervisor)
    return set_config

@depends('scalitycs')
def ov_configure(name,
                 supervisor,
                 values,
                 getter=None,
                 setter=None,
                 ring=None,
                 test=False):

    if not getter:
        if not ring:
            raise CommandExecutionError('Either getter or ring must be specified')
        getter = generate_config_getter(name, ring)
    if not setter:
        if not ring:
            raise CommandExecutionError('Either setter or ring must be specified')
        setter = generate_config_setter(name, ring)
    current = getter(supervisor)
    # check specified modules and bail out early if one is unknown
    for (module, set_values) in values.iteritems():
        if not current.has_key(module):
            raise CommandExecutionError('Configuration module {0} is unknown'.format(module))
    # check specified values and bail out early if one is unknown
    for (module, set_values) in values.iteritems():
        cur_values = current[module]
        for key in set_values.iterkeys():
            if not cur_values.has_key(key):
                raise CommandExecutionError('Configuration value {0}.{1} is unknown'.format(module, key))
    changes = {}
    for (module, set_values) in values.iteritems():
        cur_values = current[module]
        diff = {}
        for (key, set_value) in set_values.iteritems():
            cur_value = cur_values.get(key, {'value': ''})['value']
            if cur_value != str(set_value):
                diff[key] = (cur_value, str(set_value))
        if len(diff) is 0: continue
        changes[module] = ', '.join(['%s: %s -> %s' % (key, v[0], v[1]) for key, v in diff.iteritems()])
        diff = dict((key, v[1]) for key, v in diff.iteritems())
        if not test:
            setter(supervisor, module, diff)
    return changes

def check_process_listening(address,
              port,
              max_retry=20):

    retry = 0
    result = 0
    while retry < max_retry:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        result = s.connect_ex((address, port))

        if result == 0:
            s.close()
            break
        retry = retry + 1
        time.sleep(5)
    else:
        return -result
    return 0

