module Voronoi where

import open D3
import D3.Voronoi
import Mouse
import open Random

width = 960
height = 500
margin = { top = 0, left = 0, right = 0, bottom = 0 }

dims   = { height = height - margin.top - margin.bottom
         , width  = width - margin.left - margin.right }

type Dimensions = { height : Float, width : Float }
type Margins = { top : Float, left : Float, right : Float, bottom : Float }

svg : Dimensions -> Margins -> Selection a
svg ds ms =
  static_ "svg"
  |. num attr "height" (ds.height + ms.top + ms.bottom)
  |. num attr "width"  (ds.width  + ms.left + ms.right)
  |. static_ "g"
     |. str attr "transform" (translate margin.left margin.top)

circles : Widget [D3.Voronoi.Point] D3.Voronoi.Point
circles =
  selectAll "circle"
  |= tail
     |- enter <.> append "circle"
        |. num attr "r" 1.5
        |. str attr "fill" "black"
     |- update
        |. attr "cx" (\p _ -> show p.x)
        |. attr "cy" (\p _ -> show p.y)

voronoi : Widget [D3.Voronoi.Point] [D3.Voronoi.Point]
voronoi =
  selectAll "path"
  |= cells
     |- enter <.> append "path"
     |- update
        |. attr "d" (\ps _ -> path ps)
        |. attr "class" (\_ i -> "q" ++ (show (mod i 9)) ++ "-9")

cells : [D3.Voronoi.Point] -> [[D3.Voronoi.Point]]
cells = D3.Voronoi.cellsWithClipping margin.right margin.top dims.width dims.height

path : [D3.Voronoi.Point] -> String
path ps =
  let pair p = (show p.x) ++ "," ++ (show p.y)
    in "M" ++ (join "L" (map pair ps)) ++ "Z"

translate : number -> number -> String
translate x y = "translate(" ++ (show x) ++ "," ++ (show y) ++ ")"

randomPoints : Int -> Signal [D3.Voronoi.Point]
randomPoints n =
  let mk_point x y = { x = x * dims.width , y = y * dims.height } in
    zipWith mk_point <~ (floatList (constant n)) ~ (floatList (constant n))

vis dims margin =
  svg dims margin
  |-^ voronoi
  |-^ circles

main : Signal Element
main =
  let mouse (x, y) = { x = (toFloat x) - margin.left, y = (toFloat y) - margin.top }
      points = (\m ps -> mouse m :: ps) <~ Mouse.position ~ (randomPoints 100)
    in render dims.width dims.height (vis dims margin) <~ points
