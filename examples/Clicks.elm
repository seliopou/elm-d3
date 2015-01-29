module Clicks where

import String

import D3(..)
import D3.Event

data Pos
  = Left
  | Middle
  | Right

type Model = { left : Int, middle : Int, right : Int }

events : D3.Event.Stream Pos
events = D3.Event.stream ()

view : D3 Model (Pos, Int)
view =
  selectAll "div"
  |= (\c -> [(Left, c.left), (Middle, c.middle), (Right, c.right)])
     |- enter <.> append "div"
        |. str attr "class" "box"
        |. D3.Event.click events (\e (p, _) _ -> p)
     |- update
        |. text (\(_, n) _ -> show n)
     |- exit
        |. remove

transform : Pos -> Model -> Model
transform pos c =
  let incr m = m + 1 in
  case pos of
    Left   -> { c | left   <- incr c.left }
    Middle -> { c | middle <- incr c.middle }
    Right  -> { c | right  <- incr c.right }

controller : Signal Model
controller =
  let initial = { left = 0, middle = 0, right = 0 } in
  D3.Event.folde transform initial events

main : Signal Element
main = render 900 200 view <~ controller
