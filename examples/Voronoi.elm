-- This is an Elm reimplementation of a popular Voronoi diagram example using
-- elm-d3. The original can be found here:
--
--   http://bl.ocks.org/mbostock/4060366
--
-- From the root directory of the elm-d3 project, compile it using the
-- following commands:
--
--   make
--   elm --make --src-dir=src `./scripts/build-flags` `./scripts/include-css examples/voronoi.css` examples/Voronoi.elm
--
-- On OS X, you can then open the file in the browser using the following
-- command:
--
--   open build/examples/Voronoi.html
--
module Voronoi where

-- Import D3 and dump all its names into the current scope. Also import Voronoi
-- diagram-related operations, but keep those names qualified.
--
import D3(..)
import D3.Voronoi

-- Import Mouse to access the mouse's position. Also import Random and dump its
-- names into the current scope.
--
import Mouse
import Random(..)

-- Type declaractions for records that represent dimensions and margins.
--
type Dimensions = { height : Float, width : Float }
type Margins = { top : Float, left : Float, right : Float, bottom : Float }


width = 960
height = 500

margin = { top = 0, left = 0, right = 0, bottom = 0 }
dims   = { height = height - margin.top - margin.bottom
         , width  = width - margin.left - margin.right }

-- A function that will create an <svg> element with a nested <g> element. The
-- function will use the given dimensions and margins the set the width and
-- height of the <svg> element.
--

svg : Dimensions -> Margins -> D3 a a
svg ds ms =
  static "svg"
  |. num attr "height" (ds.height + ms.top + ms.bottom)
  |. num attr "width"  (ds.width  + ms.left + ms.right)
  |. static "g"
     |. str attr "transform" (translate margin.left margin.top)

circles : D3 [D3.Voronoi.Point] D3.Voronoi.Point
circles =
  selectAll "circle"
  |= tail
     |- enter <.> append "circle"
        |. num attr "r" 1.5
        |. str attr "fill" "black"
     |- update
        |. fun attr "cx" (\p _ -> show p.x)
        |. fun attr "cy" (\p _ -> show p.y)

voronoi : D3 [D3.Voronoi.Point] [D3.Voronoi.Point]
voronoi =
  selectAll "path"
  |. bind cells
     |- enter <.> append "path"
     |- update
        |. fun attr "d" (\ps _ -> path ps)
        |. fun attr "class" (\_ i -> "q" ++ (show ((%) i 9)) ++ "-9")

cells : [D3.Voronoi.Point] -> [[D3.Voronoi.Point]]
cells = D3.Voronoi.cellsWithClipping margin.right margin.top dims.width dims.height

-- Helper function for creating an SVG path string for the given polygon.
--
path : [D3.Voronoi.Point] -> String
path ps =
  let pair p = (show p.x) ++ "," ++ (show p.y)
    in "M" ++ (join "L" (map pair ps)) ++ "Z"

-- Helper function for creating an SVG transformation string that represents a
-- translation.
--
translate : number -> number -> String
translate x y = "translate(" ++ (show x) ++ "," ++ (show y) ++ ")"

-- Generates a list of random points of the given length. The list is returned
-- as a Signal, thought the signal will never take on any other value.
--
randomPoints : Int -> Signal [D3.Voronoi.Point]
randomPoints n =
  let mk_point x y = { x = x * dims.width , y = y * dims.height } in
    zipWith mk_point <~ (floatList (constant n)) ~ (floatList (constant n))

vis dims margin =
  svg dims margin
  |- voronoi
  |- circles

main : Signal Element
main =
  let mouse (x, y) = { x = (toFloat x) - margin.left, y = (toFloat y) - margin.top }
      points = (\m ps -> mouse m :: ps) <~ Mouse.position ~ (randomPoints 100)
    in render dims.width dims.height (vis dims margin) <~ points
