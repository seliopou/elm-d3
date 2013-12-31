module Boxes where

import open D3
import Mouse

size   = 300
margin = { top = 10, left = 10, right = 10, bottom = 10 }
dims   = { height = size - margin.top - margin.bottom
         , width  = size - margin.left - margin.right }

type Dimensions = { height : number, width : number }
type Margins = { top : number, left : number, right : number, bottom : number }

svg : Dimensions -> Margins -> Selection a
svg ds ms =
  append "svg"
  |. num attr "height" (ds.height + ms.top + ms.bottom)
  |. num attr "width"  (ds.width  + ms.left + ms.right)
  |. append "g"
     |. str attr "transform" (translate margin.left margin.top)

boxes : Widget (number, number) (number, number, String)
boxes =
  selectAll ".box"
  |= (\(x, y) -> [(x, 0, "cyan"), (0, y, "magenta")])
     |- enter <.> append "rect"
        |. str attr "class" "box"
        |. num attr "width"  100
        |. num attr "height" 100
        |. attr     "fill"   (\(_, _, c) _ -> c)
     |- update
        |. attr "x" (\(x, _, _) _ -> show x)
        |. attr "y" (\(_, y, _) _ -> show y)
     |- exit
        |. remove

translate : number -> number -> String
translate x y = "translate(" ++ (show x) ++ "," ++ (show y) ++ ")"

main : Signal Element
main = render dims.height dims.width (svg dims margin) (embed boxes) <~ Mouse.position
