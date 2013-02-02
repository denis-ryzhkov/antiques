# -*- coding: utf-8 -*-

#### ints_parser

def ints_parser(sample):
    
    '''
    Factory for parsers that extract ints from strings with similar format, given as a sample to this factory.
    Resulting specialized parsers have better performance than universal re.match, datetime.strptime, etc.
    Strings are returned, because sometimes leading zeroes matter.

    Usage:
        parse_ints = ints_parser('12.01.31-23:59:55.123')
        for s in ['12.02.28-21:58:54.003', '12.02.28-21:58:54']: # much longer list
            print(parse_ints(s))

    ints_parser version 0.0.1
    Copyright (C) 2011 by Denis Ryzhkov <denis@ryzhkov.org>
    MIT License, see http://opensource.org/licenses/MIT
    '''
    
    starts_stops = []
    was_char = False
    for char_index, char in enumerate(sample):
        if char in '0123456789':
            if not was_char:
                starts_stops.append([char_index]) # new start
            was_char = True
        else:
            if was_char:
                starts_stops[-1].append(char_index) # stop of last
            was_char = False
    starts_stops[-1].append(None) # stop of last - up to the end of string
    starts_stops = tuple(tuple(start_stop) for start_stop in starts_stops) # speedup a bit
    return lambda s: tuple(s[start:stop] or '0' for start, stop in starts_stops)

#### test_ints_parser

def test_ints_parser():
    parse_ints = ints_parser('12.01.31-23:59:55.123')
    inputs = ['12.02.28-21:58:54.003', '12.02.28-21:58:54']
    ok_outputs = ['12 02 28 21 58 54 003', '12 02 28 21 58 54 0']
    for input_, ok_output in zip(inputs, ok_outputs):
        ok_output = tuple(ok_output.split())
        output = parse_ints(input_)
        assert output == ok_output, (output, ok_output, input_)
    print('OK')

#### main

if __name__ == '__main__':
    test_ints_parser()
