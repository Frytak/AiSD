#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3": plot, chart

#let O-n(x)      = x
#let O-n2(x)     = 2 * x
#let O-n3(x)     = 3 * x
#let O-n3-2(x)   = 3/2 * x
#let O-logn(x)   = calc.log(x, base: 10)
#let O-nlogn(x)  = x + calc.log(x, base: 10)
#let O-1(x)      = 0

#let complexity-line(f, x-min, x-max, offset, steps) = {
  let step = (x-max - x-min) / steps
  range(0, steps + 1).map(i => {
    let x = x-min + i * step
    (x, f(x) + offset)
  })
}

#let csv-average-us(path) = {
  let rows = csv(path).slice(1)
  let valid = rows.filter(r => int(r.at(0)) >= 0)
  let total = valid.fold(0.0, (acc, r) => acc + float(r.at(1)))
  total / valid.len() / 1000 // ns -> us
}

#let load-scenario(algorithm, scenario, sizes) = {
  sizes.map(n => {
    let path = "results/" + algorithm + "/" + scenario + "/" + str(n) + ".csv"
    let avg = csv-average-us(path)
    (calc.log(n, base: 10), avg)
  })
}

#let sizes-range(min-power, max-power) = range(min-power, max-power + 1).map(p => (1, 2, 5).map(m => m * calc.pow(10, p))).flatten()

#let load-algorithm(algorithm, sizes, scenario-sizes) = {
  let scenarios = (
    "random",
    "circle",
    "grid",
    "cluster",
    "triangle",
  )
  let result = (:)
  for s in scenarios {
    let s-sizes = if s in scenario-sizes { scenario-sizes.at(s) } else { sizes }
    result.insert(s, load-scenario(algorithm, s, s-sizes))
  }
  result
}

#let draw-execution-time-plot(algorithm, sizes, scenario-sizes, additional-plots, domain, image, caption) = {
  let d = load-algorithm(algorithm, sizes, scenario-sizes)

  figure(
    cetz.canvas({
      plot.plot(size: (12, 12),
                legend: (12, 0),
                legend-anchor: "south-east",
                x-grid: true, y-grid: true,
                x-tick-step: 1, y-tick-step: 1,
                x-min: domain.at(0), x-max: domain.at(1),
                y-min: image.at(0), y-max: image.at(1),
                x-format: x => $10^#int(x)$,
                y-format: x => $10^#int(x)$,
                x-label: [$log_10(n)$ - Ilość punktów],
                y-label: [$log_10(t)$ - Czas wykonania (#(sym.mu)s)],
      {
        plot.add(
          d.random.map(row => (row.at(0), calc.log(row.at(1), base: 10))),
          mark: "square",
          mark-style: (stroke: purple, fill: purple.lighten(40%)),
          style: (stroke: purple.darken(15%) + 2pt),
          label: "Losowe"
        )

        plot.add(
          d.circle.map(row => (row.at(0), calc.log(row.at(1), base: 10))),
          mark: "o",
          mark-style: (stroke: orange, fill: orange.lighten(40%)),
          style: (stroke: orange.darken(15%) + 2pt),
          label: "Kółko"
        )

        plot.add(
          d.grid.map(row => (row.at(0), calc.log(row.at(1), base: 10))),
          mark: "square",
          mark-style: (stroke: red, fill: red.lighten(40%)),
          style: (stroke: red.darken(15%) + 2pt),
          label: "Siatka"
        )

        plot.add(
          d.cluster.map(row => (row.at(0), calc.log(row.at(1), base: 10))),
          mark: "o",
          mark-style: (stroke: blue, fill: blue.lighten(40%)),
          style: (stroke: blue.darken(15%) + 2pt),
          label: "Skupisko",
        )

        plot.add(
          d.triangle.map(row => (row.at(0), calc.log(row.at(1), base: 10))),
          mark: "triangle",
          mark-style: (stroke: green, fill: green.lighten(40%)),
          style: (stroke: green.darken(15%) + 2pt),

          label: "Trójkąt",
        )

        for s in additional-plots {
          plot.add(s.data, ..s.options)
        }
      })
    }),
    caption: caption
  )
}

#let algorithm-colors = (
  (stroke: purple, mark: "o"),
  (stroke: orange, mark: "square"),
  (stroke: red,    mark: "square"),
  (stroke: blue,   mark: "triangle"),
  (stroke: green,  mark: "triangle"),
  (stroke: maroon, mark: "o"),
  (stroke: teal,   mark: "triangle"),
)

#let draw-scenario-comparison-plot(algorithms, scenario, additional-plots, domain, image, caption) = {
  figure(
    cetz.canvas({
      plot.plot(size: (14, 12),
                legend: (14, 0),
                legend-anchor: "south-east",
                x-grid: true, y-grid: true,
                x-tick-step: 1, y-tick-step: 1,
                x-min: domain.at(0), x-max: domain.at(1),
                y-min: image.at(0), y-max: image.at(1),
                x-format: x => $10^#int(x)$,
                y-format: x => $10^#int(x)$,
                x-label: [$log_10(n)$ - Ilość punktów],
                y-label: [$log_10(t)$ - Czas wykonania (#(sym.mu)s)],
      {
        for (i, alg) in algorithms.enumerate() {
          let data = load-scenario(alg.name, scenario, alg.sizes)

          plot.add(
            data.map(row => (row.at(0), calc.log(row.at(1), base: 10))),
            mark: alg.mark,
            mark-style: (stroke: alg.color, fill: alg.color.lighten(40%)),
            style: (stroke: alg.color.darken(15%) + 2pt),
            label: alg.label,
          )
        }

        for s in additional-plots {
          plot.add(s.data, ..s.options)
        }
      })
    }),
    caption: caption
  )
}
