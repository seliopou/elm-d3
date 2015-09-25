module D3
  ( version             -- : String

  , D3

  , render              -- : number -> number -> D3 a b -> a -> Element
  , render'             -- : (a -> (number, number)) -> D3 a b -> a -> Element

  , sequence            -- : D3 a b -> D3 a c -> D3 a a
  , chain, (|.), (<.>)  -- : D3 a b -> D3 b c -> D3 a c
  , select, selectAll   -- : String -> D3 a a
  , append              -- : String -> D3 a a
  , static              -- : String -> D3 a a
  , remove              -- : D3 a a

  , bind                -- : (a -> [b]) -> D3 a b
  , (|=)                -- : D3 a b -> (b -> [c]) -> D3 a c

  , nest, (|-)          -- : D3 a b -> D3 b c -> D3 a b

  , enter, update, exit -- : D3 a a
  , attr, style         -- : String -> (a -> Int -> String) -> D3 a a
  , property            -- : String -> (a -> Int -> Value) -> D3 a a
  , classed             -- : String -> (a -> Int -> Bool) -> D3 a a
  , html, text          -- : (a -> Int -> String) -> D3 a a

  , str     -- : (String -> (a -> Int -> String) -> D3 a) -> String -> String -> D3 a a
  , num     -- : (String -> (a -> Int -> String) -> D3 a) -> String -> number -> D3 a a
  , fun     -- : (String -> (a -> Int -> String) -> D3 a) -> String -> (a -> Int -> String) -> D3 a a

  , transition          -- : D3 a a
  , delay               -- : (a -> Int -> Int) -> D3 a a
  , duration            -- : (a -> Int -> Int) -> D3 a a
  ) where

{-| Elm bindings for D3.js

# Types, etc.
@docs D3, version

# Rendering
@docs render, render'

# Composition
@docs sequence, chain, (|.), (<.>), nest, (|-)

# Data Binding
@docs bind, (|=), enter, update, exit

# Casting
@docs num, str, fun

# Transitions
@docs transition, delay, duration

# Selection Operations
@docs select, selectAll, static, append, remove, attr, classed, property, style, html, text
-}

import Graphics.Element exposing (Element)
import Json.Encode exposing (Value)
import String

import Native.D3.Render
import Native.D3.Selection
import Native.D3.Transition

-- These modules are not used directly but are required to be referenced from
-- some elm source code so that they're actually linked during compile time...
-- since there's not really a distinction between linking and compiling any
-- more, as far as I can tell.
--
import Native.D3.JavaScript
import Native.D3.Util

{-| The type of a D3 operation that assumes its parent has data of type `a`
bound to it and which itself can act as a context with data of type `b`
bound to it. -}
type D3 a b = D3


{-| The version of D3 that is currently loaded. -}
version : String
version = Native.D3.Selection.version

-------------------------------------------------------------------------------
-- Selection-to-Runtime API

{-| Render a `D3 a b`, given a width and height, and a datum. -}
render : number -> number -> D3 a b -> a -> Element
render = Native.D3.Render.render

{-| Render a `D3 a b` when the width and height depend on the datum. -}
render' : (a -> (number, number)) -> D3 a b -> a -> Element
render' dims selection datum =
  let (width, height) = dims datum
    in render width height selection datum

-------------------------------------------------------------------------------
-- Core Selection API

{-| Sequence two selections. Think of this as the semicolon operator. -}
sequence : D3 a b -> D3 a c -> D3 a a
sequence = Native.D3.Selection.sequence

{-| Chain two selections. Think of this as the method chaining operator. -}
chain : D3 a b -> D3 b c -> D3 a c
chain = Native.D3.Selection.chain

infixl 4 |.
{-| Alias for `chain` -}
(|.) : D3 a b -> D3 b c -> D3 a c
(|.) = chain

infixl 4 <.>
{-| Alias for `chain` -}
(<.>) : D3 a b -> D3 b c -> D3 a c
(<.>) = chain

{-| Nest a selection below another, setting the context to the parent
selection. `nest a b` is equivalent to `chain a (seq b update)`. -}
nest : D3 a b -> D3 b c -> D3 a b
nest a b = chain a (sequence b update)

infixl 2 |-
{-| Alias for `nest` -}
(|-) : D3 a b -> D3 b c -> D3 a b
(|-) = nest

{-| Create a single-element (or empty) selection given a css selector. -}
select : String -> D3 a a
select = Native.D3.Selection.select

{-| Create a multi-element (or empty) selection given a css selector. -}
selectAll : String -> D3 a a
selectAll = Native.D3.Selection.selectAll

{-| Append a DOM element to each element in the selection. The result is a
selection that contains all the appended elements. -}
append : String -> D3 a a
append = Native.D3.Selection.append

{-| Append a DOM element, but only once. -}
static : String -> D3 a a
static = Native.D3.Selection.static_

{-| Remove the element in the current selection from the DOM, but leave them in
the selection. -}
remove : D3 a a
remove = Native.D3.Selection.remove

{-| Bind data to the given selection, introducing a data join that can be
resolved using the `enter`, `update`, and `exit` operators. -}
bind : (a -> List b) -> D3 a b
bind f = Native.D3.Selection.bind f

infixl 6 |=
{-| Alias for bind -}
(|=) : D3 a b -> (b -> List c) -> D3 a c
(|=) s f = s <.> bind f

{-| Retrieve the enter selection from a data join -}
enter : D3 a a
enter = Native.D3.Selection.enter

{-| This is a NOOP, but is useful for its algebraic properties. It is the
identity of the `chain` operator. -}
update : D3 a a
update = Native.D3.Selection.update

{-| Retrieve the exit selection from a data join -}
exit : D3 a a
exit = Native.D3.Selection.exit

-------------------------------------------------------------------------------
-- Operators

{-| Set an attribute to the per-element value determined by `fn`. -}
attr : String -> (a -> Int -> String) -> D3 a a
attr = Native.D3.Selection.attr

{-| Set a style property to the per-element value determined by `fn`. -}
style : String -> (a -> Int -> String) -> D3 a a
style = Native.D3.Selection.style

{-| Set a DOM object property to the per-element value determined by `fn`. -}
property : String -> (a -> Int -> Value) -> D3 a a
property = Native.D3.Selection.property

{-| Include or exclude the class on each element depending on the result of `fn`. -}
classed : String -> (a -> Int -> Bool) -> D3 a a
classed = Native.D3.Selection.classed

{-| Set the HTML content of each element as determined by `fn`. -}
html : (a -> Int -> String) -> D3 a a
html = Native.D3.Selection.html

{-| Set the text content of each element as determined by `fn`. -}
text : (a -> Int -> String) -> D3 a a
text = Native.D3.Selection.text

{-| String casting helper for attr and similar functions. -}
num : (String -> (a -> Int -> String) -> D3 a a)
    -> String
    -> number
    -> D3 a a
num a name v = a name (\_ _ -> (toString v))

{-| String casting helper for attr and similar functions. -}
str : (String -> (a -> Int -> String) -> D3 a a)
    -> String
    -> String
    -> D3 a a
str a name v = a name (\_ _ -> v)

{-| Function casting helper for attr and similar functions. This is a NOOP. -}
fun : (String -> (a -> Int -> String) -> D3 a a)
    -> String
    -> (a -> Int -> String)
    -> D3 a a
fun f = f

-------------------------------------------------------------------------------
-- Transitions

{-| Create a transition -}
transition : D3 a a
transition = Native.D3.Transition.transition

{-| Set the per-element delay of a transition. -}
delay : (a -> Int -> Int) -> D3 a a
delay = Native.D3.Transition.delay

{-| Set the per-element duration of a transition. -}
duration : (a -> Int -> Int) -> D3 a a
duration = Native.D3.Transition.duration
