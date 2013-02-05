'''
Dead-simple read-only @classproperty decorator.

classproperty version 0.0.1
Copyright (C) 2013 by Denis Ryzhkov <denisr@denisr.com>
MIT License, see http://opensource.org/licenses/MIT
'''

#### classproperty

class classproperty(object):

    def __init__(self, fget):
        self.fget = fget

    def __get__(self, owner_self, owner_cls):
        return self.fget(owner_cls)

#### test

def test():

    class C(object):

        @classproperty
        def x(cls):
            return 1

    assert C.x == 1
    assert C().x == 1

    print('OK')

if __name__ == '__main__':
    test()
