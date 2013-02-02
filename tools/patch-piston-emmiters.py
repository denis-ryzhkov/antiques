#/usr/bin/python

'''
Patches the next bug of Piston: Fields with "bool(value) == False" are missing from result.
Is virtualenv-aware and checking if already patched.

Used by:
    fabfile.py
'''

if __name__ == '__main__':
    from os.path import join
    import piston
    target_file_name = join(piston.__path__[0], 'emitters.py')
    
    replace_from = '''
                        maybe = getattr(data, maybe_field, None)
                        if maybe:
'''
    
    replace_to = '''
                        if hasattr(data, maybe_field):
                            maybe = getattr(data, maybe_field)
'''
    
    with open(target_file_name, 'r') as target_file:
        target_data = target_file.read()
    
    if 'hasattr(data, maybe_field)' in target_data:
        print('already patched ' + target_file_name)
    
    else:
        print('patching ' + target_file_name)
        with open(target_file_name, 'w') as target_file:
            target_file.write(target_data.replace(replace_from, replace_to))
