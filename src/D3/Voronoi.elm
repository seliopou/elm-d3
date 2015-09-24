module D3.Voronoi
  ( cells
  , cellsWithClipping
  , Point
  ) where

import Native.D3.Voronoi
import String

type alias Point = { x : Float, y : Float }

cells : List Point -> List (List Point)
cells = Native.D3.Voronoi.cells

cellsWithClipping : Float -> Float -> Float -> Float -> List Point -> List (List Point)
cellsWithClipping = Native.D3.Voronoi.cellsWithClipping
