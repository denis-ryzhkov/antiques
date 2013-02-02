# -*- coding: utf-8 -*-

'''
Fabric extension
that introduces «env.is_local» flag, False by default,
that controls where «run, sudo, cd» are executed:
locally or on remote server.

This makes it easy and DRY to write tasks with standard «run, sudo, cd» API,
toggled to local mode from single «env.is_local = True» target-setting task:

Usage:
    from fabric.api import env
    from fabric_local_remote import run, sudo, cd
    
    def local():
        env.is_local = True
        ...
    
    def prod():
        ...
    
    def deploy():
        with cd(...):
            run(...)
            sudo(...)
    
    $ fab local deploy
    $ fab prod deploy

TODO: Give time for this code to mature, then submit it to fabric/contrib.

Copyright (C) 2011 by Denis Ryzhkov <denis@ryzhkov.org>
MIT License, see http://opensource.org/licenses/MIT
'''

__all__ = 'run sudo cd'.split()

from fabric.api import env
env.is_local = False # default

#### run

from fabric.api import run as remote_run, local as local_run
run = lambda command, capture=False: local_run(command, capture=capture) if env.is_local else remote_run(command)

#### sudo

from fabric.api import sudo as remote_sudo
local_sudo = lambda command, capture=False: local_run('sudo ' + command, capture=capture)
sudo = lambda command, capture=False: local_sudo(command, capture=capture) if env.is_local else remote_sudo(command)

#### cd

from fabric.api import cd as remote_cd, lcd as local_cd
from contextlib import contextmanager
cd = lambda path: (local_cd if env.is_local else remote_cd)(path)
