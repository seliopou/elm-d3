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

  , keyup       -- : KeyboardEvent e a
  , keydown     -- : KeyboardEvent e a
  , keypress    -- : KeyboardEvent e a

  , input       -- : InputEvent e a

  , focus       -- : BasicHandler e a
  , blur        -- : BasicHandler e a
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

-- Keyboard event datatypes and handlers
--

type KeyboardEvent = {
  altKey : Bool,
  keyCode : Int,
  ctrlKey : Bool,
  metaKey : Bool,
  shiftKey : Bool
}

type KeyboardHandler e a = Stream e -> (KeyboardEvent -> a -> Int -> e) -> Selection a

handleKeyboard : String -> KeyboardHandler e a
handleKeyboard e s f = Native.D3.Event.handleKeyboard e s (\m a i -> Event (f m a i))

keyup : KeyboardHandler e a
keyup = handleKeyboard "keyup"

keydown : KeyboardHandler e a
keydown = handleKeyboard "keydown"

keypress : KeyboardHandler e a
keypress = handleKeyboard "keypress"


-- Input event datatypes and handlers
--

type InputEvent = String

type InputHandler e a = Stream e -> (InputEvent -> a -> Int -> e) -> Selection a

input : InputHandler e a
input s f = Native.D3.Event.handleInput s (\m a i -> Event (f m a i ))

-- Focus/Blur handlers
--

type BasicHandler e a = Stream e -> (a -> Int -> e) -> Selection a

focus : BasicHandler e a
focus s f = Native.D3.Event.handleFocus s (\a i -> Event (f a i))

blur : BasicHandler e a
blur s f = Native.D3.Event.handleBlur s (\a i -> Event (f a i))
