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


import Graphics.Element exposing (Element)
import Json.Encode exposing (Value)
import String

import Native.D3.Render
import Native.D3.Selection
import Native.D3.Transition

type D3 a b = D3


version : String
version = Native.D3.Selection.version

-------------------------------------------------------------------------------
-- Selection-to-Runtime API

-- Render a `D3 a b`, given a width and height, and a datum.
--
render : number -> number -> D3 a b -> a -> Element
render = Native.D3.Render.render

-- Render a `D3 a b` when the width and height depend on the datum.
--
render' : (a -> (number, number)) -> D3 a b -> a -> Element
render' dims selection datum =
  let (width, height) = dims datum
    in render width height selection datum

-------------------------------------------------------------------------------
-- Core Selection API

-- Sequence two selections. Think of this as the semicolon operator.
--
--   sequence s1 s2
--
-- is equivalent to
--
--   context.s1();
--   context.s2();
--
-- and preserves the context.
--
sequence : D3 a b -> D3 a c -> D3 a a
sequence = Native.D3.Selection.sequence

-- Chain two selections. Think of this as the method chaining operator.
--
--   chain s1 s2
--
-- is equivalent to
--
--   context = context.s1().s2();
--
chain : D3 a b -> D3 b c -> D3 a c
chain = Native.D3.Selection.chain

-- Infix operator aliases for chain.
--
infixl 4 |.
(|.) : D3 a b -> D3 b c -> D3 a c
(|.) = chain

infixl 4 <.>
(<.>) : D3 a b -> D3 b c -> D3 a c
(<.>) = chain

-- Nest a selection below another, setting the context to the parent selection.
--
--   nest s1 s2
--
-- is equivalent to
--
--   context = context.s1();
--   context.s2();
--
nest : D3 a b -> D3 b c -> D3 a b
nest a b = chain a (sequence b update)

-- Infix operator alias for chain'.
--
infixl 2 |-
(|-) : D3 a b -> D3 b c -> D3 a b
(|-) = nest

-- Create a single-element (or empty) selection given a css selector.
--
--   select selector
--
-- is equivalent to
--
--   context = context.select(selector);
--
select : String -> D3 a a
select = Native.D3.Selection.select

-- Create a multi-element (or empty) selection given a css selector.
--
--   selectAll selector
--
-- is equivalent to
--
--   context = context.selectAll(selector);
--
selectAll : String -> D3 a a
selectAll = Native.D3.Selection.selectAll

-- Append a DOM element.
--
--   append element
--
-- is equivalent to
--
--   context = context.append(element);
--
append : String -> D3 a a
append = Native.D3.Selection.append

-- Append a DOM element, but only once.
--
--
static : String -> D3 a a
static = Native.D3.Selection.static_

-- Remove the current context.
--
--   remove
--
-- is equivalent to
--
--   context = context.remove();
--
remove : D3 a a
remove = Native.D3.Selection.remove

-- Bind data to the given selection, creating a widget that will nest the
-- result under a provided parent.
--
--   bind s f
--
-- is equlvalent to
--
--   function(p) { return p.s().bind(f); }
--
bind : (a -> List b) -> D3 a b
bind f = Native.D3.Selection.bind f

-- Infix operator alias for bind.
--
infixl 6 |=
(|=) : D3 a b -> (b -> List c) -> D3 a c
(|=) s f = s <.> bind f

-- Create an enter selection.
--
--   enter
--
-- is equivalent to
--
--   context = context.enter();
--
enter : D3 a a
enter = Native.D3.Selection.enter

-- Create an update selection.
--
--   update
--
-- is equivalent to
--
--   context = context;
--
update : D3 a a
update = Native.D3.Selection.update

-- Create an exit selection.
--
--   exit
--
-- is equivalent to
--
--   context = context.exit();
--
exit : D3 a a
exit = Native.D3.Selection.exit

-------------------------------------------------------------------------------
-- Operators

-- Set an attribute to the per-element value determined by `fn`.
--
--   attr name fn
--
-- is equivalent to
--
--   context = context.attr(name, fn);
--
attr : String -> (a -> Int -> String) -> D3 a a
attr = Native.D3.Selection.attr

-- Set a style property to the per-element value determined by `fn`.
--
--   style name fn
--
-- is equivalent to
--
--   context = context.style(name, fn);
--
style : String -> (a -> Int -> String) -> D3 a a
style = Native.D3.Selection.style

-- Set a DOM object property to the per-element value determined by `fn`.
--
--   property name fn
--
-- is equivalent to
--
--   context = context.property(name, fn);
--
property : String -> (a -> Int -> Value) -> D3 a a
property = Native.D3.Selection.property

-- Include or exclude the class on each element depending on the result of `fn`.
--
--   classed name fn
--
-- is equivalent to
--
--   context = context.classed(name, fn);
--
classed : String -> (a -> Int -> Bool) -> D3 a a
classed = Native.D3.Selection.classed

-- Set the HTML content of each element as determined by `fn`.
--
--   html fn
--
-- is equivalent to
--
--   context = context.html(fn);
--
html : (a -> Int -> String) -> D3 a a
html = Native.D3.Selection.html

-- Set the text content of each element as determined by `fn`.
--
--   text fn
--
-- is equivalent to
--
--   context = context.text(fn);
--
text : (a -> Int -> String) -> D3 a a
text = Native.D3.Selection.text

-- String casting helper for attr and similar functions.
--
--   num op name fn
--
-- is equivalent to
--
--   context = context.op(name, function() { return n; });
--
num : (String -> (a -> Int -> String) -> D3 a a)
    -> String
    -> number
    -> D3 a a
num a name v = a name (\_ _ -> (toString v))

-- String casting helper for attr and similar functions.
--
--   str op name string
--
-- is equivalent to
--
--   context = context.op(name, function() { return string; });
--
str : (String -> (a -> Int -> String) -> D3 a a)
    -> String
    -> String
    -> D3 a a
str a name v = a name (\_ _ -> v)

-- Function casting helper for attr and similar functions. This is a NOOP.
--
--   fun op name fn
--
-- is equivalent to
--
--   context = context.op(name, fn)
--
fun : (String -> (a -> Int -> String) -> D3 a a)
    -> String
    -> (a -> Int -> String)
    -> D3 a a
fun f = f

-------------------------------------------------------------------------------
-- Transition

-- Create a transition.
--
--   transition
--
-- is equivalent to
--
--   context = context.transition();
--
transition : D3 a a
transition = Native.D3.Transition.transition

-- Set the per-element delay of a transition.
--
--   delay fn
--
-- is equivalent to
--
--   context = context.delay(fn);
--
delay : (a -> Int -> Int) -> D3 a a
delay = Native.D3.Transition.delay

-- Set the per-element duration of a transition.
--
--   delay fn
--
-- is equivalent to
--
--   context = context.delay(fn);
--
duration : (a -> Int -> Int) -> D3 a a
duration = Native.D3.Transition.duration
