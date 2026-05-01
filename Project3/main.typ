#import "@preview/algorithmic:1.0.7"
#import algorithmic: style-algorithm, algorithm-figure, algorithm

#set document(
title: [Algorytmy wyznaczania otoczki wypukłej (Convex Hull) - analiza porównawcza],
author: ("Piotr Niepsuj",),
)

#let takes = (-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9)

#set page(numbering: "1")
#set text(lang: "pl")

#align(center)[#title()]
#align(center)[Piotr Niepsuj]

#v(8em)
#text(size: 14pt, weight: "bold")[Spis treści]
#v(0.5em)
#line(length: 100%, stroke: 0.8pt + black)
#v(1em)

#set heading(numbering: "1.1.")
#outline(title: none, indent: auto)
#pagebreak()

= Wprowadzenie
Głównym celem tego projektu jest praktyczne zbadanie, jak wybór algorytmu sortowania wpływa na czas wykonania programu. Zamiast opierać się tylko na samej teorii ze złożoności obliczeniowej, projekt zakłada sformułowanie własnych hipotez i ich empiryczną weryfikację. Kluczowym kryterium oceny wydajności poszczególnych metod będzie zmierzony czas ich działania.

W ramach projektu zaimplementowałem algorytmy podzielone na trzy kategorie:
- *Część I (algorytmy proste):* Insertion sort, Selection sort oraz Bubble sort.
- *Część II (algorytmy efektywniejsze):* Quicksort, Shellsort oraz Heapsort.
- *Część III (algorytmy niekonwencjonalne):* Stooge sort, Thanos sort oraz Stalin sort.

Aby uzyskać pełny obraz tego, jak algorytmy zachowują się w różnych warunkach, każdy z nich jest testowany na pięciu scenariuszach przygotowania danych:
+ *Dane losowe* - nasz główny punkt odniesienia pokazujący wydajność w "normalnych" warunkach.
+ *Dane posortowane malejąco (odwrócone)* - czyli układ odwrócony, często będący najgorszym przypadkiem dla wielu metod.
+ *Dane posortowane rosnąco* - optymistyczny scenariusz dla większości algorytmów.
+ *Dane prawie posortowane (sąsiednia wymiana)* - zbiór z około 10% zamian sąsiednich elementów, co imituje dane z małym bałaganem.
+ *Dane prawie posortowane (globalna wymiana)* - zbiór z około 10% zamian losowych elementów, co odpowiada sytuacji, gdy dane mają szum.

== Środowisko testowe i sprzęt
- *Procesor:* Intel Core i5-12600K
- *Pamięć RAM:* 32 GB (DDR4)
- *Język programowania:* C++
- *Kompilator:* g++ (GCC) 14.3.0

== Metoda generowania danych testowych
Do przygotowania danych wejściowych stworzyłem program w języku C++. Program generuje zestawy danych dla wielkości bazujących na potęgach liczby 10. Aby zwiększyć rozdzielczość wykresów, potęgi te są dodatkowo zagęszczane przez mnożniki 1, 2 oraz 5 (co daje nam tablice o rozmiarach np. 10, 20, 50, 100, 200, 500, 1000 itd.). Wygenerowane dane zapisywane są do plików CSV, dzięki czemu każdy algorytm operuje na dokładnie takich samych liczbach w danym scenariuszu.

Program obsługuje się z wiersza poleceń, a zakres generowanych danych można łatwo dostosować (przedziały podawane są włącznie). Przykłady użycia:
- *`./main generate`* - generuje domyślnie wszystkie dane wielkości od 1 do 8 potęgi 10.
- *`./main generate 3 6`* - ogranicza generowanie plików CSV tylko do rozmiarów od 3 do 6 potęgi 10.
#pagebreak()

== Metoda testowania
Ten sam program w C++ odpowiada za przeprowadzanie właściwych pomiarów. Aplikacja wczytuje przygotowane wcześniej dane z plików CSV, uruchamia wybrany algorytm i mierzy jego czas wykonania (z wykorzystaniem wbudowanych narzędzi biblioteki chrono).

Interfejs z poziomu konsoli pozwala na bardzo dużą elastyczność w dobieraniu testów, co jest szczególnie przydatne przy wolniejszych algorytmach, których nie chcemy puszczać dla ogromnych tablic.

Oto jak w praktyce wygląda sterowanie testami:
- *`./main test`* - odpala komplet pomiarów: wszystkie algorytmy na wszystkich 5 scenariuszach w pełnym przedziale (potęgi 1-8).
- *`./main test 1 4`* - testuje wszystkie algorytmy i scenariusze, ale zawęża zestaw danych do potęg od 1 do 4.
- *`./main test 1 7 quick-sort descending`* - testuje wyłącznie algorytm Quicksort na danych posortowanych malejąco, dla potęg 1-7.
- *`./main test 1 4 bubble-sort all`* - uruchamia Bubble sort na wszystkich 5 scenariuszach dla potęg 1-4.
- *`./main test 1 4 all descending`* - sprawdza zachowanie wszystkich zaimplementowanych algorytmów, ale tylko na danych malejących, w rozmiarach od potęgi 1 do 4.

#grid(columns: (1fr, auto), rows: (auto), gutter: 3pt,
  [
    Pojedynczy test na danym algorytmie, scenariuszu i rozmiarze danych generuje plik CSV zawierający próby od $-10$ do $9$ i czas wykonania algorytmu w nanosekundach, przykład można zobaczyć na @csv-example. Przy wyliczaniu średniej do wykresów tylko próby od $0$ do $9$ są brane pod uwagę. Próby od $-10$ do $-1$ są na rozgrzewkę dla procesora.

    Każdy test zostaje przeprowadzony na odizolowanym rdzeniu procesora z regulatorem skalowania ustawionym na wydajność. W moim przypadku korzystam z rdzenia 0, który jest rdzeniem wydajnościowym. Testy są także włączane z najwyższym możliwym priorytetem. Zostało to osiągnięte w następujący sposób
    - *Izolacja rdzenia 0* \
      Dodanie do `/etc/default/grub` ustawienia `GRUB_CMDLINE_LINUX_DEFAULT="isolcpus=0 nohz_full=0 rcu_nocbs=0"`
    - *Ustawienie regulatora skalowania dla rdzenia 0 na wydajność (do restartu systemu)* \
      Wykonane za pomocą komendy `echo performance | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor` można sprawdzić czy operacja powiodła się wypisując `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`
    - *Uruchomienie testów na rdzeniu 0 z największym priorytetem*
      Wykorzystanie `taskset` do przypisania procesu do rdzenia 0 oraz `chrt` do ustawienia najwyższego priorytetu. Komenda urzyta w testach to `sudo chrt -f 99 taskset -c 0 ./main test`
  ],

  [
    #box(width: 180pt)[
      #figure(
    table(
      columns: 2,
      fill: (col, row) => {
        if row == 0 { return none } // nagłówek bez koloru
        if col == 0 {
          if takes.at(row - 1) < 0 { rgb(255, 160, 160) } else { rgb(160, 255, 160) }
        }
      },
      [*Próba*], [*Czas wykonania (ns)*],
      [$-10$],[$11464$],
      [$-9$],[$7212$],
      [$-8$],[$5258$],
      [$-7$],[$4029$],
      [$-6$],[$3633$],
      [$-5$],[$3478$],
      [$-4$],[$3333$],
      [$-3$],[$3211$],
      [$-2$],[$3163$],
      [$-1$],[$3192$],
      [$0$],[$3154$],
      [$1$],[$3211$],
      [$2$],[$3164$],
      [$3$],[$3144$],
      [$4$],[$3143$],
      [$5$],[$3180$],
      [$6$],[$3161$],
      [$7$],[$3145$],
      [$8$],[$3161$],
      [$9$],[$3143$]
    ),
    caption: [Dane testowe pliku CSV dla Bubble sort na tablicy 100 elementowej z losowym ułożeniem elementów.]
    ) <csv-example>
    ]
  ]
)

#pagebreak()

= Graham's scan
Algorytm Skanowania Grahama to jedno z najbardziej klasycznych podejść do problemu wyznaczania otoczki wypukłej. Jego działanie opiera się na sprytnym posortowaniu punktów, a następnie odrzucaniu tych, które tworzą wklęśnięcia. Działanie algorytmu możemy podzielić na trzy etapy.

*1. Wybór punktu startowego* \
Na początku musimy znaleźć punkt, który na pewno należy do otoczki wypukłej. Najprościej jest to zrobić wybierając najniższy punkt, czyli ten o najmniejszej współrzędnej $Y$. W przypadku kilku takich punktów, wybieramy ten, który leży najbardziej po lewej stronie, czyli ma najmniejszy $X$. Punkt ten nazwiemy $P_0$ - będzie on naszym punktem odniesienia do końca algorytmu.

*2. Sortowanie kątowe* \
Teraz bierzemy wszystkie pozostałe punkty i sortujemy je rosnąco względem kąta, jaki tworzą z punktem $P_0$ oraz osią $X$. Wykorzystujemy do tego znak iloczynu wektorowego (cross product), jeśli podczas sortowania okaże się, że kilka punktów leży na jednej prostej z punktem $P_0$, zostawiamy tylko ten, który jest od niego najdalej, ponieważ pozostałe i tak leżałyby wewnątrz krawędzi otoczki, więc od razu je odrzucamy, co oszczędza niepotrzebnych obliczeń.

*3. Skanowanie przy użyciu stosu* \
Towrzymy stos i wrzucamy na niego nasz punkt startowy $P_0$ oraz dwa pierwsze punkty z posortowanej listy, następnie iterujemy przez resztę posortowanych punktów. Dla każdego nowego punktu sprawdzamy ułożenie przedostatniego punktu na stosie, ostatniego punktu na stosie (na samym szczycie) i nowego punktu, który właśnie rozpatrujemy. Chcemy, aby te trzy punkty zawsze tworzyły skręt w lewo. Jeśli sprawdzany nowy punkt sprawia, że tworzy się skręt w prawo, oznacza to, że punkt znajdujący się obecnie na szczycie stosu tworzy wklęśnięcie i nie może należeć do otoczki wypukłej. Usuwamy ten punkt ze stosu i sprawdzamy skręt ponownie dla poprzednich punktów. Zdejmujemy punkty tak długo, aż znów uzyskamy poprawny skręt w lewo. Gdy to nastąpi, dodajemy nasz nowy punkt na stos i przechodzimy do kolejnego.

Po przejściu przez całą posortowaną listę, na stosie zostają nam wyłącznie wierzchołki naszej otoczki wypukłej uporządkowane w kierunku przeciwnym do ruchu wskazówek zegara.

#show: style-algorithm
#algorithm-figure(
  "Skanowanie Grahama",
  supplement: "Algorytm",
  vstroke: .5pt + luma(150),
  {
    import algorithmic: *

    Procedure(
      "GrahamScan", ("points",),
      {
        Assign($n$, [rozmiar tablicy $"points"$])
        If([$n < 3$], {
          Line([zwróć $"points"$])
        })
        LineBreak

        Line([ 1. Znajdź najniższy punkt (w przypadku remisu wysunięty najbardziej w lewo)])
        Assign($"min\_idx"$, $0$)
        Assign($i$, $1$)
        While([$i < n$], {
          If([$"points"[i].y < "points"["min\_idx"].y - epsilon$ lub ($|"points"[i].y - "points"["min\_idx"].y| < epsilon$ i $"points"[i].x < "points"["min\_idx"].x - epsilon$)], {
            Assign($"min\_idx"$, $i$)
          })
          Assign($i$, $i + 1$)
        })
        Line([zamień $"points"[0]$ z $"points"["min\_idx"]$])
        Assign($P_0$, $"points"[0]$)
        LineBreak

        Line([ 2. Sortowanie kątowe i filtrowanie])
        Line([posortuj $"points"[1 dots n-1]$ rosnąco względem kąta tworzonego z wektorem od $P_0$])
        Line([jeśli kąty są równe, bliższy punkt umieść przed dalszym])
        Line([odfiltruj współliniowe punkty w $"points"$, zostawiając tylko najdalsze od $P_0$ na danej półprostej])
        Assign($m$, [rozmiar tablicy po odfiltrowaniu])
        If([$m < 3$], {
          Line([zwróć $"points"[0 dots m-1]$])
        })
        LineBreak

        Line([ 3. Budowa otoczki ze stosem])
        Assign($"hull"$, [pusty stos])
        Line([dodaj $"points"[0]$, $"points"[1]$, $"points"[2]$ na stos $"hull"$])
        LineBreak

        Assign($i$, $3$)
        While([$i < m$], {
          While([rozmiar($"hull"$) $> 1$], {
            Assign($"top"$, [szczyt stosu $"hull"$])
            Assign($"next\_to\_top"$, [element tuż pod szczytem stosu $"hull"$])
            LineBreak

            Line([ Jeśli punkty tworzą skręt w prawo lub są współliniowe, zdejmij szczyt])
            If([$"next\_to\_top.cross_product"("top", "points"[i]) < epsilon$], {
              Line([zdejmij element ze stosu $"hull"$])
            })
            If([$"next\_to\_top.cross_product"("top", "points"[i]) >= epsilon$], {
              Line([przerwij pętlę sprawdzającą (skręt w lewo jest poprawny)])
            })
          })
          Line([dodaj $"points"[i]$ na stos $"hull"$])
          Assign($i$, $i + 1$)
        })
        LineBreak

        Line([zwróć stos $"hull"$ jako gotową otoczkę])
      }
    )
  }
)

= Andrew's Monotone Chain
= Jarvis March
= Quick Hull
= Chan's Algorithm
