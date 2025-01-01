<!-- pandoc -f commonmark -t html understanding-j.md -->
<!--
<head><meta http-equiv="refresh" content="5"/></head>
<style>
pre {
    background: #dddddd;
    padding: 1em;
    overflow: auto;
    border-radius: 0.3em;
}
code {
    background: #dddddd;
    border-radius: 0.3em;
}
blockquote {
    border-left: #dddddd 0.5em solid;
    padding: 0.5em;
}
</style>
-->

- J versions: 9.4.2,

Found anything wrong? File an issue at
<https://github.com/bugsbugsbux/understanding-j/issues>.

---

# Understanding J

> An introduction to the J programming language that gets to the point.

It is intended for those with (some) programming experience, but others
should be mostly fine after looking up some basic programming terms like
function, argument, class, instance, inheritance, statement, expression,
etc.

Don't treat this as a reference: Section titles do not introduce an
exhaustive explanation of a certain topic, but serve to give this
document a rough structure. Individual sections are not intended to be
read in isolation from the others and assume the knowledge of previous
sections.

**Run the examples and read the comments!**

If you have J installed you can open this file in JQt via the
file-selection dialog which opens with `ctrl+o` (make sure to set the
filetype-filter to "all"). Click on a line with J code and press
`ctrl+enter` to execute it.

Covered builtins are listed in the appendix with a short description.

Important links:

- Project Homepage: <https://jsoftware.com>
- Online J interpreter:
  <https://jsoftware.github.io/j-playground/bin/html2/>
- **All builtin operators**, with links to their wiki pages:
  <https://code.jsoftware.com/wiki/NuVoc>
- Good old wiki:
  <https://www.jsoftware.com/help/dictionary/contents.htm>
- Cheatsheet/Reference Card (not for beginners):
  <https://code.jsoftware.com/wiki/File:B.A4.pdf>

---

## History:

J was first released in 1990 as a successor to APL, an alternative
mathematical notation that is computer-executable and works well with
multi-dimensional array data. Most notably J switches from APL's custom
symbol-set to ASCII only, calling most basic builtins by a single symbol
or a symbol with appended dot or colon, and giving distinct meaning to
single symbols that usually appear in pairs like various braces and
quotes (`[]"{}` etc).

## Comments:

```J
NB. comments the rest of the line (latin: nota bene).
```

## Numbers:

J has many number-notations; the most important are:
```J
3                   NB. integer
3.14                NB. float
_3                  NB. negative numbers start with underscore
_                   NB. sole underscore is infinity: a number
__                  NB. negative infinity
12j34               NB. complex number (sometimes used as argument pair)
16bcoffee           NB. base-16 number (must be lowercase)
```

## Lists, Booleans:

The notation is simple: just put elements next to each other. All
elements must to have the same type but as an empty list has no elements
it can be combined with any other list. True and false are represented
simply by the two numbers `1` and `0`. See also: strings

```J
0 1                 NB. the booleans (truth values) in a 2-element list
0 1 2 3 4           NB. due to context a list of numbers not booleans
(0 1 2) (3 4)       NB. error: can't implicitly join lists, see below
```

## Strings:

Strings are lists thus an empty string is commonly used as empty list
notation. The default string type is called "literal" and is UTF-8
encoded which means the first 128 ASCII characters work well with arrays
as they are a single byte long. String literals are singlequoted, and
only this character is special; it is escaped by doubling it. See also:
string representation and unicode

```J
''                  NB. empty string is empty list
'this is a string. it''s always singlequoted'
```

## Nouns:

*Nouns* are data values such as the ones covered until now. *Boxes*,
which will be covered later, are nouns too. Lists are actually just a
basic case of *arrays* which can be thought of as nested lists.

Classes and their instances aren't nouns: they cannot be referenced
directly; but their name can be saved as a string.

Functions aren't nouns either; but by putting them into a special kind
of list, *gerunds*, they can effectively be made one (also covered
below).

### Special data types:

J comes with some specialized data types, which wont be covered here,
but shall at least be mentioned:

- **Symbols**: They are a specialized type of string, which is
  immutable, treated as a single element and has optimized performance
  with searching, sorting and comparison operations. However, only a
  few, often used ones should be created, as they are registered in a
  global table and cannot be removed from it anymore. More info at:
  <https://code.jsoftware.com/wiki/Vocabulary/sco>
  <https://www.jsoftware.com/help/dictionary/dsco.htm>
- **Sparse arrays**: If a sizable array (for example a list; see:
  arrays) consists of mostly the same repeated value, its size can be
  reduced by only saving the values which are not this so called
  sparse-element. Contrary to regular arrays, sparse arrays are
  displayed as a table of index-value pairs of the non-sparse-elements
  and need to be queried explicitly for their sparse-element.
  Computations with them are envisioned as equivalent to regular arrays
  but this is not fully implemented (for example, sparse arrays cannot
  be boxed (see: boxes) and strings (which are arrays) cannot be
  sparse); the results are usually sparse arrays too, however, the
  sparse-element might differ! More info at:
  <https://www.jsoftware.com/help/dictionary/d211.htm>

## Functions:

**Verbs** are functions that take nouns as their argument/s and return
nouns. A verb has access to its left argument via the local variable `x`
and to its right argument via the local variable `y`. If there are
arguments on both sides of a function it is called dyadic (such verbs
are *dyads*) otherwise the function is monadic (and such verbs are
called *monads*; not related to the haskell term).
```J
  -                 NB. fn (here minus) without arg does not execute
  - 1               NB. monad (1 arg, but may be list)
1 -                 NB. error: monads take their arg from the right only
1 - 2               NB. dyad (2 args, may be lists)

    - 1 2           NB. monad with list argument
0 1 2 , 3 4         NB. the dyad , joins lists
```
Note that the monadic and dyadic case here are two distinct functions:
negate-number and subtract. They share a name (the symbol `-`) and a
definition: the function `-` is *ambivalent*. A function does not have
to have both cases.

**Modifiers** are functions used to pre-process a statement/expression;
this means they run before the main evaluation step. Modifiers return a
new function that has, additionally to its own arguments `x` and `y`,
access to the original arguments as variables `u` (left, `m` may be used
instead to indicate a noun) and `v` (right, use `n` instead to indicate
a noun). The new function may return any entity, even more modifiers,
which would also be processed before the first verb evaluates!

```J
1 + 2 + 3           NB. dyadic + is addition
+  1 2 3j4          NB. monadic + gives the complex conjugates: 1 2 3j_4
+/ 1 2 3            NB. 6 because: 1 + 2 + 3 is 6
```

The last example showed that `+/y` is not the same as `+y` but rather
`y1 + y2 + y3 ...`. This is because `/` is an *adverb* (a modifier that
takes one argument to the *left*): It creates a new function that
inserts the original argument `+` between all elements of its own
argument `1 2 3`.

*Conjunctions* only differ insofar as they (meaning the original
modifiers not the returned entities) take two arguments. For example `&`
takes a dyad and a noun and creates a new verb which always uses the
given noun as one of its arguments and the argument to the newly created
monad as the other argument:
```J
2 ^ 3               NB. dyad ^ is power: "two to the three"
2&^ 0 1 2 3         NB. convert dyad ^ with left arg 2 to a monad
^&(2) 0 1 2 3       NB. convert dyad ^ with right arg 2 to a monad
```

## Assignments:

Assignments use the operators `=:` (global) and `=.` (function-local).
They return their values, but the interpreter does not display them, so
often monads `[` or `]`, which return their argument unchanged, are used
as prefix. When assigning to multiple variables the return value is
still the original argument.
```J
foo =: 1            NB. return value of assignment not shown
[ foo =: foo + 1    NB. global assignment
] foo =. foo + 1    NB. local assignment if in function otherwise global

NB. btw the dyadic versions return either the left or the right arg:
0 [ 1
0 ] 1
```

It is possible to assign multiple values at the same time, but the value
returned is the unchanged original argument.
```J
'foo bar' =: 'val'  NB. names as space joined strings
foo
bar
baz=:'foo bar'=:3 4 NB. multi assignment returns unchanged arg
baz                 NB. thus baz received the original arg
foo                 NB. but foo got first
bar                 NB. and bar got second value
'foo bar' =: 1 2 3  NB. error: same number of names as elements required
```

See also: importing code

## Importing Code:

To run the code from some file use one of these convenient verbs:

- `load`: Runs the specified file or shortname (list available
  shortnames with `scripts''`).
- `loadd`: Like `load` but displays the lines before executing them.
- `require`: Like `load` but files that were already loaded won't be
  loaded again.

As these verbs, like all functions, have their own scope, assignments in
the loaded file/s which use `=.` but target the current global scope get
captured by the loading function's scope and thus are not available
afterwards!

## Defining Entities (Functions, Nouns) by Explicit-Definition:

Explicit-definitions are created with the `:` conjunction which returns
an entity of the type indicated by the integer to its *left*:

- `0` for nouns,
- `1` for adverbs,
- `2` for conjunctions,
- `3` for monadic (optionally ambivalent) verbs,
- `4` for dyads.

The entities' value is specified as the *right* argument and is a string
for functions. A value of `0` always means to read in the following
lines as a string - until the next line containing `)` as its only
printable character.

```J
NB. nouns
0 : 'string'            NB. creates noun with value 'string'
1 + 0 : 100             NB. creates and uses noun 100 (the number)
echo '>', (0 : 0), '<'  NB. creates noun from next lines and uses it
A Multiline string.
Make sure to put a space between the left arg and : because otherwise it
is parsed as one of the functions __: or _9: to 0: or 1: to 9: or _:
that ignore their args and always return their (negative) digit/infinity
)

NB. verbs
1 (4 : 'x + y') 2
(3 : '-y') 1
(3 :'3 :''1+y'' y') 1   NB. nested
fn =: 3 : 0             NB. assign new (ambivalent) multiline verb
    echo 'First the body of a monad, then optionally the body of a dyad'
    echo 'separated by a line containing : as its only printable symbol'
    :
    echo 'Multiline explicit-defs cannot be nested but may contain'
    3 :'echo''one-line explicit-defs or (multiline) DDs (see below)''' 0
)
fn 1
1 fn 2

NB. adverb representing number in percent ( ": formats arg as string)
echo 0.01 (1 : '( ": u * 100), ''%'' ')
percent =: 1 : 0        NB. same as a multiline definition
    (": m * 100), '%'   NB. using m to indicate left arg is noun
)
echo 0.7 percent

NB. conjunction that swaps its arguments and the args of its result
swap =: 2 : 'y v u x'
4 % 2                   NB. division
% 2                     NB. 1 divided by y
4 % - 2                 NB. 4 divided by negative 2
4 - % 2                 NB. operators swapped: 4 minus a half
2 - % 4                 NB. swap args too: 2 minus a quarter
4 % swap - 2            NB. equivalent but done by the conjunction swap
```

## Index-Functions, Helpers:

As demonstrated, explicit definitions specify the type to create as a
number. This pattern of selecting functionality with a numeric index is
sort of J's guilty pleasure. In most cases one would look up the
functions in the docs and assign an alias to often used ones; in fact, J
already comes with a set of aliases (and other helpers): list them with
`names_z_''`. New users should definitely look over the docs for `!:`
(foreign function index) and `o.` (circle functions) to see what's
available:
<https://code.jsoftware.com/wiki/Vocabulary/Foreigns>
<https://code.jsoftware.com/wiki/Vocabulary/odot#dyadic>

## Direct Definitions:

Direct definitions, *DD*s for short, are another way to write explicit
definitions. They are wrapped in double-braces and assume their type
from the argument-variable-names used:

- If variables `v` or `n` are used, a *conjunction*,
- otherwise, if `u` or `m` are used, an *adverb*,
- otherwise, if `x` is used, a dyad or ambivalent *verb* is created.

A type may also be forced by appending `)` and one of the letters
`n`oun, `a`dverb, `c`onjunction, `m`onad or `d`yad to the opening
braces.

The following examples contain more info about DDs and should be
compared carefully with their actual output!

```J
]fn =: {{123}}       NB. monad; internally represented as explicit-def
echo 1 2 3 , {{123}} ''
]fn =: {{x + y [ echo 'dyad because uses x' }}
1 fn 2

{{'>',{{)nstring}},{{)n123}},'<'}} 'nested; one-line string definitions'

{{ echo '---'
    echo 'untyped multiline DD'
    echo '* may start on opening line'
    echo '* may contain other mutliline DDs'
    {{ NB. such as this one
    echo '* closing line doesn''t have to start with }}'
    echo '* may continue on closing line' }} 'like here'
}} ''

{{)m NB. only comment allowed on typed opening line
    echo '---'
    echo 'typed multiline DD is like an untyped one except:'
    echo '* makes sure it is of a certain type'
    echo '* must not start on opening line (comments allowed)'
    y NB. last value is returned

}} {{)n  NB.(not a comment) except a multiline DD noun *may* do so.
multiline DDs which define nouns:
  * must be typed
  * always produce a single list of characters (a string)
  * everything (incl whitespace and comment on opening line) becomes
    part of the string, except:
}} , {{)n
    the opening line if it is empty (as in this case -> no empty line)
  * must put closing braces as first characters of line:
    }} thus this does not end the definition, but this does:
}} , '< * as the < indicated: always end in a newline'
```

## Arrays:

**An array is a ((list of) list/s of) value/s.** Thus even single values
(*scalars*/*atoms*) are actually arrays. All elements must have the same
type, and on the same nesting-level (*dimension*/*axis*) every element
has to have the same length.

Therefore an array can be described by its type and *shape*, which is
the list of the lengths of elements on each nesting-level. The length of
the shape is called *rank*.

```J
$ 0                 NB. monad $ gives shape; scalars have an empty shape
# $ 0               NB. and therefore rank 0; monad # gives arg's length
$ 0 1 2             NB. shape
# $ 0 1 2           NB. rank
2 1 $ 10 20         NB. dyad $ reshapes array; new: 2 lists of 1 element
$ 2 1 $ 10 20       NB. shape
2 $ 10 20 30        NB. reshaping may drop elements
5 $ 100 200         NB. or repeat the elements as needed
'ten', 20           NB. error: incompatible types
10, 3.14            NB. ok: both are numbers
2 2 $ 'abc'         NB. don't forget that strings are arrays too!
'a',LF,'b'          NB. strings 'a' and 'b' combined with a newline
NB. ^^ predefined variable containing newline, also useful: TAB,CR,CRLF
```

## Boxes, Trees:

The container-type box is useful to get around the restrictions of
arrays: A boxed value always appears as scalar of type box; therefore
any values, each in their own box, can be put into the same array!

A box not containing another box may be called **leaf** when talking
about **trees**, structures consisting of nested boxes. J comes with
special functions to simplify working with trees, such as `{::` to index
them (see: indexing).

```J
<3                  NB. monad < puts the value passed as arg into a box
><3                 NB. monad > opens/unboxes the outer box of a value
<''                 NB. an empty box is just a boxed empty array
a:                  NB. equivalent; called "ace", a noun

1 ; 3               NB. dyad ; joins args as boxes
1 ; <3              NB. it removes 1 boxing level from its right arg
(<1); <3            NB. but not from its left arg; therefore
(<1),<( (<2),<<3 )  NB. building trees with , helps seeing nesting level

1 2 , 'abc'         NB. error: different types and lengths
1 2 ; 'abc'         NB. ok because ; boxes the values first
(<1 2) , <'abc'     NB. here we manually boxed the values first -> ok

NB. multi assignments unpack top-level boxes:
]'foo bar' =: 0 1;2 NB. removes one boxing level but returns original
foo, bar

NB. comparison of boxed values
'bar' = 'baz'
(<'bar') = <'baz'
(<'bar') = <'bar'
'bar' = <'bar'
```

## (Explicit) Control-Structures and Control-Words:

J has all common control-structures and -words, however, they can only
be used within explicit functions (explicit definitions or DDs). They
are not idiomatic J and hinder new users from learning to think in array
programming style (see: idiomatic replacements for explicit
control-structures). Nevertheless, some problems are simpler to solve
this way.

- Assert: *All atoms* have to be `1`.
  ```J
  {{
      assert. 'aa'='aa' NB. dyad = compares corresponding atoms: 1 1
      assert. 'aa'='ab' NB. error because not all 1s: 1 0
  }}''
  ```
- Conditionals: *First atom* must not be `0`.
  ```J
  {{ if. 0 1 do.        NB. first atom is 0 -> false
      echo 'if block'
  elseif. 1 0 do.       NB. first atom is not 0 -> true
      echo 'elseif block'
  elseif. 1 do.         NB. only considered if no previous block ran
      echo 'elseif 2 block'
  else.                 NB. runs if no previous block ran
      echo 'else-block'
  end. }}''

  NB. therefore be careful with tests such as:
  {{ if 'bar' = 'baz' do. echo 'true' else. echo 'false' end. }}''
  ```
- Select: It first boxes unboxed arguments to `select.`, `fcase.`
  or`case.` then compares whether one of the boxes passed to `select.`
  is the same as a box passed to a `case.` or ` fcase.` statement and
  executes the respective block. An empty `case.` condition always
  matches. After the evaluation of a `case.` block execution jumps to
  `end.`, while after executing an `fcase.` (fallthrough) block the
  following `case.` or `fcase.` runs unconditionally.
  ```J
  match =: {{
  select. y
  case. 'baz' do. echo 'does not match ''bar'' due to both being boxed'
  case. 'bar' do. echo 'after case. jumps to end.'
  case. 1 2 3 do. echo 'due to the boxing only matches the list 1 2 3'
  case. 1; 2; 3 do. echo 'box it yourself to get the desired cases'
  case. 4;5 do. echo 'one select.-box matching one f/case.-box suffices'
  fcase. 'fizz' do. echo 'after fcase. always executes next f/case.'
  fcase. 'buzz' do. echo 'fcase. stacks dont have to start at the top.'
  case. 'nomatch' do. echo 'no match but triggered by preceding fcase.'
  case. do. echo '... empty case. always matches'
  end. }}

  echo '---'
  match 'bar'
  match 1 2 3
  match 1
  match <2              NB. won't get boxed a second time
  match 4; 6
  match 4; 4            NB. despite several matches only runs block once
  match 'fizz'
  match 'buzz'
  match 'shouldn''t match but...'
  ```
- While loops: Only run if *first atom* is not `0`.
  ```J
  {{
      foo =: 3
      while.
          (foo > 0), 0  NB. dyad > true if x greater than y
      do.
          echo foo =: foo -1
      end.
  }} ''
  ```
- Whilst loops: are while loops that always *run at least once*.
  ```J
  {{ whilst. 0 1 do.
      echo 'runs at least once'
  end. }} ''
  ```
- For (-each) loops: There are no classic for loops. Iterating over a
  list of integers can mimic one. If a for-loop does not terminate early
  its element-holding variable is set to an empty list and its
  index-holding variable to the length of the list. If it terminates
  early their last states are kept.
  ```J
  {{
    for. 1 2 do.
      echo 'runs once per item. Neither item nor index are available...'
    end.
  }} ''

  fn =: {{
    foo =: 'for_<foo>. hides global <foo>[_index]. with local versions'
    NB. see: namespaces for more info about local/global assignments
    foo_index =. 'for_<foo>. modifies local <foo>[_index]'
    for_foo. 'abc' do.
      echo foo; foo_index
      if. y do.
        early =. 'yes'
        break.
      else.
        early =. 'no'
        continue.   NB. does not terminate loop just current iteration!
      end.
      echo 'never runs'
    end.
    echo 'terminated early?'; early; 'foo:'; foo; 'foo_index:';foo_index
  }}
  fn 1
  fn 0
  echo 'value of global foo:'; foo NB. unchanged
  ```
- Return statements: Exit function early. Pass a return-value as *left*
  argument!
  ```J
  {{                    NB. functions return last computed value
      <'foo'
      <'bar'
  }} ''
  {{
      <'foo'
      return.           NB. exits early and returns last computed value
      <'bar'
  }} ''
  {{
      <'foo'
      <'fizz' return.   NB. or given left arg (parens not necessary??)
      <'bar'
  }}''
  ```
- Goto: Considered Harmful - Edsger Dijkstra
- Error handling: see: Errors

## Errors:

Verbs related to errors and debugging can be found in section 13 of
the foreign function index (`13!: n`) but there are default aliases,
which will be used below.

Errors have a number and a message, which defaults to (err - 1)th
element in the list of default error messages returned by `9!:8''`.
`dberr` queries the last error's number and `dberm` gets its message.

To raise an error its number is passed to `dbsig` which optionally
accepts a custom error message as left argument. (Show the correct
function name instead of "dbsig" in the message by using `(13!:8)`
directly).

```J
getinfo =: {{
    echo 'An error occurred...'
    echo 'Its number is: ', ": dberr ''
    echo 'And its message is:', LF, ": dberm '' }}
might_fail =: {{
    if. y do.
        echo 'success'
    else.
        echo 'failure'
        'my custom message' dbsig 100     NB. raise an error
    end. }}
namedfn =: {{
    try.
        might_fail y
    catch. getinfo''
    end.
    echo 'after try-catch' }}

namedfn 0
```

When J runs in debug mode, which can be en/disabled with a boolean
argument to `dbr`, and queried with `dbq`, errors in *named* functions
pause execution and messages contain a bit more information; the
program state can then be investigated and altered.

```J
dbr 1               NB. turn on debugging
namedfn 0           NB. more info but does not pause because handled

namedfn =: {{
    try. might_fail y
    catchd.         NB. pause on error
        echo 'adding catchd. clause pauses execution if debugging is on'
        echo 'catchd. block only executes if:'
        echo '  * debugging is off and'
        echo '  * there is no catch. block'
    catch.
        echo 'catch. block only executes if there is no catchd. block'
        getinfo''
    end.
    echo 'after try-catch' }}
namedfn 0           NB. pauses, does not run any catch./catchd. blocks
dbs ''              NB. inspect stack
dbnxt ''            NB. continue program

NB. dbq'' does not inform about whether execution is currently paused
NB. but only whether debug mode is on or not. currently it is:
dbq ''

dbr 0               NB. turn off debugging
namedfn 0           NB. doesn't pause, runs catch. block

namedfn =: {{
    try. might_fail y
    catchd. echo 'not debugging and no catch thus catchd. block may run'
    end.
    echo 'after try-catch' }}
namedfn 0
```

J has a `throw.` keyword which is equivalent to raising error 55 with
`dbsig` and behaves differently from other errors: `throw.`ing
immediately exits the current function and goes up the callstack until
it finds a caller which used a `try.` block with a `catcht.` clause,
which is then executed. If no `catcht.` is found an "uncaught throw."
error is raised.

```J
NB. normal errors look for catch./catchd. in same try. statement
inner =: {{
    try. dbsig 14   NB. no left arg -> default message
    catch. echo 'inner function''s catch. block'
    end.
    echo 'inner fn done' }}
outer =: {{
    try. inner ''
    catch. echo 'outer function''s catch. block'
    end.
    echo 'outer fn done' }}
outer ''

NB. throw. looks for catcht. in *caller* (or its callers)
inner =: {{
    try.
        echo 'throwing up...'
        throw.
    catch. echo 'inner function''s catch.'
    catcht. echo 'inner function''s catcht.'
    end.
    echo 'inner fn done' }}
outer ''
outer =: {{
    try. inner''
    catch. echo 'outer function''s catch. block'
    catcht. echo 'outer function''s catcht.'
    end.
    echo 'outer fn done' }}
outer ''
```

## Ranks and Frames:

The **rank of a noun is the length of its shape**. Note that the shape
of a scalar/atom is an empty list, thus a scalar's rank is 0; as well as
that the number of elements on the lowest dimension (atoms) is the last
number in the shape:

```J
] foo =: i.2 3 4    NB. monad i. creates number sequence in given shape
$ foo               NB. shape of foo
#$foo               NB. length of shape of foo; aka rank
]bar =: i.4 3 2     NB. has the reverse shape of foo
```

Every **verb defines a maximum allowed rank for its arguments**; this is
called the "rank of a verb". As a verb may have a monadic and a dyadic
version and a dyad has two arguments, "the" rank of a verb is actually a
list of the three ranks in the following order: monadic, dyadic-left and
dyadic-right rank.

```J
; b.0               NB. show ranks of ; which works on entire argument/s
< b.0               NB. monad takes whole arg but dyad takes atoms only
fn =: {{echo 'hi'}} NB. new verb
fn b.0              NB. default ranks of new verbs are all infinity
</ b.0              NB. same when created by modifiers; compare to <b.0
fn "1 2 3 b.0       NB. set and show the three ranks of verb fn
fn "1 2   b.0       NB. set and show the left and right ranks of verb fn
fn "_     b.0       NB. show that this sets all ranks to same value
(fn"<)    b.0       NB. show that this copies the right verb's ranks
```

If an argument has a **higher rank than is allowed it is broken into
pieces of this rank called "cells"**. The verb then operates on each of
this cells individually and finally all results are returned.

```J
- 1 2 3             NB. monad - (rank 0) breaks list into atoms

<"0 i.2 3           NB. max allowed rank 0: breaks arg into atoms
<"1 i.2 3           NB. max allowed rank 1: breaks arg into lines
<"2 i.2 3           NB. max allowed rank 2: breaks arg into tables
```

Deducing the shape of the cells in these examples is simple; comparing
them with the shape of the original argument reveals that the shape of
cells is a (possibly empty) suffix of the argument's shape and has the
length of the rank of the verb. The example operating on atoms also
showed that the final shape is not simply a (one-dimensional) list of
the individual results: Rather, it is the individual results arranged in
a so called **"frame", which is the (possibly empty) leading part of the
argument's shape, that was not used to determine the shape of the
cells**.

```
arg-shape   verb-rank   frame   result-shapes   final-shape
2 3 4           0       2 3 4       ''          2 3 4,''
2 3 4           1       2 3         ''          2 3,''
2 3 4           _       ''          ''          '',''
2 3 4           2       2           2           2,2

]a =: i.2 3 4
<"0 a
<"1 a
<"_ a
{{ y;y }}"2 a
```

While dyads follow essentially the same rules, as they process two cells
at the same time, these have to be paired up according to some rules:
Generally, every left argument is paired with the right argument that
corresponds to it by index. If this is not possible an error is thrown.
Therefore, dyads do not pair each left with every right cell, which is
what applying adverb `/` to a dyad does -- even though sometimes it
looks like it due to the following exception: When there is a single
cell on a side, it is paired with every cell from the other side
(individually).

```J
10 20 30 - 1 2 3    NB. corresponding: 1st-1st,2nd-2nd,...
10 20 30 - 1 2      NB. error: no partner for 3rd cell
10 20 30 - 1        NB. each left with the single right cell
1 - 10 20 30        NB. each right with the single left cell
1-/ 10 20 30        NB. here it looks the same as without the /
10 20 30-/ 1 2      NB. but here it does not
```

Dyads, too, arrange the individual results in a frame determined by the
argument. However, as there are two arguments and thus two frames, these
may not contradict each other, which they do not when they are equal
or one simply omits the last elements of the other:

```J
(i.2 2) ;"1 (i.2 3) NB. ok: frames are 2 and 2
(i.2 2) ;"0 (i.2 3) NB. error: frames are 2 2 and 2 3
(i.2 3 4);"1(i.2 3) NB. ok: frames are 2 3 and 2
(i.1 3) ;"1 (i.2 3) NB. error: frames are 1 and 2
(i.3) ;"1 0 (i.2 3) NB. ok: frames are '' and 2 3 (which equals '',2 3)
```

When one frame is longer than the other, the shorter frame is also used
to group the cells of *both* arguments: On the side of the shorter frame
these groups will always contain a single cell, which is then paired
with each cell from the corresponding group on the other side
individually. Finally, the results of each group are arranged by the
difference of the frames, while the groups are arranged by the shorter
(common) frame.

```J
(i.2 3 4) ;"1 2 (i.2 3 4)   NB. frames: 2 3 and 2
(i.2 3) ;"1 1 (i.2 3 4)     NB. frames: 2 and 2 3
1 2 +"0 0 i.2 3             NB. frames: 2 and 2 3
```

Positive verb-ranks, such as the ones used until now, select
verb-rank-amount of trailing dimensions to be used as cells for the verb
to operate on. Negative ranks, however, select leading dimensions, or in
other words, the frame.

```J
<"_2 i.2 3 4    NB. frameshape: 2 3 cellshape: 4
<"_1 i.2 3 4    NB. frameshape: 2 cellshape: 3 4
<"_0 i.2 3 4    NB. there is no negative zero -> select 0-cells (atoms)
<"_11 i.2 3 4   NB. abs val of neg rank higher than arg rank: 0-cells

fn =: <"_1      NB. actually sets a negative rank...
fn i.3
fn i.3 3
fn b.0          NB. ...but it is NOT SHOWN
```

Rank, even the default one, should always be considered as the
application of a modifier -- and therefore as creating a new function
which handles the invocation of the verb with the correct arguments. It
is not simply a property of the verb that could be altered at will.
Because of this, verb rank can never be increased: Every
rank-conjunction can only work with the arguments it receives (possibly
by a previous rank-operator) and therefore can only further constrain
the rank.

```J
]tbl =: i.2 2
< tbl               NB. should be imagined as <"_ because rank is _ 0 0
<"1 "2 tbl          NB. "2 passes tables to "1 which calls < with lists
<"2 "1 tbl          NB. "1 passes lists to "2 which passes (them) to <

NB. sequence of rank-conj is not the same as the minimum values:
tbl ;"0 1 tbl       NB. pair atoms with lines
tbl ;"1 1 "0 2 tbl  NB. for each atom-table pair: pair (atom) with line
```

## Padding:

Incompatible values can still be put into the same structure by using
boxes. When they are of the same type, lower dimensional values can also
be padded to match the shape of the higher dimensional value and thus
the boxes can be omitted. This is different from reshaping!

Unboxing automatically pads values. Behind the scenes this happens all
the time when assembling subresults into a frame.

```J
 1; 2 2
>1; 2 2             NB. numeric arrays are padded with zeros
2 3 $ 'a'           NB. reshaping reuses the original as needed
>'a'; 'aaa'         NB. padding adds filler if necessary. here spaces

NB. note the resulting pattern:
 (2 1 $ 1); (2 3 $ 2)
>(2 1 $ 1); (2 3 $ 2)
 (2 3 $ 1); (2 3 4 $ 2)
>(2 3 $ 1); (2 3 4 $ 2)

NB. different length results are padded before being put into a frame as
NB. this example (that creates y by y matrices) shows:
(3 : '1 + i.y,y' "0) 1 2 3
```

## Evaluation Rules:

After reading the previous sections the following rules should not be
surprising:

- Evaluation works right to left and in two steps:

  1. Evaluate modifiers until only nouns and verbs are left,
  2. then evaluate those.

  Right to left does not simply mean reading the words in reverse order
  but to find the rightmost verb or modifier (depending on current
  step), then determining its arguments and replacing all of that with
  its evaluation result. This repeats until the line is processed
  entirely.
  ```J
  - -/ 1 2 3        NB. 1. modifiers: find rightmost: / it's arg is -
  - 1 - 2 - 3       NB. 1a. result -fn 1 2 3 but expressed as its effect
  - 1 - _1          NB. 2. verbs: rightmost - has args 2 and 3 result _1
  - 2               NB. rightmost verb - has args 1 and _1 result 2
  _2                NB. rightmost verb - only has right arg: 2 result _2

  0 1 + - 2 3       NB. this is (0 1 + (- 2 3))
  ```
- No mathematical operator precedence, just right to left evaluation and
  parentheses.
  ```J
  2 * 3 + 4         NB. 14
  (2 * 3) + 4       NB. 10
  ```
- Parentheses form subexpressions, that complete before the parent.
  ```J
  (3-2) - 1         NB. subexpr completes first and returns result: 1

  1 (2) 3           NB. if this was not an error (2) were the number 2
  1, (2), 3         NB. but it is a subexpr not a noun thus , is needed

  (- +) 1 2 3       NB. (-+) is not simply -+ but creates a (see:) train
  - + 1 2 3         NB. trains are not equivalent to unparentesized expr
  ```
- *Consecutive* modifiers are processed left to right:
  ```J
  1 - ~ 3           NB. adverb ~ swaps the args of the verb it creates
  -~ 3              NB. or copies the right arg to the left

  join0 =: ,"0      NB. join atoms; technically already has a modifier "
  'AB' join0 'CD'   NB. but let's treat this as just some rank 0 verb

  'AB' join0 ~ / 'CD'
  NB. first creates a function invoking join0 with swapped args
  NB. then combines each x- with each y-element using this new function

  'AB' join0 / ~ 'CD'
  NB. first creates a function that combines each x- with each y-element
  NB. using dyad join0; then swaps the args to this new function
  ```
- Nouns are evaluated immediately, verbs only when called:
  ```J
  mynoun =: unknown + 1         NB. error; evaluates expr to get noun
  myverb =: 3 : 'unknown + 1'   NB. ok because not yet evaluated
  myverb''                      NB. error
  ```

## Trains:

```
      x? (E? D    C  B  A) y
result <---- D <---- B         }combinators: dyads
            ?       / \             except when their left arg is [:
           ?       /   \
          E       C     A      }operators: use train's arg/s, monads
         ? \     ? \   ? \          except when train not hook and has x
        x?  y   x?  y x?  y    }using arguments of the train itself
        -------------
       =======       \
    last left arg      All except the first operator may be replaced by:
 is missing in hooks        *) [: which makes the combinator a monad
then replaced with x or y   *) noun to be used as left arg of combinator
```

An **isolated sequence of verbs (in other words: multiple verbs not
followed by a noun) creates a train**, that is a special pattern
defining which verbs receive what arguments and execute in which order.
The basic idea is called **fork** and best explained by the computation
of the arithmetic mean:
```J
Y =: 1 2 3 4
(+/ % #) Y          NB. a list's mean is its sum divided by its length
(+/ Y) % (# Y)      NB. equivalent expanded form
```

A longer train simply continues this pattern using the result of the
previous fork as the right argument to the next fork. When the last fork
doesn't get a left argument (because the train is of even length) it
uses an argument of the train instead: its left, or if missing its right
one. This is called hook-rule and when it's used the whole train is
called *a* **hook**, otherwise its *a* fork.
```
Train:          Expands to:                         Note:
  (    C B A) y =            (  C y) B (  A y)      the basic fork
  (E D C B A) y = (  E y) D ((  C y) B (  A y))     just more forks
  (  D C B A) y =       y D ((  C y) B (  A y))     last uses hook rule
  (      B A) y =                  y B (  A y)      just a hook
```

Using my own terminology: A train consists of *operators* (the odd
numbered verbs counting from right) that *operate* on the train's
arguments, and *combinators* (the even numbered verbs counting from
right) that are dyads *combining* the result of everything to their
right with the result of the operator to their left.

As said before, a hook's last combinator uses an argument of the train
to replace its missing left operator. When the train is dyadic, another
peculiarity of hooks becomes evident: A hook's operators are always
monads, ignoring the train's left argument:
```
x (E D C B A) y = (x E y) D ((x C y) B (x A y))     operators are dyads
x (  D C B A) y =       x D ((  C y) B (  A y))     operators are monads
x (      B A) y =                  x B (  A y)      just a hook
```

Any left operator may be replaced with a noun to create a so called
**NVV (noun-verb-verb) fork**, which simply uses this noun as its left
argument:
```
x (E D 1 B A) y = (x E y) D (      1 B (x A y))     left arg to B is 1
x (  D 1 B A) y =       x D (      1 B (  A y))     left arg to B is 1
```

Any left operator may be replaced with `[:` to create a so called
**capped fork** which converts its combinator into a monad:
```
x (E D [: B A) y = (x E y)D (        B (x A y))     fork ([:BA) -> monad
x (  D [: B A) y =      x D (        B (  A y))     fork ([:BA) -> monad
```

Experiment with some trains:
```J
NB. a verb like ; but which always adds a boxing level before joining
'X Y' =: (<<'X'),(<<'Y')
X ; Y
X {{ (<x),(<y) }} Y

NB. try to build the verb as a train instead:
X (< , <) Y             NB. error: a fork's operators are dyads
X (] < , <) Y           NB. fail: the operators of hooks all work on y
NB. let's start simpler:
X (] <) Y               NB. some train that boxes y
X (] <)~ Y              NB. swap args to box x instead
NB. combine them with a fork:
X ((]<)~ , (]<)) Y      NB. working solution!

NB. another way: by using a hook right verb can just be < as it is monad
X ((]<)~ <) Y           NB. problem: this combinator drops right arg
X (((]<)~ , ]) <) Y     NB. solution: use fork to combine with right arg

NB. another way: a fork combining two capped forks
X ( ([:<[) , [:<] ) Y

NB. some NVV-forks:
hi =: 'hello' ; ]
hi 'alice'
hi=:'hello' ; '!' ;~ ]  NB. only left operators may be nouns ->swap args
hi 'bob'
```

## Gerunds:

A gerund is a **list containing** (the boxed definitions of) **verbs**,
thus creates a noun from verb/s. It can be created with conjunction
`` ``` and applied in different ways with `` `:``. (see also: indexing)
```J
+ ` -                   NB. creates list of two verbs: + and -
- ` ''                  NB. this gerund only has one element: -
# +`-                   NB. length of the noun, which is a list of verbs

gerund =: +/ ` % ` #

NB. (m`:0) applies each verb in m separately
gerund`:(0) 1 2 3 4     NB. equivalent to:
>(+/1 2 3 4);(%1 2 3 4);(#1 2 3 4)

NB. (m`:6) creates a train from the verbs in m
gerund`:(6) 1 2 3 4
(+/ % #) 1 2 3 4        NB. equivalent; (computes the average)

gerund `:(3) 1 2 3 4 5  NB. used as cyclic gerund with monadic adverb /
1 +/ 2 % 3 # 4 +/ 5     NB. equivalent, see: cyclic gerunds
```

### Cyclic Gerunds:

Many modifiers which apply their verb multiple times may instead take a
list of verbs, from which to take one per needed application of a verb.
If there are too few verbs in the list, it is simply looped over again
as often as needed.

```J
+/ 1 2 3 4 5        NB. modifier / uses its verb multiple times
1 + 2 + 3 + 4 + 5   NB. equivalent
gerund / 1 2 3 4 5  NB. uses the verbs from gerund sequentially instead
1 +/ 2 % 3 # 4 +/ 5 NB. equivalent

NB. The rank operator " applies its verb to each cell(-pair)
(-&1) "0 (1 2 3 4 5)
(+&1) "0 (1 2 3 4 5)
(-&1)`(+&1) "0 (1 2 3 4 5)
```

## Names:

Variable-names may only contain

- ASCII-letters (upper and lowercase),
- numbers (but not as first character) and
- underscores (except leading, trailing or double).

```J
valid_name1 =: 'only ascii'
VALID_NAME1 =: 'case sensitive, '
VALID_NAME1, valid_name1

_invalid =: 1
2bad =: 2
err_ =: 3
```

Unknown variables are assumed to be verbs because nouns are evaluated
immediately when defined, so their variable parts have to exist
beforehand. Verbs, however, are only evaluated when used, so unknown
parts at the time of definition are ok. This also allows functions to
reference themselves!
```J
foo =: 10
] bar =: 1 + foo    NB. foo is noun, immediately evalueted: bar is 11

foo =: unknown + 1  NB. error executing monad unknown
foo =: 1 + unknown  NB. assumed verb without arg -> not evaluated -> ok
foo ''              NB. error unknown not found
unknown =: 10       NB. now unknown exists but:
foo ''              NB. error unknown not a verb
unknown =: 3 : '10' NB. now it is a verb (always returning 10)
foo ''              NB. ok

foo=:3 :'missing+1' NB. verb definition ok because not evaluated yet
foo ''              NB. error missing not found
missing =: 10
foo ''              NB. ok

fn =: {{
    if. y > 0 do.
        echo y
        fn y-1      NB. calling own name -> recursion
    end.
}}
fn 3
```

Variables create subexpressions just like parentheses do; imagine they
expand to their parenthesized value:
```J
N =: 2
1 N 3               NB. error: implicit joins are not allowed

- + 1 2 3           NB. how about creating an alias for this action?
action =: - +
action 1 2 3        NB. not the same result! it's a subexpression:
(- +) 1 2 3         NB. this subexpression creates a hook (train)
```

Each name lives in a namespace also called a locale:

## Namespaces:

Every function has its own local scope, that is an **unnamed
namespace** that cannot be inherited, thus a function defined within
another function does not have access to the outer function's namespace
(except using `u.` or `v.`; see: Applying modifiers to local variables).
```J
var =. 'global'     NB. outside function =. is equivalent to =:
fn1 =: {{
    var =. 'local'  NB. in a function =. writes to its local namespace
    fn2 =. {{
        echo var    NB. uses global var as there is no local var in fn2
        var2 =: '=: always writes to global scope'
    }}
    fn2 ''
    echo var2       NB. finds var2 in global namespace

    var2 =. 'local hides global of same name'
    echo var2
    erase 'var2'    NB. removes var2 from *its* scope (which is local)
    echo var2       NB. global version available again
    erase 'var2'    NB. careful: removes var2 from *its* scope (global!)
}}
fn1 ''
echo var2           NB. show that it's really gone again
```

Control-structures do *not* have their own namespaces. for_name-loops
always use the local scope to create/update the loop variables.
```J
foo =: 'global'
{{
    foo_index =. 'local'
    for_foo. 'abc' do. echo 'foo:'; foo; 'foo_index:'; foo_index end.
    echo 'foo:'; foo; 'foo_index'; foo_index
}} ''
echo 'global foo:'; foo
```

The second type of namespace is the **named namespace**/locale, of which
there may be many but at any time only one may be the **current/global
namespace**, which is inherited by any function('s local namespace) when
it is called. Inheriting means if a name is not found it is looked for
in the inherited namespace/s, which for new named namespaces is "z"
(where the standard helpers are defined) by default.
```J
conl ''             NB. shows available named namespaces
coname ''           NB. shows currently used named namespace (=global)
cocurrent <'base'   NB. switches global namespace to namespace "base"
    nl ''           NB. shows all names defined in global namespace
    nl 3            NB. show defined names of type: 0 1 2 or 3 (verbs)
    clear ''        NB. rm all names from given namespace or "base"
    nl ''
    echo'hi world'  NB. echo not defined -> where does it come from?
    copath <'base'  NB. shows list of namespaces "base" inherits: "z"
cocurrent <'z'      NB. make "z" the current=global namespace
    nl ''           NB. contains echo; use names'' for pretty display
cocurrent 'base'    NB. switch back
```

The examples showed that to evaluate a name in another namespace this
needs to become the global namespace first, as well as that namespaces
are addressed with strings. However, there is a simpler way of writing
this (but behind the scenes it does the same): **Locatives** are names
that specify a namespace either by appending its name in underscores or
by appending two underscores and the name of a variable that contains
the (boxed) name.

```J
names_z_ ''                 NB. pretty print names defined in "z"
var =: <'z'
names__var ''               NB. same
{{ for_ns. conl'' do.       NB. iterate over available namespaces
    echo coname__ns''       NB. locatives temporarily switch namespaces
end. }} ''
coname ''                   NB. back in original namespace
```

Note that in the last 4 lines the global namespace only changed during
the evaluation of the locative in `echo coname__ns''` but not while
executing `echo` with the result of `coname__ns''`. Moreover, while
`echo` too is a verb from another namespace, it is inherited and thus
does not change the global namespace! To use a locative-accessed verb
with the current global namespace use adverb `f.` to pull the verb into
the current namespace before executing it:

```J
fn_z_ =: fn =: {{ echo var }}

var_z_ =: 'during locative'
var =: 'during orig namespace'

fn 'executes fn from current namespace'
erase 'fn'
fn 'executes fn from inheritance'
fn_z_ 'executes fn from locative'
fn_z_ f. 'executes result of adverb (which gets fn from locative)'
```

Namespaces are automatically created when used.
```J
conl''
ns =: <'mynamespace'
echo__ns 'inherited echo from "z", the default parent'
copath ns           NB. show "mynamespace" inherits from "z"
```

## Applying modifiers to local variables:

Function-namespaces not being inheritable becomes a problem when
applying modifiers to local variables:

During evaluation phase 1 (see: Evaluation Rules) modifiers produce
verbs with identical body but `u` and `v` replaced with the operands of
the modifier, which were not yet evaluated. Then, during phase 2, the
verb encounters the unresolved name, tries to look it up and does not
find it since it does not have access to the caller's namespace.

If a modifier uses `u.`/`v.` instead of `u`/`v` the resulting verb
starts the lookup of a name they stand for from the scope of its caller!
Here is an example:
```J
F =: {{
    L =. +
    L adv y         NB. local var L stays unevaluated during phase 1
}}

adv =: 1 : 'u/y'
F 1 2 3             NB. error: unknown var: L

adv =: 1 : 'u./y'   NB. looks for name L from the scope of the caller F
F 1 2 3             NB. ok
```

## Classes, OOP:

In J, classes are simply namespaces whose instances (also namespaces)
inherit them. As assigning to inherited names just creates an own
version of the name in the inheriting namespace, shared fields need to
be accessed with a locative.

By convention `conew` is used to create new instances: It calls
`cocreate` with an empty argument resulting in a new namespace with a
stringified, previously unused, numeric name and then prepends the
class' namespace to the list of ancestors. Finally `conew` remembers the
namespace from which the new instance was created as the variable
`COCREATOR`. Another convenience of the `conew` verb is that its dyadic
version also calls the monad `create` with its left arguments. By
convention a destructor should be implemented as the monadic function
`destroy` calling `codestroy` which simply uses `coerase` on the current
namespace.

```J
coclass 'C'                 NB. coclass is just an alias for cocreate
    field =: 100

    create =: {{
        echo 'hi from C''s constructor'
        field =: y
    }}
    destroy =: {{
        echo 'hi from C''s destructor'
        codestroy''
    }}

    get =: 3 : 'field'
    inc =: 3 : 'field =: field +1'
    dec =: 3 : 'field =: field -1'
```

```J
cocurrent 'base'
    c1 =: conew 'C'         NB. wont call constructor
    c2 =: 1 conew 'C'       NB. calls constructor with its left args
    echo (get__c1''); get__c2''
    dec__c1''
    inc__c2''
    echo (get__c1''); get__c2''
```

This demonstrates creating a class inheriting from another, as well as
how to use class-variables (as opposed to instance-variables), by
creating a singleton, that is, a class that at any time may only have
one instance:
```J
coclass 'Singleton'
    NB. inherit from "C":
    NB. ('C'; (copath cocurrent'')) copath cocurrent''
    NB. or simply:
    coinsert 'C'

    NB. Shall be used as class-variable (=shared by instances)
    hasInstance =: 0

    NB. IMPORTANT:
    NB. * Avoid using knowledge about internals of parents. Stick to
    NB.   their functions as much as possible!
    NB. * Avoid recursion when overriding functions by using a locative.
    NB. * Avoid executing the locative in parent by using the f. adverb!

    create =: {{
        echo 'hi from Singleton''s constructor'
        echo 'Singleton''s parents are: ', ": copath 'Singleton'
        if. hasInstance_Singleton_ do.
            throw. 'Cannot create more than 1 instance of a singleton.'
        end.

        create_C_ f. y

        NB. If "C"'s constructor throws, this does not run.
        NB. Use locative to write to class-var not instance-var:
        hasInstance_Singleton_ =: 1
    }}

    NB. This shows why the destory function should always be implemented
    NB. and used to dispose of instances: Some classes are intended to
    NB. execute specific destruction behaviour but coerase does not call
    NB. any destructors. Singleton breaks if hasInstance isn't reset:
    destroy =: {{
        echo 'hi from Singleton''s destructor'
        hasInstance_Singleton_ =: 0

        destroy_C_ f. ''
    }}
```

```J
cocurrent 'base'
    NB. show "Singleton"'s ancestors/parents (namespaces it inherits):
    copath 'Singleton'

    s1 =: 111 conew 'Singleton'
    get__s1 ''

    {{ try.
        s2 =: 222 conew 'Singleton'
    catcht.
        echo 'Caught SingletonException: Already has an instance!'
    end. }}''

    destroy__s1 ''
    s2 =: 333 conew 'Singleton'
    get__s2 ''

    NB. clean up:
    {{
        for_insta. s2; c1;c2 do. destroy__insta'' end.
        coerase 'Singleton'
        coerase 'C'
        for_name. 's1';'s2'; 'c1';'c2' do. erase name end.
    }}''
```

## Indexing:

How indices work in J:

- The first element has index `0`.
- Negative indices select from the back (thus the last element can be
  accessed with index `_1`).
- Each element in an index is a separate selection (of what differs per
  verb).
- An *unboxed list* of indices selects (multiple of) the array's
  top-level elements, because each element is a separate selection and
- *trailing* axes/dimensions may be omitted, resulting in all their
  elements being selected.
- Top-level boxes (**1st boxing level**) contain paths, that is lists of
  *selections per axis/dimension* of an array. In other words: Each
  element in a box selects on a different axis/dimension of the array,
  which effectively means they subindex the previous result.
- To select several elements on the same axis/dimension group them in
  another box (**2nd boxing level**).
- *Instead*, elements can be excluded per axis/dimension by wrapping
  them with another two boxes (**3rd boxing level**).
- To select all elements of an axis/dimension exclude none by putting an
  empty array at the third boxing level (`<<<''` or `<<a:`).
- Keep in mind that `;` doesn't add a boxing level to a boxed right
  argument!

The verb `{` can index arrays but not boxes. Every element in its left
argument is a new selection starting from the same dimension (that the
verb was applied to).
```J
{ b.0                   NB. show ranks of {
] a =: i. 4 4
0 { a                   NB. first
0 {"1 a                 NB. "1 provides lines and loops -> first col
_1 { a                  NB. count from back
0 0 { a                 NB. separate selections starting at same level
(<0 0) { a              NB. top-level boxes contain paths
(1 1; 2 2) { a          NB. separate selections with paths
(1; 1 1) { a            NB. different length results need padding
(<(<0),(<1 3)) { a      NB. select multiple elements per axis in path
(<(<a:),(<<_2)) { a     NB. exclude per axis (excl none = select all)
```

To **replace elements** use the `}` adverb that is used like `{` with an
additional left argument specifying the replacement/s:
```J
(2) 1 } 1 200 3
' ' (<(<<_1),(<1)) } 4 4 $ 'abcdefghijklmnop'
(2 2 $ '1234') (<(<1 2),(<1 2)) } 4 4 $ 'abcdefghijklmnop'

orig =: 'immediate reassigment modifies in-place (prevents copy)'
copy =: orig        NB. creates copy instead of pointing to same object
orig=: 'I' 0 }orig  NB. reassigning to same name is in-place (efficient)
> orig ; copy       NB. show that copy is indeed unchanged
```

To be able to write index getters that work for any array `}` accepts a
dyad as left argument: It takes the replacement/s as left and the
original array as right argument and returns the indices *of a flattened
version of the array* at which to replace values.
```J
_ (1) } i.2 3       NB. noun-indices access the unflattened array
_ 1: } i. 2 3       NB. indices from functions are for flattened arrays

1 0 2 # 'abc'       NB. dyad # copies corresponding element in y x-times
, i.2 2             NB. monad , flattens an array
fn =. 4 : 0
    Y =. , y        NB. flattened y
    bitmask =. x>Y  NB. where replacement greather than element...
    bitmask # i. #Y NB. ...keep, else drop index from flat-indices list
)
0 fn } 2 6 $ foo =: _4 2 9 3 8 5 _7 _2 3 1 _3 2
0 fn } 2 2 3 $ foo
```

**Ranges** can be conveniently specified with (combinations of) the
following verbs:
```J
] digits =: i.10
    {: digits       NB. last            (no dyadic version)
    {. digits       NB. first
  3 {. digits       NB. first 3
 _3 {. digits       NB. last 3
2 1 {. 3 3 $ digits NB. first 1 of first 2
    }: digits       NB. drop last     (no dyadic version)
    }. digits       NB. drop first
  3 }. digits       NB. drop first 3
 _3 }. digits       NB. drop last 3
1 2 }. 3 3 $ digits NB. drop first 1 then first 2 (reshaping dropped 9)

3}. 7{. digits      NB. range from (incl) 3 to (excl) 7
```

### Indexing Boxes:

`{::` is like `{` but *opens its results* and uses *each path to
continue indexing into the previous result* instead of returning to the
starting level and producing more result values. The final *result is
not opened if* it is not a single box or the *last path's last part is a
list* (monad `,` can be used to promote a scalar to rank 1). `{::` only
works with paths because it will wrap lists of numbers in a box first.
```J
]a =: 1 2 3; 4 5 6; 7 8 9
(1;1) { a               NB. paths start at same level
(1;1) {:: a             NB. paths continue indexing previous result
]a =: <<"0 i.3 3
(0;1 1) {:: a           NB. final scalar box result is opened, except:
(0;(<1;,1)) {:: a       NB. last path's last part is a list due to ,y
(0; 1) {:: a            NB. not opened because result isn't a scalar box
(0; (<(<<1))) {:: a     NB. excluding stuff etc works as it would with {
```

### Indexing Gerunds:

As gerunds (see: gerunds) are simply lists of boxed verb-definitions,
they could be indexed like any other list; however, this would not
return an executable verb! Conjunction `@.` takes an index as right
argument and returns the corresponding verb from the gerund on the left
in executable form. Selecting multiple verbs returns a train (see:
trains) and parentheses can be set by boxing the indices accordingly.
(See also: conditional application)
```J
gerund =: +/ ` % ` # ` -
div =: gerund @. 1
div
1 div 2
from_mean =: gerund @. (< _1 ; 0 1 2)
from_mean
from_mean 1 2 3 4
```

## Idiomatic Replacements for Explicit Control-Structures:

The control-structures described above (see: explicit control-structures
and control-words) can be replaced with more idiomatic versions which
also work outside of explicit functions.

Note: Experimenting with the code in this section can easily result in
non-terminating ("infinite") loops! To abort them either kill the
process, which looses the session data, or call `break''` in another J
session. When running J from the terminal you can hit ctrl-c to break.

### Repeated Application:

To apply a verb a certain amount of times (each time on the previous
result), either dyadically apply the result of creating a monad from a
dyad with `&` or use conjunction `^:`:
```J
arg =: 100
< < < arg           NB. "applying a verb (here <) 3x"
3 -&1 arg           NB. apply resulting monad 3x
-&1 ^:3 arg         NB. apply given monad 3x
-&1 ^:1 arg         NB. apply 1x
-&1 ^:0 arg         NB. applying 0x returns arg unchanged

NB. dyadic application of ^: first creates a monad!
'x' ,^:3 'y'        NB. bind left arg of dyad (here 'x'&,) then apply 3x
```

Conjunction `^:` may take a verb instead of an explicit amount of
repetitions, which is called with the argument/s of the construct. Note:
A left argument is first bound to the repeating verb to create a monad!
```J
printer =: {{ echo 'printing ticket for 1 ', >x }}
make_tickets =: printer ^: {{
    if. x = <'child' do.
        +/ 18 > y
    else. +/ y > 17
    end.
}}
ages =: 36 42 9 13 71
(<'child') make_tickets ages    NB. calls (<'child')&printer repeatedly
(<'adult') make_tickets ages    NB. calls (<'adult')&printer repeatedly
```

Run a verb **until its result stops changing** (that is consecutive
iterations return the same result) by using infinity as repetition
count:
```J
dec_bottom0 =: {{
    if. 0 > new =. y-x do.
        0 [ echo 'subresult: ', ": 0
    else. new [ echo 'subresult: ', ": new
    end.
}} "0

1&dec_bottom0 ^:(_) 5
_ (1&dec_bottom0) 5
NB. - ^:(_) 5       NB. wont terminate: consecutive results never same
```

Running the **same loop different amounts of times** is simply done by
providing a list of repetition counts. This can be used to return
subresults (which are not boxed!):
```J
3 (-&1) arg         NB. 3x ...
1 2 3 (-&1) arg     NB. ... with subresults
-&1 ^:(1 2 3) arg   NB. same

NB. not same, despite result:
(-&1 ^:1 arg), (-&1 ^:2 arg), (-&1 ^:3 arg)

NB. to better illustrate why it is not the same:
(1&dec_bottom0 ^:(1) 5),(1&dec_bottom0 ^:(2) 5),(1&dec_bottom0 ^:(3) 5)
1&dec_bottom0 ^:(1 2 3) 5
```

Providing the repetition count as a box is a recognized pattern to
**capture the subresults**. A box is interpreted as `i.>n`-repetitions
(except when the boxed value is empty or infinity, which both create an
infinite loop). Therefore, the construct only loops up to n-1 times and
includes the original argument as first result! Consequently subresults
must have the same type as the original argument.
```J
3 (-&1) arg         NB. 3x ...
1 2 3 (-&1) arg     NB. ... with subresults
(<3) -&1 arg        NB. ... interpreted as 0 1 2 (=i.3) repetitions
-&1 ^:(<3) arg      NB. equivalent

1&dec_bottom0 ^:(<_) 5
a: (1&dec_bottom0) 5
```

### Conditional Application:

A **simple conditional** either executes a branch or doesn't. In other
words: a verb is executed `1` or `0` times. Replacing the number of
repetitions with a boolean-expression is enough to create a conditional
because J's booleans are simply the numbers `0` and `1`:
```J
NB. children (<18) only pay 75%
price =: 15
ages =: 36 42 9 13 71
(18 > ages) 0.75&* price        NB. bool_expr bound_arg_action arg
*&0.75 ^:(18 > ages) price      NB. action ^: bool_expr arg
```

**Multiple branches** can be expressed with a gerund and passed as left
argument to conjunction `@.` (see: indexing gerunds), which calls the
selected branch with the given argument/s. The noun index as right
argument to `@.` may be replaced by a verb to generate it; this is also
called with the argument/s to the construct:

```J
NB. note that it's important whether the verbs are monads or dyads:
{{price}} ` {{price*0.75}} @. (18>]) "0 ages        NB. noun indexing
{{price}} ` {{price*0.75}} @. {{18>y}} "0 ages      NB. called as monads
price [ ` {{x*0.75}} @. (4 :'18>y') "0 ages         NB. called as dyads
ages ] ` (4 :'y*0.75') @. {{18 > x}} "0 price       NB. swapped args

NB. more branches: ages >70 pay 70%, <18 pay 50%    NB. adding booleans:
price {{x*0.5}} ` [ ` {{x*0.7}} @. (4 :'(>&70 + >&17) y') "0 ages
```

### Conditional Repetition:

To create **while-loops** an infinite loop can be combined with a
conditional: once the condition fails its argument is returned
unchanged, thus reused in the next iteration and again returned which
then ends the loop, due to consecutive non-unique results.

```J
1&dec_bottom0 ^:(>&3)^:(_) 8
1&dec_bottom0 ^:(>&3)^:(a:) 8

NB. using a multi branch conditional:
{{ y[ echo 'done'}} ` {{ res[ echo res=. y-1}} @. (>&3) ^:(a:) 8

NB. here the condition is never true -> returns unchanged arg
1&dec_bottom0 _1    NB. but here it's never even called:
1&dec_bottom0 ^:(>&3)^:(a:) _1
```

### Looping with More Control:

The 6 conjunctions `F.`, `F:`, `F..`, `F.:`, `F:.` and `F::` are
collectively known as Fold. Usage: `x? u Fold v y`

Fold creates a **loop which invokes `v` on the previous result** of `v`
and **then allows to postprocess (even discarding) the result** with
`u`. However, the result of `u` is never the input to `v`.

If the first inflection (appended "." or ":") of Fold is "." only the
last result is kept, while ":" combines the subresults into a final
result (which pads subresults if necessary and thus the last result
might differ from a Fold with a single result).

`F.` and `F:` create an infinite loop which has to be exited explicitly.
They always provide `x` (if given) unchanged as left argument to `v` and
use `y` as a whole as initial right argument.

Dyad `Z:`, which may be used in `u` and `v`, provides control over
Fold-created loops, similar to `break.` and `continue.` in explicit
loops. Its effect is determined by its left argument and only activated
if the right argument is not `0`:

- `_3`: Raise "fold limit"-error (thus no result) if loop already ran
  given (as right argument) number of times. Note that `_1 Z: 1` in `v`
  does not increment the iteration count and thus might create an
  infinite loop which is not caught by `_3 Z: n`...
- `_2`: Immediately exit the loop. `u` never runs or completes, thus
  this iteration does not contribute to the overall result. Raises
  "domain error" if overall result is empty.
- `_1`: Immediately exit current function and start the next iteration
  with the result of `v` if in `u` or the previous result of `v` if in
  `v`. `u` never runs or completes, thus overall result stays unchanged.
  Note the danger of using this in `v` of `F.` or `F:` (see: above).
- `0`: Current iteration is not aborted, but the result of `u` is
  discarded.
- `1`: Exit after finishing current iteration.

```J
double =: *&2

NB. raises error in 5th iteration
NB. F: and F. as dyads always use original x argument
res =: 2 {{ y [_3 Z: 5 }} F: {{ x+y [echo x;y }} 0
res

NB. stop once results are greater than 20
NB. F: and F. as monads apply v monadically, contrary to the other Folds
res =: {{ y [_2 Z: (y > 20) }} F: {{ ([ echo) double y }} 1
res
NB. Fold-Single only keeps last result
res =: {{ y [_2 Z: (y > 20) }} F. {{ ([ echo) double y }} 1
res

NB. discard result if it is 8; regardless, it is used as previous value
{{ y [echo'afterwards';y [_2 Z:(y>20) [_1 Z:(y=8) }} F: {{double y}} 1
NB. In contrast (0&Z:) doesn't abort current iteration, only discards
NB. current result:
{{ y [echo'afterwards';y [_2 Z:(y>20) [ 0 Z:(y=8) }} F: {{double y}} 1

NB. do not use (_1 Z: 1) in v when using F. or F: as it creates an
NB. infinite loop which is not caught by (_3 Z: n)
NB. {{ y [_3 Z: 10}} F: {{ new [_1 Z: (new=8) [echo new=: double y}} 1

NB. finish current iteration and exit loop
{{ y [echo'afterwards';y [ 1 Z:(y=8) }} F: {{double y}} 1
```

The other fold variants use `x`, if given, as initial right argument to
`v` and one item of `y` per iteration as left argument. The items of `y`
are used in order if the second inflection is "." and in reverse if it
is ":". If `x` is not given, the first/last item of `y` is used as
initial right argument and the second/-to-last item is the first left
argument to `v`.

```J
]Y =: 1+i.5
  ]F:., Y           NB. forward order, not postprocessed, needs padding
  <F:., Y           NB. postprocessed but , uses unprocessed prev result
  <F::, Y           NB. reverse order
0 <F:., Y           NB. forward with different first y argument
0 <F::, Y           NB. reverse with different first y argument
0 <F.:, Y           NB. same but only keep final result
0 <F.., Y           NB. same but forward

NB. (_1&Z:) can be used safely in v with F.. F.: F:. and F::
0 <F:. {{x,y [ _1 Z:(x=3)}} Y
```

### Idiomatic Error Handling:

Conjunction `::` (required leading space) allows to provide an
alternative verb in case left verb fails (called with same arguments):
```J
try =: {{echo 'Hello, ', y, '!'}}
except =: {{echo (": y), ' does not seem to be a string...'}}
try :: except 'Foo'
try :: except 123
1 try :: except 2       NB. handler for dyad must have dyadic version
except =: {{)d
    except f. ''        NB. avoid recursion by localizing variable first
    :
    'Error: not a dyad'
}}
1 try :: except 2

try :: 'Handler may be a noun to return on failue!' 123
```

## Argument preprocessing:

Conjunction `^:` can be used with a gerund to preprocess the arguments:
```J
  u^:g y =          u^:(  g1 y) (  g2 y)
x u^:g y = (x g1 y) u^:(x g2 y) (x g3 y)
```
```J
echo ^: (1: ` {{(": y*100), '%'}}) 0.75
NB. convert left arg to string, apply 1x, keep right arg unchanged:
1 2 3 ,^:({{":x}} ` 1: ` ] ) 'abc'
NB. dyadically used but gerund only has 2 elements: use x unchanged
'abc' ,^:(1: ` (4 :'":y')) 1 2 3
```

## Inverse and Tacit Functions:

Many (mostly monadic) builtin verbs define an **inverse function** to
undo their effect. The inverse of these *monads* can be *shown* with
argument `_1` to adverb `b.`.

An explicit function does not have an inverse by default, but one can be
set with conjunction `:.` (required leading space!) and is then part of
the verb definition which becomes, as a whole, the result when querying
the inverse.

For **tacit functions** (functions without a body and thus namespace,
that do not refer to their arguments) J tries to generate an inverse
automatically; it can be corrected by explicitly assigning one with
`:.`. J tries to convert a simple explicit body to a (*similar*) tacit
verb when `13` is used as function type in an explicit definition.

**Repeating a negative amount of times** prompts J to repeat the inverse
and is the intended way of explicitly calling inverses.

```J
< b._1              NB. show inverse of monad < which is monad >
fn =: >             NB. tacit function -> J guesses inverse
fn b._1
fn^:(_3) 'hi'       NB. call inverse of fn 3 times

NB. explicit function -> no automatic inverse generated
fn =: {{
    y+y
    :
    x+y
}}
fn b._1             NB. error: no inverse

NB. assigning an inverse
fn =: fn f. :. {{
    y%2
    :
    x-y
}}
fn b._1             NB. the shown inverse is the whole definition
NB. testing the verb
fn 1                NB. monad
fn^:(_1) fn 1       NB. inverse of monad
2 fn 3              NB. dyad
5 fn^:(_1) 2        NB. inverse of dyad
5 fn^:(_1) 3

NB. let J generate tacit verb so it guesses inverse too
]fn =: 13 : 'y^y'
fn b._1             NB. I didn't know that...
fn 3
fn^:(_1) fn 3
```

## Tacit replacements for constant functions:

Functions returning the same value no matter their argument/s are called
constant. Nice tacit constant functions for the ten digits, infinity and
their negative variants were already introduced. Any noun can be
converted to a constant function by calling the rank operator with
infinity on it!

```J
explicit =: {{      NB. multiline
    _9
    :
    9               NB. typo
}}
specialFn =: _9:    NB. only for digits, infinity and their negatives
tacit =: _9 "_
verbs =: explicit ` specialFn ` tacit `:0
verbs 'as monads'
'call' verbs 'as dyads' NB. note the typo from above
```

## Composition:

On the interactive session prompt it is easy to pipe the result of one
verb into another verb: Simply put the second verb's name before the
first one's. However, it seems assigning this pipeline to a name does
not work (see: names), as it creates a train (see: trains). Instead, the
verbs need to be *composed* with a conjunction:

```J
< (1&+) 1 2 3               NB. box the incremented values
pipeline =: < (1&+)         NB. creates a train
pipeline 1 2 3              NB. thus is not expected result
pipeline =: < @: (1&+)      NB. this however does give expected result:
pipeline 1 2 3
```

Each composition conjunction exists as **two variants**: One which
passes the whole argument/s to the pipeline (aka rank infinity) and ends
in ":" and one whose rank (mostly) depends on the rank of the first verb
of the pipeline, essentially applying the later verbs on each result
returned by the first verb, instead of the collected results.

This calls a **monad on** the result of another **monad**. Note that the
usage of monadic pipelines created with `&` or `&:` is discouraged as
they are not recognized as performance optimized patterns!
```J
NB. these are equivalent only when called monadically:
(B @: A) y = B A y
(B &: A) y = B A y          NB. functionally equivalent but discouraged
NB. pipeline has monadic rank of A:
(B @ A) y = (B @: A)"A y
(B & A) y = (B &: A)"A y    NB. functionally equivalent but discouraged
```
```J
# @:(>"0) 1;2;3             NB. length of combined results
# @ (>"0) 1;2;3             NB. lengths of results
NB. functionally equivalent but discouraged:
# &:(>"0) 1;2;3
# & (>"0) 1;2;3
```

Calling a **monad on** the result of a **dyad**:
```J
x (B @: A) y = B x A y
NB. pipeline has dyadic ranks of A:
x (B @ A) y = x (B @: A)"A y
```
```J
1 2 3 < @:(,"0 0) 4 5 6     NB. box collected results
1 2 3 < @ (,"0 0) 4 5 6     NB. box each result
1 2 3 < @:(,"0 1) 4 5 6
1 2 3 < @ (,"0 1) 4 5 6
```

Call a **dyad on** the results of the **arguments individually
processed by a monad** like so:
```J
x (B &: A) y = (A x) B (A y)
NB. pipeline (effectively B) has monadic rank of A (as dyadic rank):
x (B & A) y = x (B &: A)"({.A b.0) y        NB. (A x) B"({.A b.0) (A y)
```
```J
(1;2;3) ,&:(>"0) (4;5;6)    NB. join unboxed args
(1;2;3) ,& (>"0) (4;5;6)    NB. join atom pairs of unboxed args
(<"0 i.3 2) ;&:(>"1) (<"(0) 6+i.3 2)
(<"0 i.3 2) ;& (>"1) (<"(0) 6+i.3 2)
```

`&.` and `&.:` work like `&` and `&:` (monad on monad or dyad on
result-pairs of arguments processed by monads) but **also apply the
inverse** (see: inverse and tacit functions) of the first verb as the
third verb in the pipeline!
```J
  (B &.: A) y = A^:_1 B A y
x (B &.: A) y = A^:_1 (A x) B (A y)
NB. the pipeline's rank/s are the mondic rank of A:
  (B &. A) y =  ((B &.: A)"A) y
x (B &. A) y = x (B &.: A)"({.A b.0) y
```
```J
(1&+) &.:(>"0) (<"0 i.2 2)  NB. unbox, increment, box collected results
(1&+) &. (>"0) (<"0 i.2 2)  NB. unbox, increment, box each result

] Xb =: <"0 X =: 'ABCD'
] Yb =: <"0 Y =: 'abcd'
Xb (,"_)&.:(>"0) Yb
Xb (,"_)&. (>"0) Yb
```

If only one side needs processing, a 2-element gerund is used with an
empty box marking the side not to modify; the second verb now uses its
own monadic rank on the unprocessed side:
```J
x B &.:(a:`A) y = A^:_1 x B (A y)
(x B &.:(A`a:) y = A^:_1 (A x) B y)
NB. pipeline's ranks: respecitve dyadic rank of B and monadic rank of A:
x B &. (a: `A) y = x B &.:(a:`A) "((1{B b.0),{.A b.0) y
(x B &. (A `a:) y = x B &.:(A`a:) "(({.A b.0),2{B b.0) y)
```
```J
X (,"_ _ _)&.:(a:`(>"0)) Yb
X (,"_ _ _)&. (a:`(>"0)) Yb NB. !!
NB. The previous example was not the same as the version without gerund
NB. because the version with gerund uses one of B's own dyadic ranks,
NB. while the other version only used A's monadic rank for both sides
X (,"_ 0 _)&. (a:`(>"0)) Yb NB. this behaves like without gerund

NB. when the noun to process is on the other side:
Xb (,"_ _ _)&.:((>"0)`a:) Y
Xb (,"_ _ _)&. ((>"0)`a:) Y
Xb (,"_ _ 0)&. ((>"0)`a:) Y
```

# Appendix

## J shell scripts:

J scripts are plaintext files, should use the extension `.ijs` and
may have a _shebang as first line_ (`#!` + the path to the J
executable).

_Arguments_ to the script are saved as boxed strings in variable
`ARGV_z_` in elements 3 and higher; element 2 is the path of the script
(as used on the commandline) and the first and only argument which is
always available is the name of the command which invoked the process
(as used on the commandline; usually `jconsole`). Arguments to the J
interpreter, which are not passed to the script, are not listed in
`ARGV`. Thus in a script invoked like with
`../j9.4/bin/jconsole -noel ./file.ijs foo 123` has
`ARGV -: '../j9.4/bin/jconsole';'./file.ijs';'foo';'123'` while just
running the interpreter from PATH interactively (`jconsole`) only has
`ARGV -: <'jconsole'`.

To access _environment variables_ use verb `getenv` which returns boolean
`0` if it is not defined. (Note: environment variables have to be
strings thus the boolean cannot be confused with a value `'0'`.)

Use verbs `stdout` and `stderr` to write to these file-descriptors and
do _not_ append a newline (unlike `echo`).

Stdin is interpreted as input to the **interactive session which starts
after the interpreter finished the supplied script** -- unless the
script prevents starting the interactive session by _terminating
explicitly_ with `exit` (takes the number which shall be the process'
exit/return code as argument), or _consumes stdin_ with verb `stdin`,
which returns it as a string. Since `stdin` and `stdout` are inverses,
outputting the transformation of user input can be written conveniently
using `&.`; for example the script `|. &. stdin ''` reverses the input
and could be executed like so:
`echo -n -e 'hello\nworld' | jconsole script.ijs`
A string can be split into boxed lines using monadic `cutopen`.

## String Representation and Unicode:

Note: For this section to display properly a font with support for emoji
needs to be used. If in the terminal J does not accept input of
non-ASCII characters start it with the `-noel` parameter.

J's default **string type**, "**literal**", treats 8 bits (1 byte) as an
atom. This works well for the first 128 ASCII characters, which are
equivalent to their UTF-8 representation and only need a single byte to
be stored. Other letters are represented by more bytes in UTF-8, which
makes them hard to work with. To fix this UCS-2 encodes every letter as
2 bytes, which can be interpreted as 1 atom by using J's type
"**unicode**". However, when UTF-16 (UCS-2 superset) came one could not
rely on 1 glyph being 1 "unicode" atom anymore: it may be 2. Luckily
UCS-4, also called UTF-32, encodes every glyph with exactly 4 bytes,
which can be treated as a single atom with J's type "**unicode4**". Be
careful when converting to a representation with bigger atoms to use an
operation which merges surrogate pairs (the multiple atoms representing
a single glyph) into a single atom; when converting "unicode" to
"unicode4" J would still understand it but it would not be valid UTF-32.

The verb `u:` provides access to unicode related functionality:
- monad `u: string` is `2 u: string`
- monad `u: number` is `4 u: number`
- dyad: left arg is:
    1. truncate to 1-byte precision
    2. extend or truncate to 2-byte precision
    3. convert to UCP (Unicode Code Point, a number)
    4. get UCP in UCS-2 range (<65536) as "unicode"
    5. like `1&u:` but raise error if discarding non-zero bits
    6. from literal UTF-16: each 2 bytes become 1 atom of type "unicode"
    7. convert (literal as UTF-8) to smallest string type needed;
       get any UCP as "unicode"
    8. convert to UTF-8;
       get any UCP as UTF-8 encoded "literal"
    9. convert string (literal as UTF-8) to type "unicode4" except when
       all ASCII;
       UCPs as "unicode4" (merges surrogate pairs)
    10. convert each *atom* of string to "unicode4", therefore this
        does not give valid UTF-32 if surrogate pairs are present (fix
        with 9&u:);
        get any UCP as "unicode4"

```J
2 5 $ 'helloworld'
2 5 $ 'hellöwörld'      NB. doesn't work because:
3 u: 'ö'                NB. ö is UTF-8 character represented by 2 atoms
3 u: 7 u: 'ö'           NB. convert to type unicode -> 1 atom
2 5 $ 7 u:'hellöwörld'
2 5$ 7 u:'hell😈w😈rld' NB. doesn't work because:
3 u: 7 u: '😈'          NB. emojis use 2 atoms in UTF-16 encoding
3 u: 9 u: 7 u: '😈'     NB. convert to type unicode4 -> 1 atom
3 u:10 u: 7 u: '😈'     NB. careful: 10&u: converts atoms individually:
                        NB. the UPCs are the same but use 4 bytes each
3 u: 9 u: 10 u:7 u:'😈' NB. use 9&u: to fix such a unicode4 string
2 5 $ 9 u:'hell😈w😈rld'
NB. convert each letter to UTF-8 encoded literal string and show bytes
< @ (3&u:) @ (8&u:) "(0) 9 u:'hell😈w😈rld'
NB. demo 7&u: converts to smallest string type needed for representation
datatype @ (7&u:) @ (8&u:) "(0) 9 u:'hell😈w😈rld'
datatype @ (7&u:) "(0) 9 u:'hell😈w😈rld'
NB. demo 9&u: converts to ASCII if possible else to unicode4
datatype @ (9&u:) @ (8&u:) "(0) 9 u:'hell😈w😈rld'
datatype @ (9&u:) "(0) 9 u:'hell😈w😈rld'
NB. extends or truncates to 2 byte procesion; this is not conversion!
2 u: 9 u: '😈'          NB. throws away one byte -> different glyph
datatype 2 u: 'a'

NB. adding strings
datatype (7 u:'a'),(9 u:'b')
datatype (7 u:'ö'),(9 u:'a')
datatype (7 u:'a'),(9 u:'ö')
NB. mind surrogate pairs, use 9&u: to fix it:
3 u: (7 u: '😈'), (9 u: '😈')
3 u: 9 u: (7 u: '😈'), (9 u: '😈')

NB. UCP to string
4 u: 246                NB. to unicode string; ensures 1 glyph = 1 atom:
4 u: 128520             NB. which is not true for UCPs >65535
7 u: 128520             NB. to unicode string; might be 2 atoms
9 u: 128520             NB. to unicode4 string
3 u: 9 u: 55357 56840   NB. to unicode4 string, wont merge surrogates
3 u:9 u:9 u:55357 56840 NB. use 9&u: to fix it
```

## Covered Builtins:

"conjunct" = conjunction
```
comment     NB.         comment rest of line
noun        _           infinity, but as number-prefix: negative sign
syntax      ()          subexpressions are parenthesized
syntax      ''          string (which is a *list* of literals)
monad       -           negate-number (use -. (not) to negate booleans)
dyad        -           subtract
dyad        ,           join lists
dyad        +           addition
monad       +           complex conjugate
adverb      /           puts verb between elements of new verb's arg/s
conjunct    m&v         convert dyad v to monadic verb with x fixed to m
conjunct    u&n         convert dyad u to monadic verb with y fixed to n
dyad        ^           power: x to the y
assignment  =:          assign to global namespace
assignment  =.          try assigning to local namespace else to global
monad       [           return argument unchanged
monad       ]           return argument unchanged
dyad        [           return x unchanged
dyad        ]           return y unchanged
monad       load        executes file or shortname (alias for some file)
monad       scripts     show shortnames
monad       loadd       like load but print each line before executing
monad       require     like load but only if was not loaded already
conjunct    :           define entities
syntax      )           end multiline explicit definition
monad       echo        output message
ambivalent  __: _9: ... 0: ... 9: _: ignore arg/s and return digit
syntax      :           separate monadic and dyadic bodies
monad       ":          convert to displayable byte array
dyad        *           multiplication
dyad        %           division
monad       %           1 divided by y
monad       names       pretty print names defined in current namespace
conjunct    !:          access lots of system functions
(dyad       o.          access to circle functions (sin, cos, ...)     )
syntax      {{          opens a direct definition
syntax      {{)n        open direct definition of type n (or a, c, m, d)
syntax      }}          close DD
monad       $           get shape
monad       #           get length
dyad        $           reshape array
monad       <           box
monad       >           unbox/open
noun        a:          empty box
dyad        ;           join as boxes
dyad        =           compares corresponding atoms
syntax      assert.     error if not all 1s
syntax      if.         if block ends at do.
syntax      do.         ends a condition block
syntax      elseif.     else-if block ends at do.
syntax      else.       else block ends at end.
syntax      end.        ends a control structure
syntax      select.     target value/s to match against; ends at f/case.
syntax      case.       test value/s to match target; ends at do.
syntax      fcase.      like case. but invoces next f/case.; ends at do.
dyad        >           is x greater than y?
syntax      while.      checks condition before every loop; ends at do.
syntax      whilst.     like while. but runs at least once; ends at do.
syntax      for.        loop once for each item in clause; ends at do.
syntax      for_var.    like for. but sets var to item
syntax      return.     return last value or *left* arg
verb        9!:8        returns list of default error messages
verb        dberr       return last error's number
verb        dberm       return last error's message
verb        dbsig       equivalent to (13!:8)
verb        13!:8       raise error y; optional: custom message x
syntax      try.        handle errors in block; ends at catch/d/t.
syntax      catch.      handle normal errors (not error 55 = throw.s)
verb        dbr         disable (arg 0) or enable (1) debugging mode
verb        dbq         query debugging mode state
verb        dbs         shows debug stack
verb        dbnxt       continue program on next line
syntax      catchd.     replacement for catch. pauses when debugging
syntax      throw.      exit fn, goes up callstack until finds catcht.
syntax      catcht.     handles error 55 (throw.s) in *called* functions
monad       i.          get integer sequence in shape of argument
adverb      b.          call with arg 0 to show ranks of verb
conjunct    "           change ranks of verb
adverb      ~           swap arguments or copy right arg to left side
syntax      [:          x?([: B A)y becomes (B x?Ay)
conjunct    `           make list of verbs (gerund)
conjunct    `:          execute a gerund in a certain way
monad       conl        boxed list of namespaces
monad       coname      get name of current namespace
monad       cocurrent   switch to namespace
monad       nl          boxed list of names defined in current namespace
monad       clear       remove names defined in given/'base' namespace
monad       copath      ancestors of *given* namespace
adverb      f.          pull name into current namespace
monad       erase       remove given names from *their* namespace
operand     u.          resolves modifier's operand u in caller's scope
operand     v.          resolves modifier's operand v in caller's scope
monad       conew       create new instance of class
monad       cocreate    creates new namespace, numeric if empty y
dyad        conew       create new instance and pass x as args to create
monad       codestroy   remove current namespace
monad       coerase     remove namespace
monad       coclass     switch to namespace
dyad        copath      set ancestors of namespace
monad       coinsert    prepend ancestors of current namespace
dyad        {           index into array
adverb      }           return copy of array with replaced elements
dyad        #           repeat curresponding elements x-times
monad       ,           flatten array; scalar becomes list
monad       {:          last element
monad       {.          first element
dyad        {.          first/last x elements
monad       }:          except last element
monad       }.          except first element
dyad        }.          except first/last x elements
dyad        {::         index into boxed structure
conjunct    m@.n        index gerund m
monad       break       abort exec in session with given or default tag
conjunct    x m&v y     apply monad m&v x-times
conjunct    x u&n y     apply monad u&n x-times
conjunct    u^:n        apply u or (x&u if x given) n-times
conjunct    u^:v        call v on arg/s to get amount of repetitions
conjunct    m@.v        call v on arg/s to get index of verb in m to run
conjunct    F.          infinite fold single
conjunct    F:          infinite fold multiple
dyad        Z:          exit fold according to x; do nothing if y is 0
conjunct    F..         fold single forward
conjunct    F.:         fold single reverse
conjunct    F:.         fold multiple forward
conjunct    F::         fold multiple reverse
conjunct    ::          if left verb throws run right verb
adverb      b.          call with arg _1 to show inverse
conjunct    :.          right verb is inverse of left verb
conjunct    13 :        tries to convert function body to tacit verb
conjunct    @:          as monad: monad>monad; as dyad: dyad>monad
conjunct    @           like @: but calls left on each subresult
conjunct    &:          as dyad: monads>dyad; as monad: like @:
conjunct    &           like &: but calls left on each subresult
conjunct    &.:         like &: but finally calls inverse of right verb
conjunct    &.          like &.: but call left>inverse on each subresult
noun        ARGV_z_     process name; [script name; [script arg1; ...]]
monad       getenv      return environment variable y or 0 if undefined
monad       stdout      write y to stdout (does not append newline)
monad       stderr      write y to stderr (does not append newline)
monad       exit        terminate J with exit code y (integer: 0-255)
monad       stdin       consume stdin and return it as string
monad       cutopen     split string y into boxed lines
monad       u:          2&u: or 4&u:
dyad        u:          provides access to some unicode functions
monad       datatype    type of noun as words
```
