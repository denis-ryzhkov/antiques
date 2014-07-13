"""
>>> DRAFT "py_merge"! <<<

Builtin "sorted()" function, but using all CPU cores available for speedup!

It supports all kwargs of "sorted()": "cmp", "key" and "reverse",
however items of "iterable" and all of these kwargs should be picklable:
https://docs.python.org/2/library/pickle.html#what-can-be-pickled-and-unpickled

Under the hood it uses map-reduce via "multiprocessing.Pool().map()" with builtin "sorted()"
and then merges sorted chunks as in merge-sort.
"processes" kwarg allows to set number of processes different from "cpu_count()".

Usage:

pip install multicore_sorted

cat <<END >test.py
from multicore_sorted import multicore_sorted

in_data = [1, 5, 2, 4, 3]
out_data = [1, 2, 3, 4, 5]

def cmp(a, b):
    return b - a

def key(a):
    return -a

if __name__ == '__main__':

    assert multicore_sorted(in_data) == sorted(in_data) == out_data
        # But N times faster, given Big data and N CPU cores!

    assert (
        multicore_sorted(in_data, cmp=cmp) ==
        multicore_sorted(in_data, key=key) ==
        multicore_sorted(in_data, reverse=True) ==
        list(reversed(out_data))
    )

    print('OK')
END
python test.py

drafts/py_merge/multicore_sorted version 0.1.0  
Copyright (C) 2014 by Denis Ryzhkov <denisr@denisr.com>  
MIT License, see http://opensource.org/licenses/MIT  
"""
#### export

__all__ = ['multicore_sorted']

#### import

from bn import Bn
from functools import cmp_to_key
from multiprocessing import cpu_count, Pool

#### multicore_sorted

def multicore_sorted(iterable, **kwargs):
    bn = Bn()

    #### processes
    bn('processes')

    processes = kwargs.pop('processes', None)
    if processes is None:
        try:
            processes = cpu_count() # Yes, "Pool()" does the same, but we need "processes" before calling "Pool()".
        except NotImplementedError:
            processes = 1

    if processes < 2:
        return sorted(iterable, **kwargs)
            # No need for multiprocessing if less than 2 processes!
            # It is tempting to do the same for small enough "len(iterable)",
            # but then the code below would be not efficient for generators having no "__len__".

    #### chunks
    bn('chunks')

    chunks = [[] for _ in xrange(processes)]
        # "[[]] * processes" would have created N links to the same list,
        # while we need separate lists.

    for i, item in enumerate(iterable): # Efficient even if "iterable" is a generator.
        chunks[i % processes].append(item) # Round-robin chunking.

    chunks = [ # Packing for "picklable_sorted" below.
        (chunk, kwargs) # "chunk" here is just a ref to one of big lists created above. So it is efficient.
        for chunk in chunks
    ]

    #### map-reduce

    bn('pool')
    pool = Pool(processes=processes) # No "maxtasksperchild" - the pool will be GC-ed after the sort.

    bn('map')
    chunks = pool.map(picklable_sorted, chunks)

    #bn('pool')
    #pool.close() # Test!

    #bn('merge_sorted')
    result = merge_sorted(chunks, **kwargs) # Alas "heapq.merge()" does not support "key=lambda", etc.

    #bn('test_import')
    #from itertools import chain
    #bn('test_timsort')
    #result = sorted(chain(*chunks), **kwargs)

    print(bn)
    return result

#### picklable_sorted

def picklable_sorted(chunk):
    # "Pool().map()" does not support additional kwargs like "key=lambda" for the "func".
    # Natural closure inside "multicore_sorted" is not picklable.
    # This is a picklable single-argument workaround.
    chunk, kwargs = chunk # Unpacking via efficient refs.
    #print((chunk, kwargs))
    return sorted(chunk, **kwargs)

#### merge_sorted

def merge_sorted(chunks, cmp=None, key=None, reverse=False):
    #bn = Bn()
    #bn('init')

    #### K - combined key.

    if cmp:
        cmp_key = cmp_to_key(cmp)
        K = (lambda a: cmp_key(key(a))) if key else cmp_key
    elif key:
        K = key
    else:
        K = lambda a: a
        # NOTE: "reverse" is processed below.

    #### init

    chunks = [iter(chunk) for chunk in chunks] # Prepare to fetch from each chunk.
    items = [chunk.next() for chunk in chunks] # Fetch first item from each chunk. Should be no empty chunks here.
    skip_me = object() # Unique marker.
    result = []

    while True:
        min_item = min_key = min_index = None

        #### Find "min".
        #bn('min')

        for chunk_index, item in enumerate(items): # Bultin "min()" does not fit, even with its "key" kwarg.
            if item is not skip_me and (
                min_index is None or # First not "skip_me" chunk becomes "min" chunk.
                not reverse and K(item) < min_key or # Default case "reverse=False" should be the first one.
                reverse and K(item) > min_key # Attempt to use "not <" would lead to extra computations below on "==".
            ):
                min_item = item
                min_key = K(item)
                min_index = chunk_index

        if min_index is None: # All chunks are "skip_me".
            break

        #bn('append')
        result.append(min_item)

        #### Fetch next item instead of "min".
        #bn('fetch')

        try:
            items[min_index] = chunks[min_index].next()
        except StopIteration:
            items[min_index] = skip_me

    #print(bn)
    return result

#### tests

def cmp(a, b):
    return b - a

def key(a):
    return -a

def tests():
    from random import randint

    in_data = [randint(-100, 100) for _ in xrange(4 * 10**6)]
    out_data = sorted(in_data)
    reversed_out_data = list(reversed(out_data))

    bn = Bn()
    bn('sorted')
    assert sorted(in_data) == out_data
    bn('multicore_sorted')
    assert multicore_sorted(in_data) == out_data
    print(bn)

    #"""
    assert multicore_sorted(in_data) == sorted(in_data) == out_data

    assert multicore_sorted(in_data, cmp=cmp) == reversed_out_data
    assert multicore_sorted(in_data, key=key) == reversed_out_data
    assert multicore_sorted(in_data, reverse=True) == reversed_out_data

    assert multicore_sorted(in_data, cmp=cmp, key=key) == out_data
    assert multicore_sorted(in_data, cmp=cmp, reverse=True) == out_data
    assert multicore_sorted(in_data, key=key, reverse=True) == out_data

    assert multicore_sorted(in_data, cmp=cmp, key=key, reverse=True) == reversed_out_data
    #"""

    print('OK')

if __name__ == '__main__':
    tests()
