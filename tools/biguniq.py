#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
biguniq.py is like UNIX uniq(1) tool, but it:
* Processes big unsorted text lines input.
* May be subsequently executed to process more input files or stdin.
* Appends unique lines only to output uniques.txt file.
* Uses O(n) disk IO to read result: it is uniques.txt file as-is.
* Uses O(1) memory, expecting gigabytes of input.
* Uses O(log n) disk IO to match input line to n unique lines stored,
expecting randomly unsorted input. Degrades to O(n) on sorted input.
* Uses O(n) storage: index takes 24 extra bytes per text line of data.
* BST is stored in binary index.buq file.
* Index file may be reconstructed if needed as simple
as re-feeding biguniq with its previous output uniques.txt
with O(n * log n).

Usage:
    ./biguniq.py input1.txt input2.txt inputN.txt
    cat input1.txt input2.txt inputN.txt | ./biguniq.py
    zcat input1.zip input2.zip inputN.zip | ./biguniq.py
    zip result.zip uniques.txt

biguniq version 0.0.2
Copyright (C) 2011 by Denis Ryzhkov <denis@ryzhkov.org>
MIT License, see http://opensource.org/licenses/MIT
'''

#### imports

import fileinput
from struct import pack, unpack, calcsize
from os import SEEK_END, SEEK_SET, path

#### config

# TODO: move config to command-line options with defaults

uniques_path = 'uniques.txt'
index_path = 'index.buq'

record_format = '=qqq' # offsets to: left, value, right
    # explicit stadard size is 64-bit for signed long long
    # explicit little-endian is native for x86-64
    # explicit none alignment
none_offset = -1L # None as signed long long

#### init

uniques_file = open(uniques_path, 'a+b') # random read, append-only write, text file is treated as binary for exact seeks

if not path.exists(index_path):
    open(index_path, 'a').close() # touch
index_file = open(index_path, 'r+b') # random read, random write, no-create, binary file

record_size = calcsize(record_format)

def log(*args):
    print(args)

#### update_index

# TODO: use memory-mapped-files or even more explicit in-memory caching of index file.
# Otherwise production HDD may be physically killed with Disk IO.

def update_index(left_offset=none_offset, value_offset=none_offset, right_offset=none_offset, index_offset=0, is_append=False):
    if is_append:
        index_file.seek(0, SEEK_END)
        index_offset = index_file.tell()
    else:
        index_file.seek(index_offset)
    index_file.write(pack(record_format, left_offset, value_offset, right_offset))
    return index_offset

#### add

def add(line, index_offset=0):
    #log('add', line, index_offset)
    
    #### if line is unique
    
    if index_offset == none_offset:
        #log('line is unique')
        
        #### append to data
        
        uniques_file.seek(0, SEEK_END)
        value_offset = uniques_file.tell()
        uniques_file.write(line)
        #log('value_offset', value_offset)
        
        #### append to index
        
        index_offset = update_index(value_offset=value_offset, is_append=True)
        #log('index_offset', index_offset)
        
        #### return offset to update parent
        
        return index_offset
    
    else:
        
        #### read record
        
        index_file.seek(index_offset)
        record = index_file.read(record_size)

        #### if no record
        
        if len(record) < record_size:
            #log('no record')
            assert index_offset == 0, index_offset # index should be empty if no record found at index_offset
            add(line, none_offset) # so it is first line, so it is unique, add it
        
        #### if record exists
        
        else:
            
            #### parse record, read unique_line
            
            left_offset, value_offset, right_offset = unpack(record_format, record)
            uniques_file.seek(value_offset)
            unique_line = uniques_file.readline()
            #log('l v r unique_line', left_offset, value_offset, right_offset, unique_line)
            
            #### left
            
            if line < unique_line:
                #log('left')
                new_offset = add(line, left_offset)
                #log('new_offset', new_offset)
                if left_offset == none_offset and new_offset != none_offset:
                    #log('update_index', new_offset, value_offset, right_offset, index_offset)
                    update_index(left_offset=new_offset, value_offset=value_offset, right_offset=right_offset, index_offset=index_offset)
            
            #### right
            
            elif line > unique_line:
                #log('right')
                new_offset = add(line, right_offset)
                #log('new_offset', new_offset)
                if right_offset == none_offset and new_offset != none_offset:
                    #log('update_index', left_offset, value_offset, new_offset, index_offset)
                    update_index(left_offset=left_offset, value_offset=value_offset, right_offset=new_offset, index_offset=index_offset)
            
            #### duplicate
            
            pass
    
    #log('---')
    return none_offset # do not add more

#### input

for line in fileinput.input(): # see Usage above
    add(line)

#### close

for file_to_close in uniques_file, index_file:
    file_to_close.close()

####
