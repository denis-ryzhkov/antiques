#### cached

def cached(expire=None, is_http=None):

    '''
    Intelligent caching decorator:
    1. Detects if decorated function generates HTTP response.
    2. If HTTP - uses `ETag` cache based on args.
    3. Uses server-side cache by `beaker`.
    4. If HTTP - uses `ETag` cache based on result.
    5. Returns result.

    Usage:
        @cached(expire=60*60)
        def func(args):
            # result = ...(args)
            return result

        # or
        @cached() # use default expire config
        def func(args): #...
    '''

    #### under pylons

    import sys
    if 'pylons' in sys.modules:
        import pylons
        from pylons.controllers.util import abort
        from pylons import cache

        #### check_etag

        def check_etag(etag_part, else_etag=None):
            #print('check_etag(%(etag_part)s, %(else_etag)s' % locals())

            if_none_match = pylons.request.if_none_match
            if if_none_match:
                for etag in if_none_match.etags:
                    if etag_part not in etag: continue

                    pylons.response.etag = etag
                    for header_name in 'Content-Type', 'Cache-Control', 'Pragma': # TODO: analyze all headers deeper, don't just copy from pylons etag_cache
                        pylons.response.headers.pop(header_name, None)
                    abort(304)

            pylons.response.etag = else_etag

    #### not under pylons

    else:
        raise NotImplemented # TODO: pre-config and use beaker directly

    #### common

    cache = cache.get_cache('%s.cached' % __name__)

    from hashlib import sha256
    from inspect import currentframe

    from method_decorator import method_decorator

    #### cached_decorator

    class cached_decorator(method_decorator):
        def __call__(self, *args, **kwargs):

            #### is_http

            is_http_detected = is_http if is_http != None else (currentframe().f_back.f_code.co_name == '_perform_call') # pylons function, calling controller actions, that are expected to return http response

            #### args_key

            args_key = sha256('%(method_type)s %(module_name)s.%(class_name)s.%(method_name)s(ignored, %(args)s, %(kwargs)s)' % dict(
                method_type=self.method_type,
                module_name=self.__module__,
                class_name=(self.cls.__name__ if self.cls else None),
                method_name=self.__name__,
                instance=self.obj, # ignored: usually one of controller objects in memory, or other `self`, not usefull for key directly anyway
                args=args,
                kwargs=kwargs,
            )).hexdigest()

            #### ETag args_key

            if is_http_detected:
                check_etag('(%s=' % args_key)

            #### beaker, result

            def expensive_code(): # no args here! closure only
                return method_decorator.__call__(self, *args, **kwargs)

            result = cache.get_value(key=args_key, createfunc=expensive_code, expiretime=expire)

            #### ETag result_key

            if is_http_detected:
                result_key = sha256(str(result)).hexdigest()
                check_etag(etag_part=('=%s)' % result_key), else_etag=('(%s=%s)' % (args_key, result_key)))

            #### return

            return result
    return cached_decorator
