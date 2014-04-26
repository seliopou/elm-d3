module D3.Event
  ( stream  -- : () -> Stream e
  , folde   -- : (e -> b -> b) -> b -> Stream e -> Signal b

  , click       -- : MouseHandler e a
  , dblclick    -- : MouseHandler e a
  , mousedown   -- : MouseHandler e a
  , mouseenter  -- : MouseHandler e a
  , mouseleave  -- : MouseHandler e a
  , mousemove   -- : MouseHandler e a
  , mouseout    -- : MouseHandler e a
  , mouseover   -- : MouseHandler e a
  , mouseup     -- : MouseHandler e a

  ) where

import D3(..)
import Native.D3.Event
import Signal
import String


data Event e
  = Start
  | Event e

type Stream e = Signal (Event e)

stream : () -> Stream e
stream () = Signal.constant Start

folde : (e -> b -> b) -> b -> Stream e -> Signal b
folde f m =
  let g e n =
    case e of
      -- N.B. the start event will reset the accumulator to the initial value.
      Start -> m
      Event e -> f e n
    in foldp g m


-- Mouse event datatypes and handlers
--

type MouseEvent = {
  altKey : Bool,
  button : Int,
  ctrlKey : Bool,
  metaKey : Bool,
  shiftKey : Bool
}

type MouseHandler e a = Stream e -> (MouseEvent -> a -> Int -> e) -> Selection a

handleMouse : String -> MouseHandler e a
handleMouse e s f = Native.D3.Event.handleMouse e s (\m a i -> Event (f m a i))

click : MouseHandler e a
click = handleMouse "click"

dblclick : MouseHandler e a
dblclick = handleMouse "dblclick"

mousedown : MouseHandler e a
mousedown = handleMouse "mousedown"

mouseenter : MouseHandler e a
mouseenter = handleMouse "mouseenter"

mouseleave : MouseHandler e a
mouseleave = handleMouse "mouseleave"

mousemove : MouseHandler e a
mousemove = handleMouse "mousemove"

mouseout : MouseHandler e a
mouseout = handleMouse "mouseout"

mouseover : MouseHandler e a
mouseover = handleMouse "mouseover"

mouseup : MouseHandler e a
mouseup = handleMouse "mouseup"
