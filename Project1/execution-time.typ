#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3": plot, chart

#let average-time(data) = {
  let aggregates = (:)

  for row in data {
    let key = str(row.at(0))
    let time_val = float(row.at(2))
    
    if key in aggregates {
      let (current_sum, count) = aggregates.at(key)
      aggregates.insert(key, (current_sum + time_val, count + 1))
    } else {
      aggregates.insert(key, (time_val, 1))
    }
  }

  let averages = ()
  for (key, values) in aggregates.pairs() {
    let (total_sum, count) = values
    let avg = total_sum / count
    averages.push((int(key), avg))
  }

  return averages.sorted(key: x => x.at(0))
}

#let draw-execution-time-plot(file-prefix, domain, image, caption) = {
  let folder = "execution-time"
  let rectangles-left = average-time(csv(folder + "/" + file-prefix + "-rectangle-left.csv").map(row => (float(row.at(0)), float(row.at(1)), float(row.at(2)))))
  let rectangles-center = average-time(csv(folder + "/" + file-prefix + "-rectangle-center.csv").map(row => (float(row.at(0)), float(row.at(1)), float(row.at(2)))))
  let rectangles-right = average-time(csv(folder + "/" + file-prefix + "-rectangle-right.csv").map(row => (float(row.at(0)), float(row.at(1)), float(row.at(2)))))
  let trapezoids = average-time(csv(folder + "/" + file-prefix + "-trapezoid.csv").map(row => (float(row.at(0)), float(row.at(1)), float(row.at(2)))))
  let monte-carlo = average-time(csv(folder + "/" + file-prefix + "-monte-carlo.csv").map(row => (float(row.at(0)), float(row.at(1)), float(row.at(2)))))

  figure(
    cetz.canvas({
      plot.plot(size: (14, 12),
                x-grid: true, y-grid: true,
                x-tick-step: 1, y-tick-step: 1,
                x-min: domain.at(0), x-max: domain.at(1),
                y-min: image.at(0), y-max: image.at(1),
                x-format: x => $10^#int(x)$,
                y-format: x => $10^#int(x)$,
                x-label: [$log_10(n)$ - Ilość podziałów/próbek],
                y-label: [$log_10(t)$ - Czas wykonania (#(sym.mu)s)],
      {
        plot.add(
          monte-carlo.map(row => (row.at(0), calc.log(row.at(1), base: 10))),
          mark: "o",
          mark-style: (stroke: purple, fill: purple.lighten(40%)),
          style: (stroke: purple.darken(15%) + 2pt),
          label: "Monte carlo"
        )

        plot.add(
          rectangles-left.map(row => (row.at(0), calc.log(row.at(1), base: 10))),
          mark: "square",
          mark-style: (stroke: orange, fill: orange.lighten(40%)),
          style: (stroke: orange.darken(15%) + 2pt),
          label: "Lewe prostokąty"
        )

        plot.add(
          rectangles-center.map(row => (row.at(0), calc.log(row.at(1), base: 10))),
          mark: "square",
          mark-style: (stroke: red, fill: red.lighten(40%)),
          style: (stroke: red.darken(15%) + 2pt),
          label: "Środkowe prostokąty"
        )

        plot.add(
          rectangles-right.map(row => (row.at(0), calc.log(row.at(1), base: 10))),
          mark: "square",
          mark-style: (stroke: blue, fill: blue.lighten(40%)),
          style: (stroke: blue.darken(15%) + 2pt),
          label: "Prawe prostokąty"
        )

        plot.add(
          trapezoids.map(row => (row.at(0), calc.log(row.at(1), base: 10))),
          mark: "triangle",
          mark-style: (stroke: green, fill: green.lighten(40%)),
          style: (stroke: green.darken(15%) + 2pt),
          label: "Trapezy"
        )
      })
    }),
    caption: caption
  )
}
