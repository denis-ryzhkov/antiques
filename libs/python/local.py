#### local

import thread

data = {}
lock = thread.allocate_lock()

def local(namespace=None):

    '''
    Returns thread- and namespace- local instance.
    Advantages above threading.local():
        1. Preserves data on subsequent calls inside same thread.
        2. Namespaces are one honking great idea -- let's do more of those! (c) The Zen of Python, by Tim Peters.
    Advantages above paste.registry.StackedObjectProxy():
        1. Do not depends on paster registry-middleware, so can be used for modules deployed without pylons/paster.

    Usage:
        namespace = 'my.module.name' # can use any immutable object as namespace
        ...
        l = local(namespace)
        l.name = 'value'
        ...
        l = local(namespace)
        print(l.name) # 'value'

        l = local(__name__) # less control, but sometimes easier
    '''

    lock.acquire() # lock
    try:
        key = thread.get_ident(), namespace # light-weight immutable tuple as a dict key
        local_data = data.get(key, None) # fast success
        if local_data == None: # if first time
            class local_data(object): # create new empty class
                pass
            data[key] = local_data # save
        return local_data
    finally: # even after return
        lock.release() # unlock

