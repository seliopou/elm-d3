module D3.Voronoi
  ( cells
  , cellsWithClipping
  ) where

import Native.D3.Voronoi
import String

type Point = { x : Float, y : Float }

cells : [Point] -> [[Point]]
cells = Native.D3.Voronoi.cells

cellsWithClipping : Float -> Float -> Float -> Float -> [Point] -> [[Point]]
cellsWithClipping = Native.D3.Voronoi.cellsWithClipping
