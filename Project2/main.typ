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
+ *Dane losowe:* Oczekiwany czas rzędu $O(n^2)$. Algorytm będzie mało wydajny dla większych tablic.
+ *Dane posortowane malejąco (odwrócone):* Czas działania powinien być niemal identyczny jak dla danych losowych. Liczba porównań pozostaje ta sama, więc nie oczekuję tu drastycznych różnic.
+ *Dane posortowane rosnąco:* W przeciwieństwie do Insertion sort, tutaj nie uświadczymy drastycznego spadku czasu. Algorytm i tak nie wie, że tablica jest posortowana, więc wykona pełną pulę porównań ($O(n^2)$). Czas może być co najwyżej odrobinę krótszy z powodu braku fizycznych zamian elementów (swapów) w pamięci.
+ *Dane prawie posortowane (sąsiednia wymiana):* Ponieważ metoda nie potrafi wykorzystać faktu, że elementy są już blisko swoich miejsc, czas wykonania nie ulegnie poprawie w stosunku do danych losowych.
+ *Dane prawie posortowane (globalna wymiana):* Wyniki powinny znów pokrywać się z resztą scenariuszy. Zaletą (lub wadą) tego algorytmu jest to, że niezależnie od tego, co mu podamy, robi swoje i zajmuje mu to mniej więcej tyle samo czasu.

== Bubble sort
*Zasada działania algorytmu* \
Bubble sort opiera się na wielokrotnym przechodzeniu przez listę i porównywaniu sąsiadujących ze sobą par elementów. Jeśli znajdują się one w niewłaściwej kolejności (pierwszy jest większy od drugiego), są zamieniane miejscami. Po każdym pełnym przejściu, największy z nieposortowanych elementów zostaje przeniesiony na swoją ostateczną pozycję na końcu tablicy - podobnie jak bąbelek powietrza wynurzający się z wody. W pseudokodzie poniżej jest dodatkowa optymalizacja, która powoduje przedwczesne przerwanie algorytmu gdy nie zostanie wykonana żadna zamiana elementów.

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
          Assign($s$, $0$)
          While([$j < n - i - 1$], {
            If([$"arr"[j] > "arr"[j + 1]$], {
              Line([zamień $"arr"[j]$ z $"arr"[j + 1]$])
              Assign($s$, $1$)
            })
            Assign($j$, $j + 1$)
          })
          LineBreak
          If([$s = 0$], {
            Break
          })
          Assign($i$, $i + 1$)
        })
      },
    )
  }
)

*Czasowa złożoność obliczeniowa* \
- *Najgorszy i średni przypadek:* $O(n^2)$ - wynika to wprost z użycia zagnieżdżonych pętli, z których każda wykonuje się proporcjonalnie do długości tablicy, wymuszając $n(n-1)/2$ porównań.
- *Najlepszy przypadek:* $O(n)$ algorytm przejdzie przez posortowaną listę raz nie robiąc żadnych zmian dzięki fladze.

*Hipotezy badawcze dla poszczególnych scenariuszy*
+ *Dane losowe:* Czas działania będzie stosunkowo długi przez wysoką liczbę zamian w czasie $O(n^2)$.
+ *Dane posortowane malejąco (odwrócone):* worst-case - powoduje konieczność wykonania maksymalnej możliwej liczby zamian, czas wzrośnie drastycznie.
+ *Dane posortowane rosnąco:* best-case - dzięki fladze sprawdzającej ilość zmian algorytm zrobi tylko $O(n)$ operacji.
+ *Dane prawie posortowane (sąsiednia wymiana):* Dzięki fladze algorytm będzie w stanie skończyć pracę po kilku przejściach. Czas wykonania powinien być znacznie bliższy $O(n)$ niż $O(n^2)$, zbliżony do scenariusza z danymi posortowanymi rosnąco. Jest to jedno z najlepszych wykorzystań tego algorytmu.
+ *Dane prawie posortowane (globalna wymiana):* Losowe zamiany elementów odległych od siebie powodują, że bąbelek musi kilkakrotnie przemierzać tablicę, by przenieść element na właściwe miejsce. Oczekuję czasu gorszego niż przy wymianach sąsiednich, ale nadal zauważalnie lepszego niż dla danych czysto losowych.

= Algorytmy efektywniejsze
== Quicksort
*Zasada działania algorytmu* \
Quicksort to klasyczny algorytm oparty na strategii „dziel i zwyciężaj". Wybierany jest element nazywany pivotem (w poniższej implementacji jest to zawsze ostatni element zakresu), a następnie tablica jest przestawiana tak, by wszystkie elementy mniejsze od pivota znalazły się po jego lewej stronie, a większe - po prawej. Tę operację nazywamy partycjonowaniem. Następnie algorytm rekurencyjnie wywołuje siebie dla lewej i prawej podtablicy. Podział ten trwa aż do momentu, gdy podtablice są jednoelementowe i z definicji posortowane.

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

*Czasowa złożoność obliczeniowa*
- *Najgorszy przypadek:* $O(n^2)$ – zachodzi, gdy pivot za każdym razem trafia na skrajną pozycję (np. jest minimalnym lub maksymalnym elementem zakresu). Przy zastosowanej strategii wyboru ostatniego elementu jako pivota, dokładnie taki scenariusz wystąpi dla tablic już posortowanych rosnąco lub malejąco.
- *Średni i najlepszy przypadek:* $O(n log n)$ – gdy pivot dzieli tablicę na w miarę równe części, głębokość rekursji wynosi $O(log n)$, a każdy poziom wymaga liniowej pracy.

*Hipotezy badawcze dla poszczególnych scenariuszy*
+ *Dane losowe:* Oczekuję zachowania bliskiego średniemu przypadkowi $O(n log n)$. Pivot wybierany losowo z perspektywy wartości rzadko będzie skrajny, więc drzewo rekursji powinno być płytkie i zrównoważone.
+ *Dane posortowane malejąco (odwrócone):* worst-case - ostatni element jest zawsze minimum zakresu, więc partycjonowanie tworzy skrajnie niezrównoważone podziały (jeden element po lewej, reszta po prawej). Czas wzrośnie do $O(n^2)$, a wykresy powinny wyraźnie odbiegać od pozostałych scenariuszy.
+ *Dane posortowane rosnąco:* worst-case - analogicznie do scenariusza malejącego, pivot jest zawsze maksimum zakresu, będziemy mieli $O(n^2)$. Spodziewam się czasu zbliżonego do danych malejących, oba znacznie wolniejsze od danych losowych.
+ *Dane prawie posortowane (sąsiednia wymiana):* Nieliczne zakłócenia sprawiają, że pivot rzadziej jest elementem skrajnym, więc partycjonowanie jest nieco bardziej zrównoważone niż w czystym wariancie posortowanym. Oczekuję czasu pośredniego między $O(n^2)$ a $O(n log n)$, ale wciąż bliższego temu gorszemu.
+ *Dane prawie posortowane (globalna wymiana):* Losowe zamiany odległych elementów skuteczniej „dezorganizują" tablicę niż zamiany sąsiednie, dzięki czemu pivot jest lepiej dobrany. Spodziewam się wyniku wyraźnie lepszego niż przy wymianach sąsiednich, zbliżonego do danych losowych.

== Shellsort
*Zasada działania algorytmu* \
Shellsort jest uogólnieniem Insertion sorta. Zamiast porównywać i wstawiać sąsiadujące elementy, algorytm operuje na elementach oddalonych o pewien krok (gap). Początkowo krok jest duży (w tej implementacji $n/2$), co pozwala szybko przenosić elementy daleko od ich docelowych pozycji. Następnie krok jest stopniowo zmniejszany o połowę, aż wyniesie 1 - wtedy algorytm staje się zwykłym Insertion sortem, jednak działa on na danych, które są już prawie posortowane po poprzednich przejściach, dzięki czemu wewnętrzna pętla wykonuje bardzo mało przesunięć.

#show: style-algorithm
#algorithm-figure(
  "Shellsort",
  supplement: "Algorytm",
  vstroke: .5pt + luma(150),
  {
    import algorithmic: *
    Procedure(
      "Shellsort", ("arr", "n"),
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

*Czasowa złożoność obliczeniowa*
- *Najgorszy przypadek:* $O(n^2)$ – przy oryginalnej sekwencji Shella (dzielenie przez 2). Istnieją sekwencje kroków (np. Hibbarda czy Pratta), które gwarantują lepszy wynik, jednak nie są tu stosowane.
- *Średni przypadek:* w praktyce zwykle $O(n^(3/2))$ lub lepiej przy sekwencji binarnej, zdecydowanie szybszy niż zwykłe $O(n^2)$ algorytmy.
- *Najlepszy przypadek:* $O(n log n)$ – gdy dane są już niemal posortowane, większość przejść nie wykonuje żadnych przestawień.

*Hipotezy badawcze dla poszczególnych scenariuszy*
+ *Dane losowe:* Oczekuję wyraźnie lepszego czasu niż proste algorytmy $O(n^2)$. Duże początkowe kroki szybko redukują nieporządek w tablicy, dzięki czemu ostatni przebieg z krokiem 1 jest niemal natychmiastowy.
+ *Dane posortowane malejąco (odwrócone):* Algorytm radzi sobie dobrze nawet z danymi odwróconymi, bo pierwsze duże kroki skutecznie tasują tablicę. Spodziewam się czasu podobnego do danych losowych, bez drastycznego pogorszenia charakterystycznego dla prostszych algorytmów.
+ *Dane posortowane rosnąco:* best-case — przy każdym kroku wewnętrzna pętla while nie wykonuje żadnych przesunięć, bo elementy odległe o gap są już we właściwej kolejności. Czas powinien być zauważalnie krótszy niż dla danych losowych.
+ *Dane prawie posortowane (sąsiednia wymiana):* Bardzo bliskie scenariuszowi rosnącemu. Nieliczne zaburzenia powodują znikome dodatkowe przestawienia przy małych krokach. Spodziewam się czasu praktycznie identycznego z wariantem posortowanym rosnąco.
+ *Dane prawie posortowane (globalna wymiana):* Elementy oddalone od swoich docelowych pozycji są szybko przemieszczane przez duże kroki. Oczekuję wyników bardzo zbliżonych do danych losowych, nieznacznie lepszych dzięki ogólnie mniejszemu nieporządkowi.

== Heapsort
*Zasada działania algorytmu* \
Heapsort działa dwuetapowo. W pierwszym etapie tablica jest przekształcana w strukturę zwaną kopcem maksymalnym (max-heap), czyli drzewo binarne, w którym każdy węzeł jest większy od swoich dzieci. Gwarantuje to, że korzeń (pierwszy element tablicy) zawsze zawiera maksimum. W drugim etapie algorytm wielokrotnie zamienia korzeń z ostatnim elementem kopca (odkładając tym samym maksimum na właściwe miejsce na końcu tablicy), a następnie przywraca własność kopca dla zmniejszonej o jeden struktury. Procedura `heapify` realizuje właśnie to przywracanie, opadając w dół drzewa.

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
      "Heapsort", ("arr", "n"),
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

*Czasowa złożoność obliczeniowa*
- *Najgorszy, średni i najlepszy przypadek:* $O(n log n)$ - budowanie kopca kosztuje $O(n)$, a każde z $n$ wywołań `heapify` podczas wyciągania elementów kosztuje $O(log n)$. Co istotne, Heapsort jest algorytmem nieadaptywnym - jego złożoność nie zmienia się w zależności od ułożenia danych wejściowych.

*Hipotezy badawcze dla poszczególnych scenariuszy*
+ *Dane losowe:* Oczekuję stabilnego czasu rzędu $O(n log n)$. Heapsort powinien być porównywalny z Quicksortem dla danych losowych, choć w praktyce bywa nieco wolniejszy ze względu na gorszy współczynnik stały i mniej przyjazny wzorzec dostępu do pamięci co będzie powodowało chybienie pamięci cache.
+ *Dane posortowane malejąco (odwrócone):* W przeciwieństwie do Quicksorta, Heapsort nie ma tutaj problemu. Budowanie kopca z odwróconej tablicy przebiega sprawnie, a dalsze etapy sortowania są identyczne jak zawsze. Oczekuję czasu zbliżonego do danych losowych.
+ *Dane posortowane rosnąco:* Analogicznie, algorytm wykona tę samą pracę niezależnie od wejścia. Dane posortowane rosnąco mogą jednak powodować nieco więcej zamian przy budowaniu kopca, co może skutkować minimalnie gorszym czasem niż dla danych losowych.
+ *Dane prawie posortowane (sąsiednia wymiana):* Nieadaptywność Heapsortu ujawnia się tutaj jako słabość. Algorytm nie potrafi wykorzystać faktu, że dane są niemal posortowane. Oczekuję czasu bardzo zbliżonego do scenariusza z danymi losowymi.
+ *Dane prawie posortowane (globalna wymiana):* Tak samo jak powyżej, Heapsort będzie zachowywał się praktycznie identycznie we wszystkich pięciu scenariuszach. Wykresy powinny być niemal równoległe i bliskie sobie wartościami.

= Algorytmy niekonwencjonalne
== Bogosort
== Sleep sort
== Stalin sort
