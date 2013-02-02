#!/usr/bin/env python

#### Y-Combinator

Y = lambda f: (lambda x: f(lambda v: x(x)(v)))(lambda x: f(lambda v: x(x)(v)))

fact = lambda f: lambda n: n * f(n - 1) if n else 1

assert Y(fact)(5) == 120

#### "R-Combinator"

R = lambda f, x: f(f, x)

fact = lambda n: R(
    lambda f, x: x * f(f, x - 1) if x else 1,
    n
)

assert fact(5) == 120

#### R, no bindings

assert (lambda n: (lambda f, x: f(f, x))(
    lambda f, x: x * f(f, x - 1) if x else 1,
    n
))(5) == 120

#### ok?

print('ok')

# but - pure lambdas should have only one argument.
