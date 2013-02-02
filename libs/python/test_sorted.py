# -*- coding: utf-8 -*-

def test_sorted(items, tests):

    '''
    Returns items, sorted using tests:
        First group in result are items, that passed first test.
        Second group in result are items, that passed second test, and so on.
        Last group in result are items, that passed no tests.
    Sorting is stable: order inside each group is preserved as in original items.

    Usage:
        sorted_items = test_sorted(items, [
            lambda item: is_first(item),
            lambda item: is_second(item),
            ...
            lambda item: is_almost_last(item),
        ])
    '''

    def key(item):
        for index, test in enumerate(tests):
            if test(item):
                return index
        return len(tests)

    return sorted(items, key=key)
