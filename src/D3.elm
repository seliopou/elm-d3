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
  ) where

import Native.D3.Render
import Native.D3.Selection
import String
import JavaScript


data Selection a = Selection

version : String
version = JavaScript.toString Native.D3.version

-------------------------------------------------------------------------------
-- Selection-to-Runtime API

render : number -> number -> Selection a -> Selection a -> a -> Element
render = Native.D3.Render.render

render' : (a -> (number, number)) -> Selection a -> Selection a -> a -> Element
render' dims root selection datum =
  let (width, height) = dims datum
    in render width height root selection datum

-------------------------------------------------------------------------------
-- Core Selection API

sequence : Selection a -> Selection a -> Selection a
sequence = Native.D3.Selection.sequence

chain : Selection a -> Selection a -> Selection a
chain = Native.D3.Selection.chain

infixl 4 |.
(|.) : Selection a -> Selection a -> Selection a
(|.) = chain

select : String -> Selection a
select = Native.D3.Selection.select . JavaScript.fromString

selectAll : String -> Selection a
selectAll = Native.D3.Selection.selectAll . JavaScript.fromString

append : String -> Selection a
append = Native.D3.Selection.append . JavaScript.fromString

remove : Selection a
remove = Native.D3.Selection.remove

bind : (a -> [b]) -> Selection b -> Selection b -> Selection b -> Selection a
bind fn = Native.D3.Selection.bind (JavaScript.fromList . fn)

enter : Selection a
enter = Native.D3.Selection.enter

update : Selection a
update = Native.D3.Selection.update

exit : Selection a
exit = Native.D3.Selection.exit

-------------------------------------------------------------------------------
-- Operators

attr : String -> (a -> Int -> String) -> Selection a
attr name fn =
  Native.D3.Selection.attr (JavaScript.fromString name) (safeEvaluator fn)

style : String -> (a -> Int -> String) -> Selection a
style name fn =
  Native.D3.Selection.style (JavaScript.fromString name) (safeEvaluator fn)

property : String -> (a -> Int -> String) -> Selection a
property name fn =
  Native.D3.Selection.property (JavaScript.fromString name) (safeEvaluator fn)

classed : String -> (a -> Int -> Bool) -> Selection a
classed name fn =
  Native.D3.Selection.classed (JavaScript.fromString name) (safePredicate fn)

html : (a -> Int -> String) -> Selection a
html fn = Native.D3.Selection.html (safeEvaluator fn)

text : (a -> Int -> String) -> Selection a
text fn = Native.D3.Selection.text (safeEvaluator fn)

-------------------------------------------------------------------------------
-- Internal functions

safeEvaluator fn a i = JavaScript.fromString (fn a (JavaScript.toInt i))
safePredicate fn a i = JavaScript.fromBool (fn a (JavaScript.toInt i))
