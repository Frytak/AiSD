#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3": plot, chart

#let draw-rectangle-plot(csv-file, func, label, domain, image, caption) = {
  let rectangles-raw = csv(csv-file)
  let rectangles-width = float(rectangles-raw.at(0).at(0))
  let rectangles = rectangles-raw.slice(1).map(row => float(row.at(0)))

  figure(
    cetz.canvas({
      plot.plot(size: (8, 8),
                x-grid: true, y-grid: true,
                x-tick-step: 0.5, y-tick-step: 1,
                x-min: domain.at(0), x-max: domain.at(1),
                y-min: image.at(0), y-max: image.at(1),
      {
        plot.add(
          domain: domain,
          samples: 1000,
          func,
          style: (stroke: rgb("c907f5ff") + 2pt),
          label: label
        )


        for (i, y) in rectangles.enumerate() {
          plot.add(
            (
              (rectangles-width * (i + 1), 0),
              (rectangles-width * (i + 1), y),
              (rectangles-width * i, y),
              (rectangles-width * i, 0)
            ),
            fill: true,
            style: (
              stroke: blue,
              fill: rgb("0000ff16")
            )
          )
        }
      })
    }),
    caption: caption
  )
}

#let draw-trapezoidal-plot(csv-file, func, label, domain, image, caption) = {
  let trapezoids-raw = csv(csv-file)
  let trapezoids-width = float(trapezoids-raw.at(0).at(0))
  let trapezoids = trapezoids-raw.slice(1).map(row => (float(row.at(0)), float(row.at(1))))

  figure(
    cetz.canvas({
      plot.plot(size: (8, 8),
                x-grid: true, y-grid: true,
                x-tick-step: 0.5, y-tick-step: 1,
                x-min: domain.at(0), x-max: domain.at(1),
                y-min: image.at(0), y-max: image.at(1),
      {
        plot.add(
          domain: domain,
          samples: 1000,
          func,
          style: (stroke: rgb("c907f5ff") + 2pt),
          label: label
        )


        for (i, (y-left, y-right)) in trapezoids.enumerate() {
          plot.add(
            (
              (trapezoids-width * (i + 1), 0),
              (trapezoids-width * (i + 1), y-right),
              (trapezoids-width * i, y-left),
              (trapezoids-width * i, 0)
            ),
            fill: true,
            style: (
              stroke: blue,
              fill: rgb("0000ff16")
            )
          )
        }
      })
    }),
    caption: caption
  )
}

#let draw-monte-carlo-plot(csv-file, func, label, domain, image, caption) = {
  let monte-carlo-raw = csv(csv-file)
  let monte-carlo-min-y = float(monte-carlo-raw.at(0).at(0))
  let monte-carlo-max-y = float(monte-carlo-raw.at(0).at(1))
  let monte-carlo = monte-carlo-raw.slice(1).map(row => (float(row.at(0)), float(row.at(1)), float(row.at(2))))

  let positive-hits = ()
  let negative-hits = ()
  let misses = ()

  for (x, y, hit) in monte-carlo {
    if hit == 0 {
      misses.push((x, y))
    } else if hit == 1 {
      positive-hits.push((x, y))
    } else if hit == -1 {
      negative-hits.push((x, y))
    }
  }

  figure(
    cetz.canvas({
      plot.plot(size: (8, 8),
                x-grid: true, y-grid: true,
                x-tick-step: 0.5, y-tick-step: 1,
                x-min: domain.at(0), x-max: domain.at(1),
                y-min: image.at(0), y-max: image.at(1),
      {
        plot.add(
          domain: domain,
          samples: 1000,
          func,
          style: (stroke: rgb("c907f5ff") + 2pt),
          label: label
        )

        plot.add(
          domain: domain,
          samples: 200,
          x => monte-carlo-max-y,
          style: (stroke: (paint: blue, thickness: 2pt, dash: (6pt, 10pt))),
          label: "max/min y"
        )

        plot.add(
          domain: domain,
          samples: 200,
          x => monte-carlo-min-y,
          style: (stroke: (paint: blue, thickness: 2pt, dash: (6pt, 10pt))),
        )

        plot.add(
          positive-hits + negative-hits,
          mark: "o",
          mark-size: 0.1,
          style: (stroke: none),
          mark-style: (stroke: green, fill: rgb("00ff0020")),
          label: "Trafione"
        )

        plot.add(
          misses,
          mark: "o",
          mark-size: 0.1,
          style: (stroke: none),
          mark-style: (stroke: red, fill: rgb("ff000020")),
          label: "Chybione"
        )
      })
    }),
    caption: caption
  )
}
