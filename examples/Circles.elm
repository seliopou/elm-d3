module Circles where

import D3(..)
import D3.Color 
import Mouse

size   = 375
margin = { top = 25, left = 25, right = 25, bottom = 25 }
dims   = { height = size - margin.top - margin.bottom
         , width  = size - margin.left - margin.right }

type Dimensions = { height : Int, width : Int }
type Margins = { top : Int, left : Int, right : Int, bottom : Int }

svg : Dimensions -> Margins -> D3 a a
svg ds ms =
  static "svg"
  |. num attr "height" (ds.height + ms.top + ms.bottom)
  |. num attr "width"  (ds.width  + ms.left + ms.right)
  |. static "g"
     |. str attr "transform" (translate margin.left margin.top)

-- Move the mouse to the left to right to remove or add circles. Move the mouse
-- up and down to change the brightness of the circles.
circles : D3 (number, number) number
circles =
  selectAll "circle"
  |= (\(x, y) -> repeat (x // 50) y)
     |- enter <.> append "circle"
        |. fun attr "fill" color
        |. num attr "r"    0
        |. num attr "cy"   150
        |. fun attr "cx"   (\_ i -> show (25 + 50 * i))
        |. transition
           |. num attr "r" 25
     |- update
        |. fun attr "fill" color
     |- exit
        |. remove

color : number -> number -> String
color y i =
  let steelBlue = D3.Color.fromString "steelblue"
      magnitude = (2 * toFloat y / toFloat dims.height) ^ (toFloat i / 2)
    in D3.Color.toString (D3.Color.darker magnitude steelBlue)

translate : number -> number -> String
translate x y = "translate(" ++ (show x) ++ "," ++ (show y) ++ ")"

vis dims margin =
  svg dims margin
  |. circles

main : Signal Element
main = render dims.width dims.height (vis dims margin) <~ Mouse.position
