-- This is a counter example using elm-d3, a response to this post:
--
--   http://www.reddit.com/r/programming/comments/t6p0a/elm_a_new_language_for_functionalreactive_web/c4k4pnw
--
-- To build this app, from the root directory of the elm-d3 project, compile it
-- using the following commands:
--
--   make
--   elm --make --src-dir=src `./scripts/build-flags` `./scripts/include-css examples/counters.css` examples/Counters.elm
--
-- On OS X, you can then open the file in the browser using the following command:
--
--   open build/examples/Counters.html
--
module Counters where

import Dict
import List

import D3(..)
import D3.Event(..)

-------------------------------------------------------------------------------
-- The Model

type Model = {
  dict : Dict.Dict Int Int,
  next : Int
}

increment : Int -> Dict.Dict Int Int -> Dict.Dict Int Int
increment i d =
  let plus m = case m of
    Nothing -> Nothing      -- assert false
    Just n  -> Just (n + 1)
  in
  Dict.update i plus d

decrement : Int -> Dict.Dict Int Int -> Dict.Dict Int Int
decrement i d =
  let minus m = case m of
    Nothing -> Nothing      -- assert false
    Just n  -> Just (n - 1)
  in
  Dict.update i minus d


-------------------------------------------------------------------------------
-- The Events

data Event
  = Create
  | Increment Int
  | Decrement Int
  | Remove    Int

handler : Event -> Model -> Model
handler e m = case e of
  Create      -> let next' = m.next + 1 in
                 { next = next', dict = Dict.insert next' 0 m.dict }
  Increment i -> { m | dict <- increment i m.dict }
  Decrement i -> { m | dict <- decrement i m.dict }
  Remove    i -> { m | dict <- Dict.remove i m.dict }

events : Stream Event
events = stream ()


-------------------------------------------------------------------------------
-- The View
--

creator : D3 a a
creator =
  static "div" <.> str attr "class" "box creator"
  |. text (\_ _ -> "create counter")
  |. click events (\_ _ _ -> Create)

counters : D3 Model (Int, Int)
counters =
  selectAll "div.counter"
  |= (\m -> List.sortBy fst (Dict.toList m.dict))
     |- (enter <.> append "div"
        |. str attr "class" "counter"
        |- (append "div" <.> str attr "class" "box display")
        |- (append "div" <.> str attr "class" "box increment"
           |. text (\_ _ -> "+"))
        |- (append "div" <.> str attr "class" "box decrement"
           |. text (\_ _ -> "-"))
        |- (append "div" <.> str attr "class" "box remove"
           |. html (\_ _ -> "&#10007;")))
     |- update <.> select "div.display"
        |. text (\(_, d) _ -> show d)
     |- update <.> select "div.increment"
        |. click events (\_ (n, _) _ -> Increment n)
     |- update <.> select "div.decrement"
        |. click events (\_ (n, _) _ -> Decrement n)
     |- update <.> select "div.remove"
        |. click events (\_ (n, _) _ -> Remove n)
     |- exit
        |. remove

view : D3 Model Model
view =
  let counters' =
    static "div" <.> str attr "class" "counters"
    |. counters
  in
  sequence creator counters'


-------------------------------------------------------------------------------
-- The Application
--

controller : Stream Event -> Signal Model
controller =
  let initialModel = { next = 0, dict = Dict.empty } in
  folde handler initialModel

main : Signal Element
main = render 800 600 view <~ (controller events)
