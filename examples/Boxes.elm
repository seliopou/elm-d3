module Boxes where

import D3(..)
import Mouse

size   = 300
margin = { top = 10, left = 10, right = 10, bottom = 10 }
dims   = { height = size - margin.top - margin.bottom
         , width  = size - margin.left - margin.right }

type Dimensions = { height : Float, width : Float }
type Margins = { top : Float, left : Float, right : Float, bottom : Float }

svg : Dimensions -> Margins -> D3 a a
svg ds ms =
  static "svg"
  |. num attr "height" (ds.height + ms.top + ms.bottom)
  |. num attr "width"  (ds.width  + ms.left + ms.right)
  |. static "g"
     |. str attr "transform" (translate margin.left margin.top)

boxes : D3 (number, number) (number, number, String)
boxes =
  selectAll ".box"
  |= (\(x, y) -> [(x, 0, "cyan"), (0, y, "magenta")])
     |- enter <.> append "rect"
        |. str attr "class" "box"
        |. num attr "width"  100
        |. num attr "height" 100
        |. fun attr "fill"   (\(_, _, c) _ -> c)
     |- update
        |. fun attr "x" (\(x, _, _) _ -> show x)
        |. fun attr "y" (\(_, y, _) _ -> show y)
     |- exit
        |. remove

translate : number -> number -> String
translate x y = "translate(" ++ (show x) ++ "," ++ (show y) ++ ")"

vis dims margin =
  svg dims margin
  |. boxes

main : Signal Element
main = render dims.height dims.width (vis dims margin) <~ Mouse.position
