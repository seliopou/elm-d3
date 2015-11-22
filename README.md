# elm-d3

elm-d3 provides [Elm][elm] bindings for [d3.js][d3]. It enables you to create
type-safe, composable widgets using HTML, SVG, and CSS. D3 acts as a conceptual
basis for the library, as well as an alternative renderer for Elm.

[elm]: http://elm-lang.org
[d3]: http://d3js.org

## Installation

First make sure that you have [node.js][node] installed, as well as the
[Elm][elm] compiler. Once you've installed those dependencies, clone the elm-d3
repository and run the following command from the root directory:

    elm-make

This will locally install the [smash][] utility and build the library.

[node]: http://nodejs.org/
[elm]: https://github.com/evancz/elm
[smash]: https://github.com/mbostock/smash

To get an example compiled and running in your browser, use the following
command:

    elm-make examples/Circles.elm --output circles.html

You must then edit the HTML file and add a `<script>` tag that will load the
D3.js library. (Unfortunately, it is no longer possible to control linking of
external JavaScript code using the Elm compiler, so this manual step is
necessary.) Then, load it up on your browser:

    open build/examples/circles.html

If you're not using OS X, the last command won't work. In that case open
`circles.html` however you normally would in your operating system. Once the
page is open, move your mouse left and right to add and remove circles, and
move your mouse up and down to change their brightness.

## Conceptual Prerequisites

In order to effectively use elm-d3, you should be familiar with the core
concepts of D3.js, including data joins, nested selections, and reusable
charts. The following series of blog posts by [@mbostock][] introduce these
concepts quite nicely, and independently of elm-d3 should be read by anybody
that is interested in developing their D3.js skills:

* [Thinking in Joins][join]
* [Nested Selections][nest]
* [Towards Reusable Charts][chart]

[join]: http://bost.ocks.org/mike/join/
[nest]: http://bost.ocks.org/mike/nest/
[chart]: http://bost.ocks.org/mike/chart/

[@mbostock]: https://twitter.com/mbostock

## Usage

elm-d3 is designed to be a very literal interpretation of the D3.js API. In
fact, any D3.js code that uses only the [Core Selection API][core] should be
fairly straightforward to port over to elm-d3. For example, here's a fragment
of code taken from the [Voronoi Diagram example][voronoi] ([original D3.js
version][voronoi-original]):

```elm
voronoi : D3 [D3.Voronoi.Point] [D3.Voronoi.Point]
voronoi =
  selectAll "path"
  |. bind cells
     |- enter <.> append "path"
     |- update
        |. fun attr "d" (\ps _ -> path ps)
        |. fun attr "class" (\_ i -> "q" ++ (show ((%) i 9)) ++ "-9")
```

Operations such as `selectAll`, `enter`, and `attr` have the same behavior as
their D3.js counterparts. The `bind` operation is equivalent to the `data()`
operator from D3.js, though it requires its argument to be a function.
Similarly, `attr` also requires a function as its second argument, which takes
the data bound to the element and the element's index in the selection. Another
difference is that elm-d3 replaces method chaining with the `|.` operator. For
example,

```elm
selectAll "path"
|. bind cells
```

is equivalent to

```javascript
d3.selectAll("path")
  .data(cells)
```

Sequencing is another operation that's slightly different in elm-d3. In Javascript,
there's a common pattern where you apply a data bound to a selection, assign it
to a variable, and then apply `enter()`, update, and `exit()` operations to the
variable. In place of sequencing, you would use the `|-` infix operator. Its
use is illustrated in the example above. You can see the equivalent code in JavaScript below.

```javascript
var path = d3.selectAll('path')
    .bind(function(d) { ... });

path.enter()
  .append('path');

path
    .attr('d', function(d) { ... })
    .attr('class', function(d) { ... });
```

[core]: https://github.com/mbostock/d3/wiki/Selections
[voronoi]: https://github.com/seliopou/elm-d3/blob/master/examples/Voronoi.elm
[voronoi-original]: http://bl.ocks.org/mbostock/4060366

## Rendering

Creating a selection such as `voronoi` above does not actually draw anything to
the screen. Rather, it defines a computation that the runtime knows how to draw
to the screen. To do this, you use the `render` function. Its first two
arguments are the height and width of the drawing area. The third is the `D3 a
b` that will be rendered. The final argument is the datum of type `a` that will
be bound to the selection. The result is an `Element` that the Elm runtime
knows what to do with:

```elm
main : Element
main = render 800 600 voronoi [{x: 200, y: 200}, {x: 320, y:100}]
```

### Further documentation

For more information about the API, the source file in [`src/D3.elm`][d3elm].
Each function is preceded by a comment describing the equivalent expression in
JavaScript. Types are also very instructive.

[d3elm]: https://github.com/seliopou/elm-d3/blob/master/src/D3.elm

# License

BSD3, see LICENSE file for its text.
