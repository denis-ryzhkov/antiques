# -*- coding: utf-8 -*-

'''
module: async_time_test
author: denis@ryzhkov.org
license: free

See «async_time_test.async_time_test» docstring.
'''

__all__ = [
    'async_time_test',
]

__version__ = '0.4'

#### async_time_test

def async_time_test(actions_args=[], actions_per_second=1, action_time_limit_in_seconds=1, test_time_in_seconds=60, async=True):

    '''
    «async_time_test» is a tool for highload testing of asynchronous actions,
    that must be completed successfully in some time limit.

    Usage:
        def action1():
            do_some_payload1()

        def action2():
            do_some_payload2()

        for async in False, True: # to compare stats
            stats = async_time_test(
                actions_args=[
                    dict(action=action1, actions_per_second=10),
                    dict(action=action2, actions_per_second=20),
                ],
                action_time_limit_in_seconds=1,
                test_time_in_seconds=60,
                async=async,
            )
                # «action*» args can be passed per-action or per-test

            from json import dumps
            print(dumps(stats, indent=4))
                # actions_count: {
                #   total: 1800,
                #   successful: 1000,
                #   failed: {
                #       total: 800,
                #       crashed: 10,
                #       timedout: 790,
                # }},
                # action_time_in_seconds: {
                #   min: 0.01,
                #   avg: 2,
                #   max: 30,
                # },
                # test_time_in_seconds: {
                #   expected: 60,
                #   real: 69,
                # },
                # async: False/True,
    '''

    #### import
    
    from time import sleep
    from time import time as clock # WARNING: seems like «clock» is spoiled by multi-threading on Debian
    from threading import current_thread, Lock, Thread

    #### actions_args init

    for action_args in actions_args:
        
        for arg in 'actions_per_second', 'action_time_limit_in_seconds':
            action_args[arg] = action_args.get(arg, locals().get(arg, None)) # DRY combination of per-action args with per-test args and defaults
        
        action_args['total_actions_count'] = int(test_time_in_seconds * action_args['actions_per_second'])

    #### stats init

    lock = Lock() # locks update of next values:
    stats = dict(
        actions_count=dict(
            total=sum(action_args['total_actions_count'] for action_args in actions_args),
            successful=0,
            failed=dict(
                total=0,
                crashed=0,
                timedout=0,
            ),
        ),
        action_time_in_seconds=dict(
            min=None,
            avg=None,
            max=None,
        ),
        action_time_in_seconds_temporary_list=[],
        test_time_in_seconds=dict(
            expected=test_time_in_seconds,
            real=None,
        ),
        async=async,
    )

    #### single_runner

    def single_runner(stats, action, action_time_limit_in_seconds):
        is_crashed = False

        start = clock()
        try:

            action()

        except:
            is_crashed = True
            from traceback import print_exc
            print_exc()

        stop = clock()
        action_time_in_seconds = stop - start

        with lock:
            stats['action_time_in_seconds_temporary_list'].append(action_time_in_seconds)
            failed_stats = stats['actions_count']['failed']

            if is_crashed:
                failed_stats['crashed'] += 1
                failed_stats['total'] += 1

            elif action_time_in_seconds > action_time_limit_in_seconds:
                failed_stats['timedout'] += 1
                failed_stats['total'] += 1

            else:
                stats['actions_count']['successful'] += 1

    #### group_runner

    def group_runner(stats, action, total_actions_count, actions_per_second, action_time_limit_in_seconds):
        single_threads = []

        for single_index in range(total_actions_count):
            sleep(1.0 / actions_per_second)
            
            single_thread = Thread(target=single_runner, args=(stats, action, action_time_limit_in_seconds))
            single_thread.start()

            if async:
                single_threads.append(single_thread)
            else:
                single_thread.join()

        if async:
            for single_thread in single_threads:
                single_thread.join()

    group_threads = [
        Thread(target=group_runner, args=(stats, ), kwargs=action_args)
        for action_args in actions_args
    ]

    #### main thread

    start = clock()

    for group_thread in group_threads:
        group_thread.start()
        if not async:
            group_thread.join()

    if async:
        for group_thread in group_threads:
            group_thread.join()

    stop = clock()
    stats['test_time_in_seconds']['real'] = stop - start

    #### process action-time-stats

    time_list = stats['action_time_in_seconds_temporary_list']
    if time_list:
        time_stats = stats['action_time_in_seconds']
        time_stats['min'] = min(time_list)
        time_stats['avg'] = sum(time_list) / len(time_list)
        time_stats['max'] = max(time_list)
    del stats['action_time_in_seconds_temporary_list']

    #### return

    return stats

#### minimal tests

def run_tests():

    #### prepare

    from json import dumps
    from random import randrange
    from time import sleep

    def payload(deviation=0):

        one_second_factor = 10
        sleep(float(randrange(
            one_second_factor - deviation,
            one_second_factor + deviation,
        )) / one_second_factor)

        if not randrange(10):
            1/0

    def action1():
        payload(deviation=1)

    def action2():
        payload(deviation=2)

    actions1_per_second = 10
    actions2_per_second = 20
    action_time_limit_in_seconds = 1
    test_time_in_seconds = 1

    #### run

    for async in False, True: # to compare stats

        stats = async_time_test(
            actions_args=[
                dict(action=action1, actions_per_second=actions1_per_second),
                dict(action=action2, actions_per_second=actions2_per_second),
            ],
            action_time_limit_in_seconds=action_time_limit_in_seconds,
            test_time_in_seconds=test_time_in_seconds,
            async=async,
        )

        print(dumps(stats, indent=4))

    #### assert

    count_stats = stats['actions_count']
    assert count_stats['total'] == (actions1_per_second + actions2_per_second) * test_time_in_seconds
    assert count_stats['total'] == count_stats['successful'] + count_stats['failed']['total']
    assert count_stats['failed']['total'] == count_stats['failed']['crashed'] + count_stats['failed']['timedout']

    time_stats = stats['action_time_in_seconds']
    assert time_stats['min'] <= time_stats['avg'] <= time_stats['max']

    if time_stats['max'] > action_time_limit_in_seconds:
        assert count_stats['failed']['timedout'] > 0

    print('tests passed')

if __name__ == '__main__':
    run_tests()

####
