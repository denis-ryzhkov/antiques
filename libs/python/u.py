# -*- coding: utf-8 -*-

def u(s):
    
    '''
    Returns unicode string from anything, with correct utf8 encoding expected instead of ascii.
    Waiting for Python3 with no unicode issues.
    '''
    
    if isinstance(s, unicode):
        return s
    
    if isinstance(s, str):
        return unicode(s, 'utf8')
    
    try:
        return unicode(s)
    
    except UnicodeError:
        try:
            return unicode(str(s), 'utf8')
        
        except UnicodeError:
            return unicode(repr(s), 'utf8')
