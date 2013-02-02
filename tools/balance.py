#!/usr/bin/python
# -*- coding: utf-8 -*-

'''
Money balance calculator.
Version: 3.2
Author: denis@ryzhkov.org .
License: free

Usage:
    python balance.py in.txt >out.txt

Feature example of "in.txt":

    #### setup

    # it is optional, we can change options in any time
    $u # default currency: USD
    -x # don't monitor currency eXchange account in balance

    #### 2010-12-31

    w 1000 i # work gave 1000 USD to me
    i 300 h # i spent 300 USD to pay rent for home
    i 400 x # i gave 500 USD to currency eXchange
    x 1200b i # eXchange gave 1200 kilo-BYR to me
    i 200b l # i put 200 kilo-BYR to "for Life" wallet part
    # this wallet part allows me to spend small sums without writing details
    # so balance shows this account as already spent
    i 200 bob # i gave 200 USD to my friend Bob

    #### 2011-01-15

    bob 150 i # Bob returned part of his debt
    -bob # don't monitor this account in balance for a while
    i 50b bob # i gave 50 kilo-BYR to bob without tracing this as debt in balance
    +bob # let's monitor this account again

Resulting balance in "out.txt":

    bob 50u # Bob still have debt of my 50 USD 
    h 300u # i spent 300 USD on rent for home
    i 950b # i have 950 kilo-BYR
    i 250u # i have 250 USD
    l 200b # i already spent 200 kilo-BYR for life
    w -1000u # work gave me 1000 USD in total for the time tracked
'''

#### import

import fileinput, re, sys

#### patterns

grab = lambda names: dict([(name, globals()[name]) for name in names.split(',')])

num = r'[0-9]+'
word = r'\w[\w\-\.]*'
comment = r'\s*(\#.*)?$'
patterns = grab('num,word,comment')

enable_monitor = r'\+(%(word)s)%(comment)s' % patterns
disable_monitor = r'\-(%(word)s)%(comment)s' % patterns
set_default_currency = r'\$(%(word)s)%(comment)s' % patterns
move_explicit_currency = r'(%(word)s)\s+(%(num)s)(%(word)s)\s+(%(word)s)%(comment)s' % patterns
move_default_currency = r'(%(word)s)\s+(%(num)s)\s+(%(word)s)%(comment)s' % patterns
patterns = grab('comment,enable_monitor,disable_monitor,set_default_currency,move_explicit_currency,move_default_currency')

for pattern_name, pattern in patterns.iteritems():
    #print(pattern_name, pattern)
    patterns[pattern_name] = re.compile(pattern)

#### current state

disabled_accounts = set()
default_currency = ''
balances = dict()

#### move

def move(from_account, quantity, currency, to_account):

    '''Moves some quantity of some currency from one account to another account.'''

    quantity = int(quantity)
    from_key = (from_account, currency)
    to_key = (to_account, currency)

    if from_account not in disabled_accounts:
        balances[from_key] = balances.get(from_key, 0) - quantity

    if to_account not in disabled_accounts:
        balances[to_key] = balances.get(to_key, 0) + quantity

#### in

for line in fileinput.input():
    line = line.strip()

    for pattern_name, pattern in patterns.iteritems():
        match = pattern.match(line)
        if match != None: break

    if match == None:
        sys.exit('Unsupported line format:\n%s\n' % line)
    
    elif pattern_name == 'enable_monitor':
        disabled_accounts.discard(match.group(1))
        #print('enable_monitor', match.group(1))
        #print('disabled_accounts', disabled_accounts)

    elif pattern_name == 'disable_monitor':
        disabled_accounts.add(match.group(1))
        #print('disable_monitor', match.group(1))
        #print('disabled_accounts', disabled_accounts)

    elif pattern_name == 'set_default_currency':
        default_currency = match.group(1)
        #print('set_default_currency', match.group(1))
        #print('default_currency', default_currency)

    elif pattern_name == 'move_explicit_currency':
        move(match.group(1), match.group(2), match.group(3), match.group(4))
        #print('move_explicit_currency', match.group(1), match.group(2), match.group(3), match.group(4))
        #print('balances', balances)

    elif pattern_name == 'move_default_currency':
        move(match.group(1), match.group(2), default_currency, match.group(3))
        #print('move_default_currency', match.group(1), match.group(2), match.group(3), match.group(4))
        #print('balances', balances)

    elif pattern_name == 'comment':
        pass # explicitly do nothing

    else:
        raise AssertionError('unknown pattern: %s' % pattern_name)

#### out

for account, currency in sorted(balances.keys()):
    balance = balances[(account, currency)]
    if balance:
        print('%s %s%s' % (account, balance, currency))
