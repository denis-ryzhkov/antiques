#!/usr/bin/python
# -*- coding: utf-8 -*-

'''
xclip-sync-mcedit
automatically syncs in background
X clipboard and clipboard of mcedit
(internal editor of Midnight Commander)

usage:
    add to ~/.xinitrc:
        python ~/xclip-sync-mcedit.py &

require: xclip
version: 1.0 (2011-09-08)
    mc_fn patched (2012-03-13)
author: denis@ryzhkov.org
license: free
'''

from os import environ, stat
from os.path import join
from subprocess import Popen, PIPE
from time import sleep
from threading import Thread

x_cmd = 'xclip -selection clipboard'
mc_fn = join(environ['HOME'], '.local', 'share', 'mc', 'mcedit', 'mcedit.clip')
reaction_in_seconds = 1
last_text = None
can_continue = True

#### x_to_mc

def x_to_mc():
    global can_continue, last_text
    while can_continue:
    
        with Popen(x_cmd + ' -o', shell=True, stdout=PIPE).stdout as x_f:
            text = x_f.read()

        if last_text != text:
            last_text = text
            #print('x_to_mc', text)
            
            with open(mc_fn, 'w') as mc_f:
                mc_f.write(text)

        sleep(reaction_in_seconds)
        
#### mc_to_x

def mc_to_x():
    global can_continue, last_text
    last_mtime = None
    
    while can_continue:
        mtime = stat(mc_fn).st_mtime
        
        if last_mtime != mtime:
            last_mtime = mtime
            
            with open(mc_fn, 'r') as mc_f:
                text = mc_f.read()

            if last_text != text:
                last_text = text
                #print('mc_to_x', text)
                    
                with Popen(x_cmd + ' -i', shell=True, stdin=PIPE).stdin as x_f:
                    x_f.write(text)
    
        sleep(reaction_in_seconds)
    
#### main

for target in x_to_mc, mc_to_x:
    Thread(target=target).start()

try:
    while can_continue:
        sleep(60) # infinite
except:
    can_continue = False # signal for all threads to exit
    exit()
