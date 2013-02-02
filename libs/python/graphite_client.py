# -*- coding: utf-8 -*-

'''
    Direct client for Graphite Carbon server:
    
    * Unlike Galena: uses _UDP_ to fire and forget.
    * Unlike StatsD-clones: sends _exact_ metric value and timestamp.
    * Unlike all:
        * Accepts both UNIX timestamps and Python _«date/datetime»_ objects.
        * Allows to send _batch_ of metrics in one message
            to reduce network load and to improve performance even more.
    
    Integrates with Django settings GRAPHITE_HOST and GRAPHITE_PORT, if detected.
    
    Expects «ENABLE_UDP_LISTENER = True» in «/opt/graphite/carbon.conf»
    and relevant timestamp grid in «/opt/graphite/storage-schemas.conf».
    
    Usage:
        
        from graphite_client import graphite
        graphite.track('some.test.metric', 100)
        
        graphite.batch_track([
            ('first.metric', 100),
            ('second.metric', 200),
            ('third.metric', 300),
        ])
        
        # if not current timestamp:
            import time, datetime
            graphite.track('some.test.metric', 100, time.time())
            graphite.track('some.test.metric', 100, datetime.date.today())
            graphite.track('some.test.metric', 100, datetime.datetime.now())
        
        # if not default host-port:
            settings.py:
                GRAPHITE_HOST = '127.0.0.1'
                GRAPHITE_PORT = 2003
            main.py:
                graphite.track('some.test.metric', 100)
        # or:
            graphite.track('some.test.metric', 100, host='127.0.0.1', port=2003)
        # or:
            graphite.config(host='127.0.0.1', port=2003)
            graphite.track('some.test.metric', 100)
        # or:
            configured_graphite = graphite(host='127.0.0.1', port=2003)
            configured_graphite.track('some.test.metric', 100)
    
    graphite_client version 0.0.2
    Copyright (C) 2011 by Denis Ryzhkov <denis@ryzhkov.org>
    MIT License, see http://opensource.org/licenses/MIT
    
    TODO: wait for code to mature, then upload to PyPi.
'''

__all__ = ['graphite']

import socket
from time import time, mktime
from datetime import datetime, date

try:
    from django.conf import settings
except ImportError:
    settings = None

class graphite(object):
    
    socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
    host, port = None, None
    default_host = getattr(settings, 'GRAPHITE_HOST', '127.0.0.1')
    default_port = getattr(settings, 'GRAPHITE_PORT', '2003')
    
    @classmethod
    def config(cls, host=None, port=None):
        cls.host = host or cls.host
        cls.port = port or cls.port
    
    def __new__(cls, *args, **kwargs):
        # this client is intended to be used with zero config, with classmethods-s
        # so configured instance is just a subclass
        class configured_graphite(graphite): pass
        configured_graphite.config(*args, **kwargs)
        return configured_graphite
    
    @classmethod
    def track(cls, metric, value, timestamp=None, host=None, port=None):
        cls.batch_track([(metric, value)], timestamp=timestamp, host=host, port=port)
        
    @classmethod
    def batch_track(cls, metrics_values, timestamp=None, host=None, port=None):
        
        assert isinstance(timestamp, (int, float, long, date, datetime, type(None)))
        if not timestamp:
            timestamp = time()
        elif isinstance(timestamp, (date, datetime)):
            timestamp = mktime(timestamp.timetuple())
        
        message = ''
        for metric, value in metrics_values:
            message += '%s %d %d\n' % (metric, value, timestamp)
        
        destination = (
            host or cls.host or cls.default_host,
            port or cls.port or cls.default_port,
        )
        
        try:
            # UDP is connection-less, so we don't use cached «socket.connect»
            cls.socket.sendto(message, destination)
        except socket.error:
            pass # UDP, ignoring all network errors
