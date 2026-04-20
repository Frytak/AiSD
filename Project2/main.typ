#import "@preview/algorithmic:1.0.7"
#import algorithmic: style-algorithm, algorithm-figure, algorithm

#set document(
title: [Algorytmy sortowania - analiza porównawcza],
author: ("Piotr Niepsuj",),
)

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
Głównym celem tego projektu jest praktyczne zbadanie, jak wybór algorytmu sortowania i struktura danych wpływają na czas wykonania programu. Zamiast opierać się tylko na samej teorii ze złożoności obliczeniowej, projekt zakłada sformułowanie własnych hipotez i ich empiryczną weryfikację. Kluczowym kryterium oceny wydajności poszczególnych metod będzie zmierzony czas ich działania.

W ramach projektu zaimplementowałem algorytmy podzielone na trzy kategorie:
- *Część I (algorytmy proste):* Insertion sort, Selection sort oraz Bubble sort.
- *Część II (algorytmy efektywniejsze):* Quicksort, Shellsort oraz Heapsort.
- *Część III (algorytmy niekonwencjonalne):* Bogosort, Sleep sort oraz Stalin sort.

Aby uzyskać pełny obraz tego, jak algorytmy zachowują się w różnych warunkach, każdy z nich jest testowany na pięciu scenariuszach przygotowania danych:
+ *Dane losowe* – nasz główny punkt odniesienia pokazujący wydajność w "normalnych" warunkach.
+ *Dane posortowane malejąco* – czyli układ odwrócony, często będący najgorszym przypadkiem dla wielu metod.
+ *Dane posortowane rosnąco* – optymistyczny scenariusz dla większości algorytmów.
+ *Dane prawie posortowane (sąsiednia wymiana)* – zbiór z około 10% zamian sąsiednich elementów, co imituje dane z małym bałaganem.
+ *Dane prawie posortowane (globalna wymiana)* – zbiór z około 10% zamian losowych elementów, co odpowiada sytuacji, gdy dane mają szum.

== Środowisko testowe i sprzęt
- *Procesor:* Intel Core i5-12600K
- *Pamięć RAM:* 32 GB (DDR4)
- *Język programowania:* C++
- *Kompilator:* g++ (GCC) 14.3.0

== Metoda generowania danych testowych
Do przygotowania danych wejściowych stworzyłem program w języku C++. Program generuje zestawy danych dla wielkości bazujących na potęgach liczby 10. Aby zwiększyć rozdzielczość wykresów, potęgi te są dodatkowo zagęszczane przez mnożniki 1, 2 oraz 5 (co daje nam tablice o rozmiarach np. 10, 20, 50, 100, 200, 500, 1000 itd.). Wygenerowane dane zapisywane są do plików CSV, dzięki czemu każdy algorytm operuje na dokładnie takich samych liczbach w danym scenariuszu.

Program obsługuje się z wiersza poleceń, a zakres generowanych danych można łatwo dostosować (przedziały podawane są włącznie). Przykłady użycia:
- `./main generate` – generuje domyślnie wszystkie dane wielkości od 1 do 8 potęgi 10.
- `./main generate 3 6` – ogranicza generowanie plików CSV tylko do rozmiarów od 3 do 6 potęgi 10.

== Metoda testowania
Ten sam program w C++ odpowiada za przeprowadzanie właściwych pomiarów. Aplikacja wczytuje przygotowane wcześniej dane z plików CSV, uruchamia wybrany algorytm i mierzy jego czas wykonania (z wykorzystaniem wbudowanych narzędzi biblioteki chrono).

Interfejs z poziomu konsoli pozwala na bardzo dużą elastyczność w dobieraniu testów, co jest szczególnie przydatne przy wolniejszych algorytmach (takich jak Bubble sort czy Bogosort), których nie chcemy puszczać dla ogromnych tablic.

Oto jak w praktyce wygląda sterowanie testami:
- `./main test` – odpala komplet pomiarów: wszystkie algorytmy na wszystkich 5 scenariuszach w pełnym przedziale (potęgi 1-8).
- `./main test 1 4` – testuje wszystkie algorytmy i scenariusze, ale zawęża zestaw danych do potęg od 1 do 4.
- `./main test 1 7 quick-sort descending` – testuje wyłącznie algorytm Quicksort na danych posortowanych malejąco, dla potęg 1-7.
- `./main test 1 4 bubble-sort all` – uruchamia Bubble sort na wszystkich 5 scenariuszach dla potęg 1-4.
- `./main test 1 4 all descending` – sprawdza zachowanie wszystkich zaimplementowanych algorytmów, ale tylko na danych malejących, w rozmiarach od potęgi 1 do 4.
#pagebreak()

= Algorytmy prostsze
== Insertion sort
*Zasada działania algorytmu* \
Sortowanie przez wstawianie działa bardzo intuicyjnie, dokładnie tak, jak większość ludzi układająca karty w ręce podczas gry. Algorytm dzieli tablicę na dwie części, jedną posortowaną (na początku) i drugą nieposortowaną (reszta). W każdej iteracji bierze pierwszy element z części nieposortowanej i szuka dla niego odpowiedniego miejsca w części posortowanej, przesuwając większe elementy w prawo, aby zrobić mu miejsce. Kiedy znajdzie właściwą pozycję, wstawia tam element. Proces ten powtarza się, aż cała tablica będzie uporządkowana.

#show: style-algorithm
#algorithm-figure(
  "Insertion sort",
  supplement: "Algorytm",
  vstroke: .5pt + luma(150),
  {
    import algorithmic: *
    Procedure(
      "Insertion sort", ("arr", "n"),
      {
        Assign($i$, $1$)
        While([$i < n$], {
          Assign($"current"$, $"arr"[i]$)
          Assign($j$, $i - 1$)

          While([$j >= 0 " i " "arr"[j] > "current"$], {
            Assign($"arr"[j + 1]$, $"arr"[j]$)
            Assign($j$, $j - 1$)
          })

          Assign($"arr"[j + 1]$, $"current"$)
          Assign($i$, $i + 1$)
        })
      },
    )
  }
)

*Czasowa złożoność obliczeniowa*
- *Najgorszy i średni przypadek:* $O(n^2)$ – występuje, gdy tablica jest posortowana odwrotnie lub liczby są ułożone losowo. Algorytm musi wtedy dla każdego elementu przechodzić przez większość lub w najgorszym przypadku całą posortowaną już część tablicy.
- *Najlepszy przypadek:* $O(n)$ – zachodzi, gdy tablica jest już posortowana. Wewnętrzna pętla natychmiast kończy działanie, więc algorytm wykonuje tylko jedno przejście przez tablicę.

*Hipotezy badawcze dla poszczególnych scenariuszy*
+ *Dane losowe:* Oczekiwany jest czas rzędu $O(n^2)$. Z powodu dużej liczby porównań i przesunięć, algorytm będzie działał stosunkowo wolno dla większych rozmiarów tablic.
+ *Dane posortowane malejąco (odwrócone):* worst-case - Każdy nowy element będzie musiał zostać przesunięty na sam początek tablicy. Czas wykonania powinien być najdłuższy ze wszystkich scenariuszy i rosnąć stromo parabolicznie.
+ *Dane posortowane rosnąco:* best-case - Złożoność spada do $O(n)$, ponieważ warunek wewnętrznej pętli nigdy nie zostanie spełniony. Oczekuję tu błyskawicznego czasu wykonania, wykres powinien być liniowy.
+ *Dane prawie posortowane (sąsiednia wymiana):* Ponieważ Insertion sort świetnie radzi sobie, gdy elementy są blisko swoich docelowych miejsc, oczekuję czasu wykonania bardzo zbliżonego do wariantu optymistycznego, niemal liniowego.
+ *Dane prawie posortowane (globalna wymiana):* Przypadek powinien znaleźć się czasowo pomiędzy danymi losowymi, a prawie posortowanymi (sąsiednia wymiana).

== Selection sort
*Zasada działania algorytmu* \
Selection sort polega na wielokrotnym wyszukiwaniu najmniejszego elementu w nieposortowanej części tablicy i zamienianiu go z pierwszym elementem tej nieposortowanej części. Algorytm wirtualnie dzieli tablicę na część posortowaną (z lewej strony) i nieposortowaną (z prawej). W każdym kroku przeszukuje całą prawą stronę, by znaleźć absolutne minimum, a następnie dorzuca je na koniec posortowanej połowy. 

#show: style-algorithm
#algorithm-figure(
  "Selection sort",
  supplement: "Algorytm",
  vstroke: .5pt + luma(150),
  {
    import algorithmic: *
    Procedure(
      "Selection sort", ("arr", "n"),
      {
        Assign($i$, $0$)
        While([$i < n - 1$], {
          Assign($min_("idx")$, $i$)
          Assign($j$, $i + 1$)

          While([$j < n$], {
            If([$"arr"[j] < "arr"["min"_"idx"]$], {
              Assign($min_("idx")$, $j$)
            })

            Assign($j$, $j + 1$)
          })

          Line([zamień $"arr"[i]$ z $"arr"["min"_"idx"]$])
          Assign($i$, $i + 1$)
        })
      },
    )
  }
)

*Czasowa złożoność obliczeniowa*
- *Najgorszy, średni i najlepszy przypadek:* $O(n^2)$ – jest to cecha szczególna tego algorytmu. Sortowanie przez selekcję jest całkowicie "ślepe" na początkowe ułożenie danych. Niezależnie od tego, czy tablica jest już idealnie posortowana, czy odwrócona, algorytm i tak musi za każdym razem przeiterować przez resztę tablicy, żeby upewnić się, że znalazł najmniejszą wartość. Zawsze wykonuje dokładnie tę samą liczbę porównań elementów.

*Hipotezy badawcze dla poszczególnych scenariuszy*
+ *Dane losowe:* Oczekiwany czas rzędu $O(n^2)$. Algorytm będzie mało wydajny dla większych tablic, a wykres zależności czasu od rozmiaru narysuje klasyczną parabolę.
+ *Dane posortowane malejąco (odwrócone):* Czas działania powinien być niemal identyczny jak dla danych losowych. Liczba porównań pozostaje ta sama, więc nie oczekuję tu drastycznych różnic na wykresie.
+ *Dane posortowane rosnąco:* W przeciwieństwie do Insertion sort, tutaj nie uświadczymy drastycznego spadku czasu. Algorytm i tak nie wie, że tablica jest posortowana, więc wykona pełną pulę porównań ($O(n^2)$). Czas może być co najwyżej odrobinę krótszy z powodu braku fizycznych zamian elementów (swapów) w pamięci, ale wykres na pewno nie będzie liniowy.
+ *Dane prawie posortowane (sąsiednia wymiana):* Ponieważ metoda nie potrafi wykorzystać faktu, że elementy są już blisko swoich miejsc, czas wykonania nie ulegnie poprawie w stosunku do danych losowych.
+ *Dane prawie posortowane (globalna wymiana):* Wyniki powinny znów pokrywać się z resztą scenariuszy. Zaletą (lub wadą) tego algorytmu jest jego brutalna przewidywalność – niezależnie od tego, co mu podamy, robi swoje i zajmuje mu to mniej więcej tyle samo czasu.

== Bubble sort
#show: style-algorithm
#algorithm-figure(
  "Bubble sort",
  supplement: "Algorytm",
  vstroke: .5pt + luma(150),
  {
    import algorithmic: *
    Procedure(
      "Bubble sort", ("arr", "n"),
      {
        Assign($i$, $0$)
        While([$i < n - 1$], {
          Assign($j$, $0$)
          While([$j < n - i - 1$], {
            If([$"arr"[j] > "arr"[j + 1]$], {
              Line([zamień $"arr"[j]$ z $"arr"[j + 1]$])
            })
            Assign($j$, $j + 1$)
          })
          Assign($i$, $i + 1$)
        })
      },
    )
  }
)
#pagebreak()

= Algorytmy efektywniejsze
== Quicksort
#show: style-algorithm
#algorithm-figure(
  "Quicksort",
  supplement: "Algorytm",
  vstroke: .5pt + luma(150),
  {
    import algorithmic: *
    Function(
      "partition", ("arr", "l", "r"),
      {
        Assign($i$, $l$)
        Assign($j$, $l$)
        While([$j < r$], {
          If([$"arr"[j] < "arr"[r]$], {
            Line([zamień $"arr"[i]$ z $"arr"[j]$])
            Assign($i$, $i + 1$)
          })
          Assign($j$, $j + 1$)
        })
        Line([zamień $"arr"[i]$ z $"arr"[r]$])
        Return([$i$])
      },
    )
    LineBreak
    Procedure(
      "Quicksort", ("arr", "l", "r"),
      {
        If([$l < r$], {
          let partition = Call.with("partition")
          let Quicksort = Call.with("Quicksort")
          Assign($p$, partition[$"arr"$, $l$, $r$])
          Quicksort[$"arr"$, $l$, $p - 1$]
          Quicksort[$"arr"$, $p + 1$, $r$]
        })
      },
    )
  }
)

== Shellsort
#show: style-algorithm
#algorithm-figure(
  "Shellsort",
  supplement: "Algorytm",
  vstroke: .5pt + luma(150),
  {
    import algorithmic: *
    Procedure(
      "Shellsort", ("arr", "l", "r"),
      {
        Assign($"gap"$, $n/2$)
        While([$"gap" > 0$], {
          Assign($i$, $"gap"$)
          While([$i < n$], {
            Assign($"temp"$, $"arr"[i]$)
            Assign($j$, $i$)
            While([$j >= "gap"$ i $"arr"[j - "gap"] > "temp"$], {
              Assign($"arr"[j]$, $"arr"[j - "gap"]$)
              Assign($j$, $j - "gap"$)
            })
            Assign($"arr"[j]$, $"temp"$)
            Assign($i$, $i + 1$)
          })
          Assign($"gap"$, $"gap"/2$)
        })
      },
    )
  }
)

== Heapsort
#show: style-algorithm
#algorithm-figure(
  "Heapsort",
  supplement: "Algorytm",
  vstroke: .5pt + luma(150),
  {
    import algorithmic: *
    let heapify = Call.with("heapify")
    Procedure(
      "heapify", ("arr", "n", "i"),
      {
        Assign($"largest"$, $i$)
        Assign($"left"$, $2 * i + 1$)
        Assign($"right"$, $2 * i + 2$)

        If([$"left" < n$ i $"arr"["left"] > "arr"["largest"]$], {
          Assign($"largest"$, $"left"$)
        })

        If([$"right" < n$ i $"arr"["right"] > "arr"["largest"]$], {
          Assign($"largest"$, $"right"$)
        })

        If([$"largest" != i$], {
          Line([zamień $"arr"[i]$ z $"arr"["largest"]$])
          heapify[$"arr"$, $n$, $"largest"$]
        })
      },
    )
    LineBreak
    Procedure(
      "Heapsort", ("arr", "l", "r"),
      {
        Assign($i$, $n/2 - 1$)
        While([$i >= 0$], {
          heapify[$"arr"$, $n$, $i$]
          Assign($i$, $i - 1$)
        })
        LineBreak

        Assign($i$, $n - 1$)
        While([$i > 0$], {
          Line([zamień $"arr"[0]$ z $"arr"[i]$])
          heapify[$"arr"$, $i$, $0$]
          Assign($i$, $i - 1$)
        })
      },
    )
  }
)
#pagebreak()

= Algorytmy niekonwencjonalne
== Bogosort
== Sleep sort
== Stalin sort
