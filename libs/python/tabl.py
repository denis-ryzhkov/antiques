
'''
module: tabl
author: denis@ryzhkov.org
contrib: kstep@p-nut.info
license: free
'''

all = [
    'version',
    'tabl',
]

version = 8

#### tabl

class tabl(list): # `list`, not `tuple` - for frequent `CRUD` of rows; `list` - for implicitly inherited `__iter__`, `__len__`, etc.

    '''
    `tabl` type for `python` language.
    Now don't have to combine `list`-s and `dict`-s, and to repeat yourself many times.

    Target of `tabl` is easy and handy creation and manipulation of multi-column tables of values.

    It already supports:
        * Strict control of column names,
            to reduce errors on typos.
        * Default column values,
            for `DRY`.
        * Adding and updating of rows with positional and named associacion of value and column,
            for choice between `DRY` and explicit.
        * Value access in two styles:
            * As attribute: `.attr` .
            * By key: `[key]` .
        * Inherited features of rows `list` and `dict` inside of a row, e.g.:
            * Iteration through rows.
            * Formatting with row, and even it's expansion with `**`.
        * Easy access to row or rows by filter with positional or named associacion,
            same as in adding of rows.
        * Prototypes and quick presets of table structure.

    TODO:
        * More `CRUD` of rows and columns.
        * More `python`-operator and spec-methods support like `__eq__`.
        * `SQL`-like methods: `where`, `group`, `order` etc.
        * Definable `primary key` (maybe from several columns) for work as with `dict`: auto-replacement by primary key, hashed search by rows.
        * Maybe use `namedtuple` instead of `dict` if Python>=2.6.
        * PEP)

    Usage:

        t = tabl('title, description, is_deleted', is_deleted=False,
        ).add('title1', 'descr1', True,
        ).add('title2', 'descr2',
        ).add('title3', 'descr3', is_deleted=True,
        ).add(description='descr4', title='title4',
        )

        for row in t:
            if row.is_deleted:
                row.description = '<deleted>'
            for column, value in something:
                row[column] = value
            print('%(title)s: %(description)s, is deleted: %(is_deleted)s.' % row)
            print('combined with %(foreign)s: %(title)s - %(description)s' % dict(foreign='something', **row)

        print(t.get('title2', is_deleted=False).description)
        for row in t.filter('title2', is_deleted=False):
            print(row.desription)

        for row in tabl:
            row.update('<deleted>', is_deleted=True)

        tabbar = tabl('id, url, name', name='unknown')
        t = tabbar.copy()
        
        tabl.preset('tabbar', 'id, url, name', name='unknown')
        t = tabl.preset('tabbar')

    See also `Usage` of `tabl` and `tabl_row` methods for explanation.
    '''

    __presets = {}
    @classmethod
    def preset(cls, name, *columns, **defaults):

        '''
        Usage:
            tabl.preset('tabbar', 'id,url,name', name='unknown')
            ...
            t = tabl.preset('tabbar')
        '''

        if columns or defaults:
            cls.__presets[name] = (columns, defaults)

        preset_columns, preset_defaults = cls.__presets[name]
        return cls(*preset_columns, **preset_defaults)
    
    #### init

    def __init__(self, *columns, **defaults):

        '''
        Usage:
            t = tabl('title, description, is_deleted', is_deleted=False)
            t = tabl('title', 'description', 'is_deleted', is_deleted=False)
        '''

        list.__init__(self) # no rows by default

        if len(columns) == 1 and isinstance(columns[0], (str, unicode)):
            self.columns = [column.strip() for column in columns[0].split(',')]
        else:
            self.columns = list(columns) # note: arbitrary type of column id is possible, not only language-id-string, expected for `attr`-style access.

        for column in self.columns:
            assert column not in reserved_row_attrs, 'Conflict of column `%s` with built-in attribute of `tabl_row`.' % column

        for column in defaults: # dict keys only loop
            assert column in self.columns, 'Default column `%s` may be misspelled: it is not found in columns order definition.' % column

        self.defaults = defaults

    #### add

    def add(self, *values, **values_by_columns):

        '''
        Usage:
            t.add('title1', 'descr1', True,
            ).add('title2', 'descr2',
            ).add('title3', 'descr3', is_deleted=True,
            ).add(description='descr4', title='title4',
            )
        '''
        
        self.insert(len(self), *values, **values_by_columns)
        return self

    append = add # inherited method is not short enough for designed style, but has same sense

    #### insert

    def insert(self, row_index, *values, **values_by_columns):

        '''
        Usage:
            t.insert(0, 'title2', 'descr2',
            ).insert(0, 'title1', 'descr1', is_deleted=True,
            )
        '''
        
        list.insert(self, row_index, tabl_row(self, *values, **values_by_columns))
        return self

    #### get

    def get(self, *values, **values_by_columns):

        '''
        Usage:
            print(t.get('title2', is_deleted=False).description)
        '''

        for row in self.filter(*values, **values_by_columns):
            return row
        return None

    #### filter

    def filter(self, *values, **values_by_columns):

        '''
        Usage:
            for row in t.filter('title2', is_deleted=False):
                print(row.desription)
        '''

        filter = dict()
        self._check_and_set_items(filter, *values, **values_by_columns)

        for row in self:
            is_ok = True
            for column, value in filter.iteritems():
                if row[column] != value:
                    is_ok = False
                    break
            if is_ok:
                yield row

        raise StopIteration

    #### _check_and_set_items

    def _check_and_set_items(self, target, *values, **values_by_columns):

        '''
        Internal util, that checks columns and sets items to target.
        Please don't use it directly.
        Use higher-level public methods not starting with `_`.
        '''

        assert len(self.columns) >= len(values), 'This tabl has less columns, than you have passed.'
        for column_index, value in enumerate(values): # un-named values, can be overwriten by named ones
            column = self.columns[column_index]
            dict.__setitem__( target, column, value ) # if `target` is `tabl_row` this skips redundant `assert`-s

        for column, value in values_by_columns.iteritems(): # named values, most explicitly set
            assert column in self.columns, 'Column with name `%s` is not found in this tabl.' % column
            dict.__setitem__( target, column, value ) # see above

    #### copy

    def copy(self, *values, **values_by_columns):

        '''
        Usage:
            t2 = t.copy('title2', is_deleted=False)
            t3 = t2.copy()
        '''

        result = tabl(*self.columns, **self.defaults)
        for row in self.filter(*values, **values_by_columns):
            result.add(**row)
        return result

#### tabl_row

class tabl_row(dict): # `dict` - for many reasons, especially necessary for `**` operation

    '''
    Row of `tabl`.
    See `tabl` docstring and `Usage` of `tabl_row` methods.
    '''

    #### init

    def __init__(self, _tabl, *values, **values_by_columns):
        
        '''
        Use `tabl.add` and `tabl.insert`.
        Don't call this constructor directly.
        '''

        dict.__init__(self) # no columns and values by default

        object.__setattr__(self, '_tabl', _tabl) # bypass `tabl_row.__setattr__`

        for column, value in _tabl.defaults.iteritems(): # defaults, next will overwrite them
            dict.__setitem__(self, column, value)

        _tabl._check_and_set_items(self, *values, **values_by_columns)

        for column in _tabl.columns:
            assert column in self, 'Values for some non-default columns are not passed.'

    #### update

    def update(self, *values, **values_by_columns):

        '''
        Usage:
            for row in tabl:
                row.update('<deleted>', is_deleted=True)
        '''

        self._tabl._check_and_set_items(self, *values, **values_by_columns)
        return self

    #### setattr

    def __setattr__(self, column, value):
        
        '''
        Usage:
            row.description = 'another descr'
        '''

        self[column] = value # assert is inside `setitem`

    #### setitem

    def __setitem__(self, column, value):
        
        '''
        Usage:
            row[prefix + '_postfix'] = 'something'
            for column, value in something:
                row[column] = value
        '''

        assert column in self._tabl.columns, 'Column with name `%s` is not found in this tabl.' % column
        dict.__setitem__(self, column, value)

    #### getattr

    def __getattr__(self, column):

        '''
        Usage:
            if row.is_deleted:
                print(row.title)
        '''

        try:
            return dict.__getitem__(self, column)
        except KeyError: # we have to return expected exception class
            raise AttributeError, 'Column with name `%s` is not found in this tabl.' % column

    #### getitem

    def __getitem__(self, column):
        
        '''
        Usage:
            print(row[prefix + '_postfix'])
            print('%(title)s: %(description)s, is deleted: %(is_deleted)s.' % row)
            print('combined with %(foreign)s: %(title)s - %(description)s' % dict(foreign='something', **row)
        '''

        try:
            return dict.__getitem__(self, column)
        except KeyError: # reproducing same ecxeption class but with our unified message
            raise KeyError, 'Column with name `%s` is not found in this tabl.' % column

#### util

reserved_row_attrs = set(dir(tabl().add()[0]))
