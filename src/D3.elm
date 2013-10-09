module D3
  ( version                 -- : String
  , render                  -- : number -> number -> Selection a -> Selection a -> a -> Element
  , render'                 -- : (a -> (number, number)) -> Selection a -> Selection a -> a -> Element
  , sequence , chain        -- : Selection a -> Selection a -> Selection a
  , select , selectAll      -- : String -> Selection a
  , append                  -- : String -> Selection a
  , remove                  -- : Selection a
  , bind                    -- : (a -> [b]) -> Selection b -> Selection b -> Selection b -> Selection a
  , enter , update , exit   -- : Selection a
  , attr, style, property   -- : String -> (a -> Int -> String) -> Selection a
  , classed                 -- : String -> (a -> Int -> Bool) -> Selection a
  , html , text             -- : (a -> Int -> String) -> Selection a
  , str, num                -- : (String -> (a -> Int -> String) -> Selection a) -> String -> String -> Selection a
  , transition              -- : Selection a
  , delay                   -- : (a -> Int -> Int) -> Selection a
  , duration                -- : (a -> Int -> Int) -> Selection a
  ) where

import Native.D3.Render
import Native.D3.Selection
import Native.D3.Transition
import String
import JavaScript


data Selection a = Selection

version : String
version = JavaScript.toString Native.D3.version

-------------------------------------------------------------------------------
-- Selection-to-Runtime API

-- Render a `Selection a`, given a width and height, a root selection that will
-- be run only once, the selection that will depend on the datum, and the datum.
--
render : number -> number -> Selection a -> Selection a -> a -> Element
render = Native.D3.Render.render

-- Render a `Selection a` when the width and height depend on the datum.
--
render' : (a -> (number, number)) -> Selection a -> Selection a -> a -> Element
render' dims root selection datum =
  let (width, height) = dims datum
    in render width height root selection datum

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

-- Infix operator alias for chain.
--
infixl 4 |.
(|.) : Selection a -> Selection a -> Selection a
(|.) = chain

-- Create a single-element (or empty) selection given a css selector.
--
--   select selector
--
-- is equivalent to
-- 
--   context.select(selector);
-- 
select : String -> Selection a
select = Native.D3.Selection.select . JavaScript.fromString

-- Create a multi-element (or empty) selection given a css selector.
--
--   selectAll selector
--
-- is equivalent to
-- 
--   context.selectAll(selector);
-- 
selectAll : String -> Selection a
selectAll = Native.D3.Selection.selectAll . JavaScript.fromString

-- Append a DOM element.
--
--   append element
--
-- is equivalent to 
--   
--   context.append(element);
--
append : String -> Selection a
append = Native.D3.Selection.append . JavaScript.fromString

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

-- Bind data to the current selection and associate and enter, update, and exit
-- selections with the bound context.
--
--   bind fn s1 s2 s3
--
-- is equivalent to
--
--   var bound = context.data(fn);
--   bound.enter().call(s1);
--   bound.call(s2);
--   bound.exit().call(s3);
--   
bind : (a -> [b]) -> Selection b -> Selection b -> Selection b -> Selection a
bind fn = Native.D3.Selection.bind (JavaScript.fromList . fn)

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

context : Selection a
context = update

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
attr name fn =
  Native.D3.Selection.attr (JavaScript.fromString name) (safeEvaluator fn)

-- Set a style property to the per-element value determined by `fn`.
--
--   style name fn
--
-- is equivalent to
--
--   context.style(name, fn);
--
style : String -> (a -> Int -> String) -> Selection a
style name fn =
  Native.D3.Selection.style (JavaScript.fromString name) (safeEvaluator fn)

-- Set a DOM object property to the per-element value determined by `fn`.
--
--   property name fn
--
-- is equivalent to
--
--   context.property(name, fn);
--
property : String -> (a -> Int -> String) -> Selection a
property name fn =
  Native.D3.Selection.property (JavaScript.fromString name) (safeEvaluator fn)

-- Include or exclude the class on each element depending on the result of `fn`.
--
--   classed name fn
--
-- is equivalent to
--
--   context.classed(name, fn);
--
classed : String -> (a -> Int -> Bool) -> Selection a
classed name fn =
  Native.D3.Selection.classed (JavaScript.fromString name) (safePredicate fn)

-- Set the HTML content of each element as determined by `fn`.
--
--   html fn
--
-- is equivalent to
--
--   context.html(fn);
--
html : (a -> Int -> String) -> Selection a
html fn = Native.D3.Selection.html (safeEvaluator fn)

-- Set the text content of each element as determined by `fn`.
--
--   text fn
--
-- is equivalent to
--
--   context.text(fn);
--
text : (a -> Int -> String) -> Selection a
text fn = Native.D3.Selection.text (safeEvaluator fn)

-- String casting helper for attr and similar functions.
--
--   num op name fn
--
-- is equivalent to
--
--   context.op(name, function() { return n; });
--
num : (String -> (a -> Int -> String) -> Selection a) -> String -> number -> Selection a
num a name v = a name (\_ _ -> show v)

-- String casting helper for attr and similar functions.
--
--   str op name string
--
-- is equivalent to
--
--   context.op(name, function() { return string; });
--
str : (String -> (a -> Int -> String) -> Selection a) -> String -> String -> Selection a
str a name v = a name (\_ _ -> v)

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
delay fn = Native.D3.Transition.delay (safeTransition fn)

-- Set the per-element duration of a transition.
--
--   delay fn
--
-- is equivalent to
--
--   context.delay(fn);
--
duration : (a -> Int -> Int) -> Selection a
duration fn = Native.D3.Transition.duration (safeTransition fn)

-------------------------------------------------------------------------------
-- Internal functions

safeEvaluator fn a i = JavaScript.fromString (fn a (JavaScript.toInt i))
safePredicate fn a i = JavaScript.fromBool (fn a (JavaScript.toInt i))
safeTransition fn a i = JavaScript.fromInt (fn a (JavaScript.toInt i))
