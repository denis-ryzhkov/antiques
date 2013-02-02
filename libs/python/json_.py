# -*- coding: utf-8 -*-

'''
Analog of standard «json» module, but extendable to support non-standard types.
Includes «datetime» extension.

Usage:
    import json_ as json
'''

__all__ = [
    'dump',
    'dumps',
    'load',
    'loads',
    'JSONDecoder',
    'JSONEncoder',
    'processors',
    'NotChanged',
]

from json import dump as old_dump
from json import dumps as old_dumps
from json import load as old_load
from json import loads as old_loads

from json import JSONDecoder #@UnusedImport
from json import JSONEncoder #@UnusedImport

#### processors

class NotChanged(Exception):
    pass

class Processors(dict):

    def add(self, to_str=False, types=(), processor=(lambda data: data)):

        '''
        Usage:
            import utils.json_ as json

            json.processors.add(to_str=True, types=(datetime, date, time), processor=lambda data: data.isoformat())
                # [YYYY-MM-DD][T][HH:MM:SS][.microseconds][+-HH:MM]

            def datetime_from_str(data):
                for format in '%Y-%m-%dT%H:%M:%S.%f', '%Y-%m-%dT%H:%M:%S':
                    try:
                        return datetime.strptime(data, format)
                    except ValueError:
                        continue
                raise json.NotChanged

            json.processors.add(to_str=False, types=basestring, processor=datetime_from_str)
        '''

        self.setdefault(to_str, {}).setdefault(types, []).append(processor)

processors = Processors()

#### processed

def processed(data, to_str=False):

    for types, processors_of_this_type in processors.setdefault(to_str, {}).iteritems():
        if isinstance(data, types):
            for processor in processors_of_this_type:
                try:
                    data = processor(data)
                except NotChanged:
                    continue
                break

    if isinstance(data, dict):
        return dict((key, processed(value, to_str)) for key, value in data.iteritems())

    if isinstance(data, (list, tuple)):
        return [processed(value, to_str) for value in data]

    return data

#### dict --> str

def dump(data, *args, **kwargs):
    return old_dump(processed(data, to_str=True), *args, **kwargs)

def dumps(data, *args, **kwargs):
    return old_dumps(processed(data, to_str=True), *args, **kwargs)

#### str --> dict

def load(*args, **kwargs):
    return processed(old_load(*args, **kwargs), to_str=False)

def loads(*args, **kwargs):
    return processed(old_loads(*args, **kwargs), to_str=False)

#### datetime

from datetime import datetime, date, time

processors.add(to_str=True, types=(datetime, date, time), processor=lambda data: data.isoformat())
    # [YYYY-MM-DD][T][HH:MM:SS][.microseconds][+-HH:MM]

def datetime_from_str(data):
    for format_ in '%Y-%m-%dT%H:%M:%S.%f', '%Y-%m-%dT%H:%M:%S', '%Y-%m-%d':
        try:
            datetime_ = datetime.strptime(data, format_)
            if format_ == '%Y-%m-%d':
                datetime_ = datetime_.date()
            return datetime_
        except ValueError:
            continue
    raise NotChanged

processors.add(to_str=False, types=basestring, processor=datetime_from_str)
