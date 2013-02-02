
#### enum

def enum( *names ):
    
    '''
    Makes enum.
    Usage:
        E = enum( 'YOUR', 'KEYS', 'HERE' )
        print( E.HERE )
    '''

    class Enum():
        pass
    for index, name in enumerate( names ):
        setattr( Enum, name, index )
    return Enum

