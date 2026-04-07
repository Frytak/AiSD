#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3": plot, chart

#let draw-approaching-value-plot(file-prefix, value, tick-step, domain, image) = {
  let folder = "approaching-value"
  let rectangles-left = csv(folder + "/" + file-prefix + "-rectangle-left.csv").map(row => (float(row.at(0)), float(row.at(1)), float(row.at(2))))
  let rectangles-center = csv(folder + "/" + file-prefix + "-rectangle-center.csv").map(row => (float(row.at(0)), float(row.at(1)), float(row.at(2))))
  let rectangles-right = csv(folder + "/" + file-prefix + "-rectangle-right.csv").map(row => (float(row.at(0)), float(row.at(1)), float(row.at(2))))
  let trapezoids = csv(folder + "/" + file-prefix + "-trapezoid.csv").map(row => (float(row.at(0)), float(row.at(1)), float(row.at(2))))

  let monte-carlo = csv(folder + "/" + file-prefix + "-monte-carlo.csv").map(row => (float(row.at(0)), float(row.at(1)), float(row.at(2)), float(row.at(3))))
  let num-data = monte-carlo.map(row => (
    float(row.at(0)), 
    float(row.at(2))
  ))

  let ns = ()
  for row in num-data {
    if row.at(0) not in ns { ns.push(row.at(0)) }
  }
  ns = ns.sorted()

  let aggregated-data = ()
  for n in ns {
    let values = num-data.filter(row => row.at(0) == n).map(row => row.at(1))
    let n-samples = values.len()
    
    let mean-val = values.fold(0.0, (acc, val) => acc + val) / n-samples
    
    let variance = values.fold(0.0, (acc, val) => acc + calc.pow(val - mean-val, 2)) / (n-samples - 1)
    let std-dev = calc.sqrt(variance)
    
    let lower-val = mean-val - std-dev
    let upper-val = mean-val + std-dev

    aggregated-data.push((
      n,
      mean-val,
      lower-val,
      upper-val
    ))
  }

  let upper-path = aggregated-data.map(row => (row.at(0), row.at(3)))
  let lower-path = aggregated-data.map(row => (row.at(0), row.at(2)))

  figure(
    cetz.canvas({
      plot.plot(size: (14, 12),
                x-grid: true, y-grid: true,
                x-tick-step: tick-step, y-tick-step: 0.1,
                x-min: domain.at(0), x-max: domain.at(1),
                y-min: image.at(0), y-max: image.at(1),
                x-label: [$n$ - Ilość podziałów/próbek],
                y-label: [$y$ - Wartość całki],
      {

        plot.add-fill-between(
          style: (stroke: none, fill: purple.transparentize(80%)),
          lower-path,
          upper-path,
        )

        plot.add(
          aggregated-data.map(row => (row.at(0), row.at(1))),
          style: (stroke: purple.darken(15%) + 2pt),
          label: "Monte carlo"
        )

        plot.add(
          rectangles-left.map(row => (row.at(0), row.at(1))),
          style: (stroke: orange.darken(15%) + 2pt),
          label: "Lewe prostokąty"
        )

        plot.add(
          rectangles-center.map(row => (row.at(0), row.at(1))),
          style: (stroke: red.darken(15%) + 2pt),
          label: "Środkowe prostokąty"
        )

        plot.add(
          rectangles-right.map(row => (row.at(0), row.at(1))),
          style: (stroke: blue.darken(15%) + 2pt),
          label: "Prawe prostokąty"
        )

        plot.add(
          trapezoids.map(row => (row.at(0), row.at(1))),
          style: (stroke: green.darken(15%) + 2pt),
          label: "Trapezy"
        )

        plot.add(
          x => value,
          domain: domain,
          samples: 100,
          style: (stroke: (paint: black, thickness: 2pt, dash: (6pt, 10pt))),
          label: stack(
            spacing: 0em,
            [Wartość oczekiwana],
            [(#value)],
          ),
        )
      })
    }),
    caption: [Wykres przybliżonej wartości całki w zależności od liczby podziałów/próbek dla funkcji $#file-prefix$. Czarną przerywaną linią zaznaczono dokładną wartość oczekiwaną, a zacieniony obszar przy metodzie Monte Carlo przedstawia odchylenie standardowe ($plus.minus 1 sigma$) z 10 prób.]
  )
}
