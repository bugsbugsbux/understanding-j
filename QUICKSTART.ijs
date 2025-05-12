NB. comment the rest of the line
NB. run J in browser: https://jsoftware.github.io/j-playground/bin/html2
NB. most important wiki page: https://code.jsoftware.com/wiki/NuVoc
NB. this describes J9.4

NB. J is an executable alternative mathematical notation
- 2                 NB. negate number; negative sign is an underscore!
1 - 2               NB. different function with same name: subtract
2 -                 NB. error: either 2 args or arg to the right

NB. basic datatypes are strings and numbers
'strings may not be double quoted (")'
'escape single quote like so: '' by doubling it'
_1 1j2 3.45 16bff _ NB. negative-integer complex float hex infinity

NB. basic mathematical functions
2 + 3               NB. addition
2 - 3               NB. subtraction
2 * 3               NB. multiplication
3 % 2               NB. division
2 | 3               NB. remainder of 3%2
2 ^ 3               NB. 2 to the power of 3
3 %: 8              NB. 3rd root of 8
2 ^. 8              NB. log base 2 of 8

NB. Arrays are the only datastructure: lists of lists of equal length
NB. and type. There is no notation for higher dimensional arrays; only
NB. for lists: just put the elements next to each other. The list of the
NB. lengths of each dimension (nesting level) is called shape.
0 1 2               NB. list of 3 numbers
(0 1 2) (3 4)       NB. error: implicit joining does not work
 0 1 2 , 3 4        NB. use function , to join lists
# 1 2 3             NB. length (top level elements) of array
i. 2 3              NB. produces array of given shape: 2 lists of 3

NB. Strings are actually lists of characters; an empty string is often
NB. used as an empty list!
''                  NB. empty list
# ''                NB. length 0
'string' , 1 2      NB. error: incompatible types
'' , 1 2            NB. ok: new list still consists of one type only

NB. Functions are executed in right to left order and are greedy (take
NB. left argument if available). Use parentheses to influence that.
# i. 3 2            NB. first i. on argument 3 2 then # on result
# i. 5 - 2          NB. first - which takes both args, then i. then #
2 * 3 + 4           NB. 14
(2*3) + 4           NB. 10

NB. Single values are called scalars or atoms and may be treated as
NB. arrays with an empty shape. They are different from arrays with
NB. zeros in their shape or ones with a single atom:
i. 2 3              NB. this array is displayed identical to this:
i. 1 2 3            NB. but: shape (2 3) is not (1 2 3)
i. ''               NB. an atom not in a list has an empty shape
i. 1                NB. it is not the same as here: a list with 1 atom
i. 0                NB. nor the same as a list with 0 elements: no atoms
i. 0 3              NB. a table with 0 lists of 3 elements: has no atoms

NB. There is also the datatype box which is used to wrap other data
NB. which allows it to be in the same array since now all elements have
NB. type box...
<3                  NB. a number in a box
<'string'           NB. a string in a box
3 , 'string'        NB. error
(<3) , <'string'    NB. ok

NB. boxes have to be unpacked before working with them
> (<3)              NB. unpack box
1 + (<3)            NB. error
1 + > (<3)          NB. ok

NB. From now on call functions which take and return nouns "verbs" of
NB. which there are two types: verbs with one argument are monads and
NB. verbs with two args are dyads.
mymonad =:{{y - 1}} NB. right argument is called y
mydyad =: {{x - y}} NB. left argument is called x
mymonad 1
1 mymonad 2         NB. error: a monad only takes one arg
1 mydyad 2
mydyad 1            NB. error: a dyad only takes one arg

NB. One name (like -) can be a monad (like negate) and a dyad (like
NB. subtract) at the same time. Which is used depends on how it is
NB. invoked.
ambi =: {{
    echo (<'called with arg:'),(<y)
    'momo'          NB. the last value in a function is returned
    NB. separate monad from dyad with line which only contains :
    :
    echo (<'called with args:'),(<x),(<y)
    'dydy'          NB. the return value for the dyadic version
}}
ambi 1 ambi 2       NB. left one is monad, right one dyad
2 ambi ambi 1       NB. left one is dyad, right one monad

NB. The old function notation specifies whether it's a monad or a dyad
NB. with the number to the left of the : (3 for monad and ambivalent,
NB. 4 for dyad)
dyad =: 4 : 'echo (<''y is:''),(<y)'    NB. body is string
dyad 1
1 dyad 2
ambi =: 3 : 0       NB. 0 instead of string takes next lines until )
    echo 'monadic body'
    :
    echo 'optional dyadic body after line only containing :'
    echo 'body ends with line only containing )'
)
ambi 1
1 ambi 2

NB. Assignment with =: writes to the (current) global namespace, while
NB. assignment with =. writes to the namespace of the current function.
NB. Assignments return their argument unchanged. Nested functions cannot
NB. read or write to their parent's namespace. Control-structures do not
NB. have their own namespaces. Note that control-structures testing a
NB. condition only inspect the first provided atom!
echo global         NB. does not exist -> wont execute
global =: 'foo'     NB. interpreter doesn't show assignment return value
echo global =:'glo' NB. but it can be used within an expression
{{                  NB. function scope:
    echo global     NB. not found locally but globally -> global value
    global =: 'changed by outer function'
    local =. 'local'

    {{              NB. inner function's scope:
        echo 'global ', global
        global =: 'changed by inner function'
        echo local  NB. no access to parent -> not found -> not executed
        local =. 'local2'
    }} ''           NB. provide arg to immediately execute this function
    echo 'unchanged ', local
    NB. Had we used =: in inner function this would still print the
    NB. unchanged outer "local"'s value but a global variable "local"
    NB. would have been created (or modified if it existed).

    NB. control-structures use function scope:
    foo =. 0
    while. foo < 3 do. echo foo =. foo + 1 end.
    echo 'local foo changed from 0 to'; foo
    for. 1 2 3 do. echo 'no access to current value' end.
    for_var. 'abc' do. echo 'loop state'; var_index; var end.
    echo 'vars still exist thus this executes'; var_index; var
    for_var2. 'abcdef' do.
        if. var2 = 'b' do. continue. end.
        NB. note how it skips outputting 'b'
        echo 'current value: ', var2
        if. var2 = 'd' do. break. end.
    end.
    echo 'loop aborted thus var2 not reset to empty'; var2_index; var2
}} ''
echo 'global ', global
echo local          NB. not found in global scope -> not executed

NB. Functions which may take and/or return other functions as arguments
NB. are called modifiers. If they return a new function (most do so) it
NB. has access to the original arguments of the modifier as u (left arg)
NB. and v (right arg). u and v may also be called m and n respectively
NB. to indicate that they are nouns. Due to the predetermined meaning
NB. of certain names, get into the habit of only using *capital* single
NB. letter variables! Modifiers are not ambivalent; with 2 original
NB. arguments they are called conjunctions and those with 1 are called
NB. adverbs. Note that adverbs take their argument from the left and
NB. sequences of modifiers are processed left to right!
mymod =: {{         NB. in old fn notation it would be (1 : 0)
    NB. This modifier takes 1 argument and thus is an adverb. It returns
    NB. an ambivalent function (the modifier is not ambivalent!) which
    NB. *) copies its argument to the other side thus becomes a dyad:
    y u y
    :
    NB. *) or (if called as a dyad) swaps its arguments
    y u x
}}
+ mymod 2           NB. becomes: returnedFunc 2 which does 2+2
4 - mymod 1         NB. becomes: 4 returnedFunc 1 which does 1-4
NB. this is exactly what builtin adverb ~ does:
+ ~ 2
4 - ~ 1
NB. builtin adverb / inserts its verb between the items of its arg
+/ 4 2 1            NB. same as 4 + 2 + 1
-/ 4 2 1            NB. beware right to left execution: 4 - (2 - 1)
NB. or if applied dyadically it combines every left and right elements
1 2 3 4 */ 1 2 3 4  NB. multiplication table
NB. sequence of modifiers
-~/ 4 2 1           NB. first: make fn which swaps args then: insert it
4 -~ 2 -~ 1         NB. equivalent
(1 - 2) - 4         NB. equivalent

NB. By default a function receives its whole argument. Conjunction "
NB. can change that: It breaks the argument into pieces and calls the
NB. verb on each piece individually. The size of the pieces is
NB. determined by the right argument to " which is called the rank of
NB. the verb and specifies how many dimensions the piece has. Default
NB. ranks of builtins must be learnt!
fn =: {{ <y }}      NB. this simply boxes the argument it receives
fn i.2 3 4          NB. fn gets all dimensions as 1 piece
fn"_ i.2 3 4        NB. equivalent (rank infinity = rank of argument)
fn"2 i.2 3 4        NB. fn gets 2 dimensions=tables (here of shape 3 4)
fn"1 i.2 3 4        NB. fn gets 1 dimension=lists (here of shape 4)
fn"0 i.2 3 4        NB. fn gets 0 dimensions=atoms (always empty shape)

NB. The examples showed that the results are not simply a list but are
NB. arranged in some shape. The shape in which to arrange a list of
NB. items is called frame. The frame of the result is the part of the
NB. argument's shape not used to determine the shape of the pieces.
<"_ i.2 3 4        NB. pieces are shape 2 3 4 -> frame is empty (atom)
<"2 i.2 3 4        NB. pieces are shape 3 4 -> frame is shape 2 (list)
<"1 i.2 3 4        NB. pieces are shape 4 -> frame is shape 2 3 (table)
<"0 i.2 3 4        NB. pieces have empty shape -> frame is shape of arg

NB. Dyads have 2 ranks, one for each side, which may differ from the
NB. monadic rank. They pair the pieces from both sides by index, with
NB. the special case that a single piece on a side is paired with every
NB. piece from the other side individually.
+ b.0               NB. shows the 3 ranks: monadic, left, dyadic right
1 2 3 + 4 5 6       NB. thus pairs atoms
1 2 3 +"(0 0) 4 5 6 NB. equivalent
1 + 4 5 6           NB. left side has only one piece -> with each right
4 5 6 + 1           NB. right side has only one piece -> with each left
1 2 + 3 4 5         NB. error: cannot pair 2 pieces with 3
bj =: {{(<x),<y}}   NB. joins elements as boxes
bj b.0              NB. default ranks of new verbs are all _
1 2 3 bj 4 5 6      NB. thus joins whole arguments
1 2 3 bj"(0)  4 5 6 NB. pairs atoms
1 2 3 bj"(0 1)4 5 6 NB. pairs atoms with lists (single piece repeated)
1 2 3 bj"(1 0)4 5 6 NB. pairs lists with atoms (single piece repeated)
(i.2 3)bj"1 i.2 3 4 NB. pairs lists

NB. The last example raised a view questions: Why do different numbers
NB. of pieces, with none being 1, not throw an error; and why are some
NB. pieces repeated, but not for every element of the other side? The
NB. answer is dyads actually pair the cells of the frames. The two
NB. frames must be the same or one must start with the other. Thus, a
NB. valid longer frame is like the shorter with subcells which contain
NB. the pieces. Each of the small cells is then paired with its parent's
NB. corresponding (by index) cell. The results are then put into the
NB. cells of the longer frame. This does not necessarily mean the final
NB. result's shape is the longer frame, but it starts with it.
2 3 $ 1 2 3 4       NB. rearrange items of y according to shape x
(i.2 4 6 8) bj"3 1 i.2 3 5  NB. shorter frame: (2), frame difference:(3)
(2$<'shape: 4 6 8') NB. imagine x like this
(2$< 3$<'shape: 5') NB. imagine y like this
NB. outer boxes are now easy to match up, then the contents are paired
(2$<'shape: 4 6 8') {{x,"0 >y}}"0 (2$< 3$<'shape: 5')
NB. results are of shape (2) and are assembled into longer frame (2 3):
>(2 3$<'shape 2')

NB. Elements of different shape cannot be in the same array. However,
NB. they can be converted to type box, which is always an atom (empty
NB. shape). Another possibility is to make the shorter elements bigger
NB. by appending some value, which J does automatically when unboxing or
NB. assembling subresults into the final one:
 (<1),(<1 2 3)
>(<1),(<1 2 3)         NB. added 0s
>(<1+i.2 2),(<1+i.3 3)
{{<1+i.y}}"(0) 1 2 3   NB. results are all same shape -> no padding
{{ 1+i.y}}"(0) 1 2 3   NB. here the shapes differ -> adds 0s as padding
{{ 1+i.y,y}}"(0) 1 2 3

NB. J gives sequences of verb which are not invoked (due to a missing
NB. argument) special meaning and calls them trains: They create a new
NB. verb which independently applies each odd numbered verb of the
NB. sequence to its argument/s. The even numbered verbs are then used to
NB. combine their neighbouring results from right to left:
avg =: +/ % #       NB. +/ and # on arg, then combine with %
avg 1 2 3 4
(+/ % #) 1 2 3 4    NB. same: exprssion in () does not execute -> train
2 (* % +) 3         NB.        (2*3)%(2+3)
2 (- * * % +) 3     NB. (2-3)*((2*3)%(2+3))

NB. If a train is missing the last function because its length is even
NB. it uses one of its arguments instead of the missing result. However,
NB. they use the left argument only to replace the missing result, not
NB. as second argument to other verbs!
(- +/ % #) 1 2 3 4  NB. argument minus average (2.5)
2 (* -) 3           NB. 2*( -3) not 2*(2-3)

NB. Instead, any verb which supplies the left argument to a combining
NB. verb can be replaced by a noun! These verbs may also be replaced
NB. by by [: which signals to its combining verb to ignore it and apply
NB. monadically. Verbs [ and ] return the (if dyads: left or right
NB. respectively) argument unchanged.
2 (2 * -) 3         NB. 2*(x-y)     = 2*(2-3)
2 ([ * -) 3         NB. (x[y)*(x-y) = 2*(2-3)
2 (] * -) 3         NB. (x]y)*(x-y) = 3*(2-3)
2 ([ * [: - ]) 3    NB. (x[y)*( -(x]y)) = 2*( -(3))
2 ([ * 4 - ]) 3     NB. (x[y)*(4-(x]y)) = 2*(4-(3))
2 (  * 4 - ]) 3     NB.     x*(4-( ]y)) = 2*(4-(3))
  (  * 4 - ]) 3     NB.     y*(4-( ]y)) = 3*(4-(3))

NB. As sequences of verbs that do not execute create trains there needs
NB. to be a different way to factor out a simple pipeline of verbs!
NB. Combine them with conjunction @: or @
<"0 - 1 2 3         NB. negate elements, then box each
boxneg =: <"0 -     NB. a train instead of the factored out pipeline
boxneg 1 2 3        NB. ultimately a comparison: 1 2 3 <"0 - 1 2 3
boxneg =: <"0 @: -  NB. applies < after -
boxneg 1 2 3
(< @: -) 1 2 3      NB. show that u@:v applies u to whole result of v
(< @  -) 1 2 3      NB. instead u@v applies u to each result of v
NB. To write a pipeline monad after dyad simply apply the result of
NB. conjunctions @: or @ dyadically:
1 2 (< @: -) 3 4    NB. applies monad to whole result of dyad
1 2 (< @  -) 3 4    NB. applies monad to every subresult of dyad
NB. To apply a monad to each argument of a dyad conjunctions & or &: can
NB. be used:
((<1),(<2)) (, &: >) ((<3),(<4))    NB. applies dyad to whole results
((<1),(<2)) (, &  >) ((<3),(<4))    NB. applies to each subresult pair
NB. Wouldn't it be awesome to put the result/s in the last example back
NB. into a box? Use conjunctions &. and &.: to undo the first verb
NB. afterwards:
((<1),(<2)) (, &.: >) ((<3),(<4))   NB. undoes the unboxing in the end
((<1),(<2)) (, &.  >) ((<3),(<4))   NB. same but for each subresult
NB. &. and &.: also works for monad after monad pipelines:
(- &.: >) ((<1),(<2))
(- &.  >) ((<1),(<2))
NB. To factor out a function with an argument use conjunction &
1 - 1 2 3
oneminus =: 1 -     NB. error
oneminus =: 1 & -   NB. creates a monad invoking dyad - with left arg 1
oneminus 1 2 3
minusone =: - 1     NB. executes expression (- 1) and saves its value
minusone
minusone =: - & 1   NB. creates a monad invoking dyad - with right arg 1
minusone 1 2 3

NB. The booleans (truth values) are simply the numbers 0 (false) and 1
NB. (true). Arrays are equal if their shape and each atom match which
NB. can be tested with dyad -:
1 > 0 1 2           NB. less than
1 < 0 1 2           NB. greater than
1 >: 0 1 2          NB. less or equal
1 <: 0 1 2          NB. greater or equal
1 = i.2 2           NB. equals
1 ~: i.2 2          NB. not equal
(i.2 2) -: i.2 2    NB. equal in shape and each atom
(i.4) -: i.2 2
-. (i.2 2) -: i.2 2 NB. not
0 0 1 1 +. 0 1 0 1  NB. or
0 0 1 1 *. 0 1 0 1  NB. and

NB. To apply a function repeatedly use conjunction ^: with the number of
NB. repetitions as the right argument. Infinite repetitions stop as soon
NB. as the result stops changing, 1 or 0 repetitions either apply the
NB. verb or return the argument unchanged. A verb to compute the number
NB. of repetitions can be supplied instead of a fixed number.
+&1 ^:(10) 0        NB. applies +&1 ten times
+&1 ^:(<&10) 5      NB. if 5 less than 10 applies +&1 once
+&1 ^:(>&10) 5      NB. if 5 greater than 10 applies +&1 once
+&1 ^:(<&10)^:(_) 0 NB. while less than ten applies +&1

NB. Indices of arrays start at zero and may be negative to count from
NB. the back. Every box in an index holds the path to a selection. To
NB. select several elements on the same dimension group put them in
NB. another box. Wrapping in a third box excludes the given indices;
NB. excluding none selects all.
                    i.10 10
(<0)              { i.10 10 NB. 1st element
((<0),(<_1))      { i.10 10 NB. 1st and last elements
(<0 _1)           { i.10 10 NB. 1st element then last
(<(<0 1 2),(<_1)) { i.10 10 NB. 1st,2nd,3rd elements then last
(<(<0 1 2),(<<_1)){ i.10 10 NB. 1st,2nd,3rd elements without last
(<(<<''),(<_1))   { i.10 10 NB. all elements, then last

NB. Replacing elements in arrays is like indexing but using adverb } and
NB. specifying the replacements as left argument to the created verb.
1000 (<0)              } i.10 10 NB. 1st element
1000 ((<0),(<_1))      } i.10 10 NB. 1st and last elements
1000 (<0 _1)           } i.10 10 NB. 1st element then last
1000 (<(<0 1 2),(<_1)) } i.10 10 NB. 1st,2nd,3rd elements then last
1000 (<(<0 1 2),(<<_1))} i.10 10 NB. 1st,2nd,3rd elements without last
1000 (<(<<''),(<_1))   } i.10 10 NB. all elements, then last

NB. Instead of a specific index a verb may be supplied, which is invoked
NB. with the replacements as left and the array as right argument. This
NB. verb must return the relevant indices of a flattened version of the
NB. array, which allows to use it with arrays of any dimension!
, i. 3 3            NB. monad , flattens an array
0 1 2 # 'abc'       NB. dyad # copies elements in y x-times
lower =: {{
    flat =. , y
    len =. # flat
    indices =: i. len
    NB. only keep indices where condition is true:
    (flat < x) # indices
}}
44 lower } i.10 10
4 lower } i.3 3     NB. works for this array just the same
