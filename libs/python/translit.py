# -*- coding: utf-8 -*-

_translit_map = None
def translit(unicode_text):
    
    '''
    Usage:
        print(translit(u'ТестоваяСтраница')) # prints: TestovayaStranica
    '''
    
    assert isinstance(unicode_text, unicode)

    global _translit_map
    if not _translit_map:
        pairs = u'а=a,б=b,в=v,г=g,д=d,е=e,ё=yo,ж=zh,з=z,и=i,й=y,к=k,л=l,м=m,н=n,о=o,п=p,р=r,с=s,т=t,у=u,ф=f,х=h,ц=c,ч=ch,ш=sh,щ=shch,ъ=y,ы=y,ь=y,э=e,ю=yu,я=ya'
        # TODO: add more languages here with:
        # pairs += u', ...'
        pairs += u',' + pairs.upper()
        _translit_map = dict(pair.split('=') for pair in pairs.split(','))

    return u''.join(_translit_map.get(letter, letter) for letter in unicode_text) # translate or fallback to original `letter`

if __name__ == '__main__':
    print(translit(u'ТестоваяСтраница'))
