module D3
  ( version                 -- : String

  , render                  -- : number -> number -> Selection a -> Selection a -> a -> Element
  , render'                 -- : (a -> (number, number)) -> Selection a -> Selection a -> a -> Element

  , sequence, chain         -- : Selection a -> Selection a -> Selection a
  , select, selectAll       -- : String -> Selection a
  , append                  -- : String -> Selection a
  , static_                 -- : String -> Selection a
  , remove                  -- : Selection a
  , bind                    -- : (a -> [b]) -> Selection b -> Selection b -> Selection b -> Selection a
  , chain'
  , embed
  , enter, update, exit     -- : Selection a
  , attr, style, property   -- : String -> (a -> Int -> String) -> Selection a
  , classed                 -- : String -> (a -> Int -> Bool) -> Selection a
  , html, text              -- : (a -> Int -> String) -> Selection a

  , str     -- : (String -> (a -> Int -> String) -> Selection a) -> String -> String -> Selection a
  , num     -- : (String -> (a -> Int -> String) -> Selection a) -> String -> number -> Selection a
  , fun     -- : (String -> (a -> Int -> String) -> Selection a) -> String -> (a -> Int -> String) -> Selection a

  , transition              -- : Selection a
  , delay                   -- : (a -> Int -> Int) -> Selection a
  , duration                -- : (a -> Int -> Int) -> Selection a
  ) where

import Native.D3.Render
import Native.D3.Selection
import Native.D3.Transition
import String

data Selection a = Selection
data Widget a b = Widget

version : String
version = Native.D3.version

-------------------------------------------------------------------------------
-- Selection-to-Runtime API

-- Render a `Selection a`, given a width and height, and a datum.
--
render : number -> number -> Selection a -> a -> Element
render = Native.D3.Render.render

-- Render a `Selection a` when the width and height depend on the datum.
--
render' : (a -> (number, number)) -> Selection a -> a -> Element
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
sequence : Selection a -> Selection a -> Selection a
sequence = Native.D3.Selection.sequence

-- Chain two selections. Think of this as the method chaining operator.
--
--   chain s1 s2
--
-- is equivalent to
--
--   context.s1().s2();
--
chain : Selection a -> Selection a -> Selection a
chain = Native.D3.Selection.chain

-- Infix operator aliases for chain.
--
infixl 4 |.
(|.) : Selection a -> Selection a -> Selection a
(|.) = chain

infixl 4 <.>
(<.>) : Selection a -> Selection a -> Selection a
(<.>) = chain

-- Create a single-element (or empty) selection given a css selector.
--
--   select selector
--
-- is equivalent to
--
--   context.select(selector);
--
select : String -> Selection a
select = Native.D3.Selection.select

-- Create a multi-element (or empty) selection given a css selector.
--
--   selectAll selector
--
-- is equivalent to
--
--   context.selectAll(selector);
--
selectAll : String -> Selection a
selectAll = Native.D3.Selection.selectAll

-- Append a DOM element.
--
--   append element
--
-- is equivalent to
--
--   context.append(element);
--
append : String -> Selection a
append = Native.D3.Selection.append

-- Append a DOM element, but only once.
--
--
static_ : String -> Selection a
static_ = Native.D3.Selection.static_

-- Remove the current context.
--
--   remove
--
-- is equivalent to
--
--   context.remove();
--
remove : Selection a
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
bind : Selection a -> (a -> [b]) -> Widget a b
bind s f = Native.D3.Selection.bind s f

-- Infix operator alias for bind.
--
infixl 6 |=
(|=) : Selection a -> (a -> [b]) -> Widget a b
(|=) = bind

-- Chain is the Widget-analogue of chain on Selections. It will chain Selection
-- onto the result of the widget, and then return the original Selection the
-- Widget produced.
--
--   chain w s p
--
-- is equivalent to
--
--   context = w(p);
--   context.s();
--   context;
--
chain' : Widget a b -> Selection b -> Widget a b
chain' = Native.D3.Selection.chain_widget

-- Infix operator alias for chain'.
--
infixl 2 |-
(|-) : Widget a b -> Selection b -> Widget a b
(|-) = chain'

-- Casts a `Widget a b` to a `Selection a`. Wrapping a value with this call
-- disallows further nested chanining, and allows you to embed it on other
-- selection.
--
-- This is the only way to use a `Widget a b` type.
--
embed : Widget a b -> Selection a
embed = Native.D3.Selection.embed

-- Create an enter selection.
--
--   enter
--
-- is equivalent to
--
--   context.enter();
--
enter : Selection a
enter = Native.D3.Selection.enter

-- Create an update selection.
--
--   update
--
-- is equivalent to
--
--   context;
--
update : Selection a
update = Native.D3.Selection.update

-- Create an exit selection.
--
--   exit
--
-- is equivalent to
--
--   context.exit();
--
exit : Selection a
exit = Native.D3.Selection.exit

-------------------------------------------------------------------------------
-- Operators

-- Set an attribute to the per-element value determined by `fn`.
--
--   attr name fn
--
-- is equivalent to
--
--   context.attr(name, fn);
--
attr : String -> (a -> Int -> String) -> Selection a
attr = Native.D3.Selection.attr

-- Set a style property to the per-element value determined by `fn`.
--
--   style name fn
--
-- is equivalent to
--
--   context.style(name, fn);
--
style : String -> (a -> Int -> String) -> Selection a
style = Native.D3.Selection.style

-- Set a DOM object property to the per-element value determined by `fn`.
--
--   property name fn
--
-- is equivalent to
--
--   context.property(name, fn);
--
property : String -> (a -> Int -> String) -> Selection a
property = Native.D3.Selection.property

-- Include or exclude the class on each element depending on the result of `fn`.
--
--   classed name fn
--
-- is equivalent to
--
--   context.classed(name, fn);
--
classed : String -> (a -> Int -> Bool) -> Selection a
classed = Native.D3.Selection.classed

-- Set the HTML content of each element as determined by `fn`.
--
--   html fn
--
-- is equivalent to
--
--   context.html(fn);
--
html : (a -> Int -> String) -> Selection a
html = Native.D3.Selection.html

-- Set the text content of each element as determined by `fn`.
--
--   text fn
--
-- is equivalent to
--
--   context.text(fn);
--
text : (a -> Int -> String) -> Selection a
text = Native.D3.Selection.text

-- String casting helper for attr and similar functions.
--
--   num op name fn
--
-- is equivalent to
--
--   context.op(name, function() { return n; });
--
num : (String -> (a -> Int -> String) -> Selection a)
    -> String
    -> number
    -> Selection a
num a name v = a name (\_ _ -> show v)

-- String casting helper for attr and similar functions.
--
--   str op name string
--
-- is equivalent to
--
--   context.op(name, function() { return string; });
--
str : (String -> (a -> Int -> String) -> Selection a)
    -> String
    -> String
    -> Selection a
str a name v = a name (\_ _ -> v)

-- Function casting helper for attr and similar functions. This is a NOOP.
--
--   fun op name fn
--
-- is equivalent to
--
--   context.op(name, fn)
--
fun : (String -> (a -> Int -> String) -> Selection a)
    -> String
    -> (a -> Int -> String)
    -> Selection a
fun f = f

-------------------------------------------------------------------------------
-- Transition

-- Create a transition.
--
--   transition
--
-- is equivalent to
--
--   context.transition();
--
transition : Selection a
transition = Native.D3.Transition.transition

-- Set the per-element delay of a transition.
--
--   delay fn
--
-- is equivalent to
--
--   context.delay(fn);
--
delay : (a -> Int -> Int) -> Selection a
delay = Native.D3.Transition.delay

-- Set the per-element duration of a transition.
--
--   delay fn
--
-- is equivalent to
--
--   context.delay(fn);
--
duration : (a -> Int -> Int) -> Selection a
duration = Native.D3.Transition.duration
