module D3.Event
  ( start   -- : () -> Stream e
  , folde   -- : (e -> b -> b) -> b -> Stream e -> Signal b
  ) where

import open D3
import Signal
import String


data Event e
  = Start
  | Event e

type Stream e = Signal (Event e)

start : () -> Stream e
start () = Signal.constant Start

folde : (e -> b -> b) -> b -> Stream e -> Signal b
folde f m =
  let g e n =
    case e of
      -- N.B. the start event will reset the accumulator to the initial value.
      Start -> m
      Event e -> f e n
    in foldp g m
