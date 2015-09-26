module D3.Event
  ( Stream
  , KeyboardEvent
  , MouseEvent
  , InputEvent
  , stream  -- : () -> Stream e
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

{-| Event handlers

# Types
@docs Stream, MouseEvent, KeyboardEvent, InputEvent

# Operators
@docs stream, folde

# Mouse Events
@docs click, dblclick, mousedown, mouseenter, mouseleave, mousemove, mouseout, mouseover, mouseup

# Keyboard Events
@docs keyup, keydown, keypress

# Other Events
@docs input, focus, blur
-}

import D3 exposing (..)
import Native.D3.Event
import Signal
import String


type Event e
  = Start
  | Event e

{-| An event stream. Event handlers exported by this module take this sort of
stream and inject events into it. -}
type alias Stream e = Signal (Event e)

{-| Create a new `Stream`. Note that this is an effectful operation. -}
stream : () -> Stream e
stream () = Signal.constant Start

{-| This is the equivalent of `Signal.foldp`, except over streams. The
difference between the two is that `folde` requires a default value. -}
folde : (e -> b -> b) -> b -> Stream e -> Signal b
folde f m =
  let g e n =
    case e of
      -- N.B. the start event will reset the accumulator to the initial value.
      Start -> m
      Event e -> f e n
    in Signal.foldp g m


-- Mouse event datatypes and handlers
--

{-|-}
type alias MouseEvent = {
  altKey : Bool,
  button : Int,
  ctrlKey : Bool,
  metaKey : Bool,
  shiftKey : Bool
}

type alias MouseHandler e a = Stream e -> (MouseEvent -> a -> Int -> e) -> D3 a a

{-|-}
handleMouse : String -> MouseHandler e a
handleMouse e s f = Native.D3.Event.handleMouse e s (\m a i -> Event (f m a i))

{-|-}
click : MouseHandler e a
click = handleMouse "click"

{-|-}
dblclick : MouseHandler e a
dblclick = handleMouse "dblclick"

{-|-}
mousedown : MouseHandler e a
mousedown = handleMouse "mousedown"

{-|-}
mouseenter : MouseHandler e a
mouseenter = handleMouse "mouseenter"

{-|-}
mouseleave : MouseHandler e a
mouseleave = handleMouse "mouseleave"

{-|-}
mousemove : MouseHandler e a
mousemove = handleMouse "mousemove"

{-|-}
mouseout : MouseHandler e a
mouseout = handleMouse "mouseout"

{-|-}
mouseover : MouseHandler e a
mouseover = handleMouse "mouseover"

{-|-}
mouseup : MouseHandler e a
mouseup = handleMouse "mouseup"

-- Keyboard event datatypes and handlers
--

{-|-}
type alias KeyboardEvent = {
  altKey : Bool,
  keyCode : Int,
  ctrlKey : Bool,
  metaKey : Bool,
  shiftKey : Bool
}

type alias KeyboardHandler e a = Stream e -> (KeyboardEvent -> a -> Int -> e) -> D3 a a

{-|-}
handleKeyboard : String -> KeyboardHandler e a
handleKeyboard e s f = Native.D3.Event.handleKeyboard e s (\m a i -> Event (f m a i))

{-|-}
keyup : KeyboardHandler e a
keyup = handleKeyboard "keyup"

{-|-}
keydown : KeyboardHandler e a
keydown = handleKeyboard "keydown"

{-|-}
keypress : KeyboardHandler e a
keypress = handleKeyboard "keypress"


-- Input event datatypes and handlers
--

{-|-}
type alias InputEvent = String

type alias InputHandler e a = Stream e -> (InputEvent -> a -> Int -> e) -> D3 a a

{-|-}
input : InputHandler e a
input s f = Native.D3.Event.handleInput s (\m a i -> Event (f m a i))

-- Focus/Blur handlers
--

type alias BasicHandler e a = Stream e -> (a -> Int -> e) -> D3 a a

{-|-}
focus : BasicHandler e a
focus s f = Native.D3.Event.handleFocus s (\a i -> Event (f a i))

{-|-}
blur : BasicHandler e a
blur s f = Native.D3.Event.handleBlur s (\a i -> Event (f a i))
