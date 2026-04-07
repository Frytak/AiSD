#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3": plot, chart

#let draw-error-margin-plot(file-prefix, domain, image) = {
  let folder = "error-margins"
  let rectangles-left = csv(folder + "/" + file-prefix + "-rectangle-left-error-margin.csv").map(row => (float(row.at(0)), float(row.at(1)), float(row.at(2))))
  let rectangles-center = csv(folder + "/" + file-prefix + "-rectangle-center-error-margin.csv").map(row => (float(row.at(0)), float(row.at(1)), float(row.at(2))))
  let rectangles-right = csv(folder + "/" + file-prefix + "-rectangle-right-error-margin.csv").map(row => (float(row.at(0)), float(row.at(1)), float(row.at(2))))
  let trapezoids = csv(folder + "/" + file-prefix + "-trapezoid-error-margin.csv").map(row => (float(row.at(0)), float(row.at(1)), float(row.at(2))))

  let monte-carlo = csv(folder + "/" + file-prefix + "-monte-carlo-error-margin.csv").map(row => (float(row.at(0)), float(row.at(1)), float(row.at(2)), float(row.at(3))))
  let num-data = monte-carlo.map(row => (
    float(row.at(0)), 
    float(row.at(3))
  ))

  let ns = ()
  for row in num-data {
    if row.at(0) not in ns { ns.push(row.at(0)) }
  }
  ns = ns.sorted()

  let aggregated-data = ()
  for n in ns {
    let errors = num-data.filter(row => row.at(0) == n).map(row => row.at(1))
    let n-samples = errors.len()
    
    let mean-err = errors.fold(0.0, (acc, val) => acc + val) / n-samples
    
    let variance = errors.fold(0.0, (acc, val) => acc + calc.pow(val - mean-err, 2)) / (n-samples - 1)
    let std-dev = calc.sqrt(variance)
    
    let lower-err = mean-err - std-dev
    let upper-err = mean-err + std-dev
    let min-actual = calc.min(..errors) 
    let max-actual = calc.max(..errors) 

    if lower-err <= 0 { lower-err = min-actual }
    if upper-err <= 0 { upper-err = max-actual }
    
    if lower-err <= 0 { lower-err = 1e-16 } 
    if mean-err <= 0 { mean-err = 1e-16 }
    if upper-err <= 0 { upper-err = 1e-16 }

    aggregated-data.push((
      n,
      calc.log(mean-err, base: 10),
      calc.log(lower-err, base: 10),
      calc.log(upper-err, base: 10)
    ))
  }

  let upper-path = aggregated-data.map(row => (row.at(0), row.at(3)))
  let lower-path = aggregated-data.map(row => (row.at(0), row.at(2)))

  figure(
    cetz.canvas({
      plot.plot(size: (12, 12),
                x-grid: true, y-grid: true,
                x-tick-step: 1, y-tick-step: 1,
                x-min: domain.at(0), x-max: domain.at(1),
                y-min: image.at(0), y-max: image.at(1),
                x-format: x => $10^#int(x)$,
                y-format: x => $10^#int(x)$,
                x-label: [$log_10(n)$ - Ilość podziałów/próbek],
                y-label: [$log_10(epsilon)$ - Błąd bezwzględny],
      {
        plot.add(
          rectangles-left.map(row => (row.at(0), calc.log(row.at(2), base: 10))),
          mark: "square",
          mark-style: (stroke: orange, fill: orange.lighten(40%)),
          style: (stroke: orange.darken(15%) + 2pt),
          label: "Lewe prostokąty"
        )

        plot.add(
          rectangles-center.map(row => (row.at(0), calc.log(row.at(2), base: 10))),
          mark: "square",
          mark-style: (stroke: red, fill: red.lighten(40%)),
          style: (stroke: red.darken(15%) + 2pt),
          label: "Środkowe prostokąty"
        )

        plot.add(
          rectangles-right.map(row => (row.at(0), calc.log(row.at(2), base: 10))),
          mark: "square",
          mark-style: (stroke: blue, fill: blue.lighten(40%)),
          style: (stroke: blue.darken(15%) + 2pt),
          label: "Prawe prostokąty"
        )

        plot.add(
          trapezoids.map(row => (row.at(0), calc.log(row.at(2), base: 10))),
          mark: "triangle",
          mark-style: (stroke: green, fill: green.lighten(40%)),
          style: (stroke: green.darken(15%) + 2pt),
          label: "Trapezy"
        )

        plot.add-fill-between(
          style: (stroke: none, fill: purple.transparentize(80%)),
          lower-path,
          upper-path,
        )

        plot.add(
          aggregated-data.map(row => (row.at(0), row.at(1))),
          mark: "o",
          mark-style: (stroke: purple, fill: purple.lighten(40%)),
          style: (stroke: purple.darken(15%) + 2pt),
          label: "Monte carlo"
        )
      })
    }),
    caption: [Wykres zbieżności metod w zależności od liczby podziałów/próbek w skali logarytmicznej dla funkcji $#file-prefix$. Zacieniony obszar przy metodzie Monte Carlo przedstawia odchylenie standardowe ($plus.minus 1 sigma$) z 10 prób.]
  )
}
