"""
---STORY:

* Epic story of implementing multi-core merge-sort.

* I found that "merge" algorithm in Python is 30x slower
than "timsort" algorithm of C builtin "sorted(chain(*presorted_chunks))".

* This "timsort" is optimized for "almost-sorted" data,
so given pre-sorted chunks it executed 6x faster than initial "sorted(raw_data)"!

* However the process of splitting to chunks together with multiprocessing overhead
made "multicore_sorted()" still 2x slower than plain single-core builtin "sorted()".

* Then I got the next idea: "is "sorted()" a bottleneck, to start with?!".
* I added more profiling and found that "sorted()" was not a bottleneck AT ALL!

* (facepalm)

* So I freezed this "multicore_sorted" project until sorting really becomes a bottleneck:
https://github.com/denis-ryzhkov/antiques/tree/master/libs/python/multicore_sorted

---FROZEN:

Builtin "sorted()" function, but using all CPU cores available for speedup!

It supports all kwargs of "sorted()": "cmp", "key" and "reverse",
however items of "iterable" and all of these kwargs should be picklable:
https://docs.python.org/2/library/pickle.html#what-can-be-pickled-and-unpickled

Under the hood it uses map-reduce via "multiprocessing.Pool().map()" with builtin "sorted()"
and then merges sorted chunks as in merge-sort,
but note - with the same builtin "sorted()", as its "timsort" algorithm in C
works much faster than "merge" algorithm in Python,
and significantly faster than "sorted()" applied to raw data without pre-sorting of chunks.

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

multicore_sorted version 0.1.0  
Copyright (C) 2014 by Denis Ryzhkov <denisr@denisr.com>  
MIT License, see http://opensource.org/licenses/MIT  
"""
#### export

__all__ = ['multicore_sorted']

#### import

from itertools import chain
from multiprocessing import cpu_count, Pool

#### multicore_sorted

def multicore_sorted(iterable, **kwargs):

    #### processes

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

    pool = Pool(processes=processes) # No "maxtasksperchild" - the pool will be GC-ed after the sort.
    chunks = pool.map(picklable_sorted, chunks)
    result = sorted(chain(*chunks), **kwargs)

    return result

#### picklable_sorted

def picklable_sorted(chunk):
    # "Pool().map()" does not support additional kwargs like "key=lambda" for the "func".
    # Natural closure inside "multicore_sorted" is not picklable.
    # This is a picklable single-argument workaround.
    chunk, kwargs = chunk # Unpacking via efficient refs.
    #print((chunk, kwargs))
    return sorted(chunk, **kwargs)

#### tests

def cmp(a, b):
    return b - a

def key(a):
    return -a

def tests():
    from random import randint

    in_data = [randint(-100, 100) for _ in xrange(10**3)] # 10**6
    out_data = sorted(in_data)
    reversed_out_data = list(reversed(out_data))

    assert sorted(in_data) == out_data
    assert multicore_sorted(in_data) == out_data

    assert multicore_sorted(in_data) == sorted(in_data) == out_data

    assert multicore_sorted(in_data, cmp=cmp) == reversed_out_data
    assert multicore_sorted(in_data, key=key) == reversed_out_data
    assert multicore_sorted(in_data, reverse=True) == reversed_out_data

    assert multicore_sorted(in_data, cmp=cmp, key=key) == out_data
    assert multicore_sorted(in_data, cmp=cmp, reverse=True) == out_data
    assert multicore_sorted(in_data, key=key, reverse=True) == out_data

    assert multicore_sorted(in_data, cmp=cmp, key=key, reverse=True) == reversed_out_data

    print('OK')

if __name__ == '__main__':
    tests()
