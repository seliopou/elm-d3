# elm-d3

elm-d3 provides [Elm][elm] bindings for [d3.js][d3], effectively making your d3
code statically typed, pure, and, reactive, and your widgets composable.

[elm]: http://elm-lang.org
[d3]: http://d3js.org

## Installation

First make sure that you have [node.js][node] installed, as well as the
[Elm][elm] compiler. Note that elm-d3 currently requires that you install the
compiler from the [current development branch][dev]. Once you've installed
those dependencies, clone the elm-d3 repository and run the following commands
from the root directory:

    npm install smash
    make

This will locally install the [smash][] utility and build three files in the
root directory of the elm-d3 repository. They'll come in handy later.

[node]: http://nodejs.org/
[elm]: https://github.com/evancz/elm
[dev]: https://github.com/evancz/elm/tree/dev
[smash]: https://github.com/mbostock/smash

* `elm-d3.library.js`: contains all compiled code;
* `elm-d3.runtime.js`: contains supporting, non-compiled JavaScript code;
  and
* `elm-d3.js`: the previous two files, concatenated.

To get an example compiled and running in your browser using the following
commands:

    elm --make --src-dir=src `./scripts/build-flags` examples/Circles.elm
    open build/examples/Circles.html

If you're not using OS X, the last command won't work. In that case open
`build/examples/Circles.html` however you normally would in your operating
system. Once the page is open, move your mouse left and right to add and remove
circles, and move your mouse up and down to change their brightness.

## Usage

At the heart of this library is the `Selection a` type. It represents a d3
selection joined with one or more values of type `a`. Just like in d3, you can
construct selections using `select` and `selectAll`, and perform operations on
selections using functions like `attr` and `style`. You can also chain those
operations together useing the `chain` function or the infix operator `|.`.
Both do the same thing&mdash;in essence, method chaining.

Creating a `Selection a` doesn't actually draw anything on the screen. Think of
it more along the lines of a [reusable chart][chart] that you can build up
incrementally. In order to render a `Selection a`, you have to pass it to the
`render` function somewhere within the `main` entry point of your Elm program.

[chart]: http://bost.ocks.org/mike/chart/

### Example

Here's an example of using elm-d3 to draw two rectangles. One follows the
x-component of your mouse position, and the other follows y-component of your
mouse position. You can find this example in the `examples` directory of this
repository.

[black]: http://rampantgames.com/blog/2004/10/black-triangle.html

```haskell
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

boxes : Selection (number, number)
boxes = 
  selectAll ".box"
  |. bind (\(x, y) -> [(x, 0, "cyan"), (0, y, "magenta")])
     -- enter
     (append "rect"
     |. str attr "class" "box"
     |. num attr "width"  100
     |. num attr "height" 100
     |. attr     "fill"   (\(_, _, c) _ -> c))
     -- update
     (update
     |. attr "x" (\(x, _, _) _ -> show x)
     |. attr "y" (\(_, y, _) _ -> show y))
     -- exit
     remove

translate : number -> number -> String
translate x y = "translate(" ++ (show x) ++ "," ++ (show y) ++ ")"

main : Signal Element
main = render dims.height dims.width (svg dims margin) boxes <~ Mouse.position
```

It's common practice when using d3 to start building your svg document with an
initial group child element with a transform attribute to setup margins. Pass
the `svg` function a `Dimensions` record and a `Margins` record and will return
a `Selection a` that, when renderd, will do just that.

The `boxes` selection demonstrates how to do data joins in elm-d3. You setup
your initial selection using `selectAll`, and then method chain a call to
`bind`, which is like calling `.data()` in JavaScript. `bind`'s first argument
is a function that will take the data bound to the context and transform it
into a list values&dmash;in this case tuples of type `(number, number,
String)`. This list of tuples is joined to the selection. The next three
arguments are `Selection (number, number, String)`s that are applied to the
enter, update, and exit selections, respectively.

Since elm is statically typed, you have to cast values manually. For example,
`attr` will set the value of an attribute on a per-element basis, which means
you have to pass it a function that will take the data bound to the element as
well as its index, and produce a string. (All attributes on DOM elements are
strings, after all.)

```haskell
attr : String -> (a -> Int -> String) -> Selection a
```

If however, you want to set the value of an attribute to a constant number for
every element in the selection, you can't pass that number directly to `attr`.
You either have to wrap it in a function:

```haskell
attr "height" (\_ _ -> 100)
```

Or you can use the `num` helper function before your application of `attr`

```haskell
num attr "height" 100
```

There's also a `str` function that serves a similar purpose, except for string
constants.

`render` actually draws `Selection a` to the screen. Its first two arguments
are the height and width of the drawing area. These are used by the elm runtime
propertly lay out graphical elements. The third argument is a `Selection a`
that sets up the initial document. The fourth is a `Selection a` that may
change depending on the datum, and the final argument is the datum of type `a`.
In this case, we're getting or datum from a signal of mouse positions. Whenever
the mouse position updates, the Elm runtime will automatically update screen to
reflect those changes.

### Further documentation

For more information about the API, the source file in [`src/D3.elm`][d3elm].
Each function is preceded by a comment describing the equivalent expression in
JavaScript. Types are also very instructive.

[d3elm]: https://github.com/seliopou/elm-d3/blob/master/src/D3.elm

# Compatibility

Curently elm-d3 requires that you use the [current development branch][dev] of
the Elm compiler. The dev branch supports the `--src-dir` compiler flags that
the Makefile uses. This flag also makes it easier to use the elm-d3 library in
other projects without duplicating code.

Besides that, elm-d3 uses the new efficent String library that will be included
in the next release. In addition, the native code included in this library uses
also uses the new API for module initialization, which makes it incompatible
with previous compiler versions.

# License

BSD3, see LICENSE file for its text.
