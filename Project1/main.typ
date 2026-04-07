#set document(
  title: [Porównanie numerycznych metod całkowania],
  author: ("Piotr Niepsuj",),
)

#set text(lang: "pl")
#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3": plot, chart
#import "error-margins.typ": draw-error-margin-plot
#import "visual-plots.typ": draw-rectangle-plot, draw-trapezoidal-plot, draw-monte-carlo-plot
#import "approaching-value.typ": draw-approaching-value-plot
#import "execution-time.typ": draw-execution-time-plot, average-time

#align(center)[#title()]
#align(center)[Piotr Niepsuj]

= 1. Wstęp

== Cel projektu
Celem projektu jest analiza oraz empiryczne porównanie wydajności i dokładności wybranych metod numerycznego obliczania całek oznaczonych, a także wizualizacja ich działania. Badaniu poddano metody deterministyczne (metoda prostokątów, metoda trapezów) oraz stochastyczną (metoda Monte Carlo). Aby rzetelnie ocenić skuteczność badanych algorytmów, testy zostaną przeprowadzone w dwóch scenariuszach: dla stosunkowo prostej funkcji $f(x)$ oraz dla bardziej skomplikowanej, wykazującej silne oscylacje funkcji $g(x)$, której całkowanie metodami analitycznymi może okazać się znacznie trudniejsze.

== Środowisko testowe i sprzęt
- Procesor: Intel Core i5-12600K
- Pamięć RAM: 32 GB (DDR4)
- Język programowania: C++
- Kompilator: g++ (GCC) 14.3.0

= 2. Prosta funkcja
Za funkcję $f(x)$ wybrałem wielomian kwadratowy $-x^2 + 4x + 1$, który jest stosunkowo prosty do całkowania analitycznie, wystarczy do tego kilka prostych zasad całkowania.

$ f(x) = -x^2 + 4x + 1 $
$ integral f(x) dif x = integral (-x^2 + 4x + 1) dif x = integral -x^2 dif x + integral 4x dif x + integral 1 dif x = $
$ = -integral x^2 dif x + 4integral x dif x + integral 1 dif x = -x^3/3 + 4 dot x^2/2 + x + C = -1/3 x^3 + 2x^2 + x + C $
$ integral f(x) dif x = -1/3 x^3 + 2x^2 + x + C $

Teraz możemy policzyć całkę oznaczoną do której wybrałem przedział $[0;3]$.

$ integral_0^3 f(x) dif x = [-1/3 x^3 + 2x^2 + x]_0^3 = (-1/3 dot 3^3 + 2 dot 3^2 + 3) - (-1/3 dot 0^3 + 2 dot 0^2 + 0) = $
$ = (-1/3 dot 27 + 2 dot 9 + 3) - (-1/3 dot 0 + 2 dot 0 + 0) = (-9 + 18 + 3) - (0 + 0 + 0) = 12 $
$ integral_0^3 f(x) dif x = 12 $

Mając konkretną wartość możemy zacząć porównywać jak radzą sobie z jej uzyskaniem metody numeryczne.

== 2.1 Metoda prostokątów
Najpierw zobaczmy metodę prostokątów, która dzieli przedział $[a;b]$ na $n$ prostokątów których wysokość jest wyznaczana na podstawie wartości funkcji podcałkowej w określonym punkcie danego podprzedziału. Szerokość każdego takiego prostokąta (oznaczana zazwyczaj jako $Delta x$) jest stała i oblicza się ją dzieląc długość całego przedziału przez liczbę podziałów, czyli ze wzoru $(b-a)/n$. Z kolei to, w którym dokładnie miejscu badamy funkcję, decyduje o wysokości prostokąta. Wyróżniamy trzy główne metody

=== 2.1.1 Metoda lewych prostokątów
Wysokość uzyskujemy z wartości funkcji $f(x)$ na lewym brzegu podprzedziału. Funkcja jest parabolą która najpierw rośnie, z @f-lewe-prostokąty widzimy, że na tym etapie prostokąty nie wypełniają całego obszaru pod wykresem, przez co metoda wylicza za małe pole (niedoszacowanie). Z kolei w momencie, gdy funkcja osiąga wierzchołek i zaczyna maleć, sytuacja się odwraca – lewy brzeg znajduje się wyżej niż reszta podprzedziału, więc prostokąty zaczynają obejmować nadmiar obszaru, dając zawyżony wynik.

#draw-rectangle-plot("f-rectangle-left.csv", x => (-x*x) + (4*x) + 1, $f(x) = -x^2 + 4x + 1$, (0, 3), (0, 6), [Wizualizacja metody lewych prostokątów na funkcji $f(x)$, gdzie suma zacieniowanych obszarów stanowi przybliżoną wartość całki.]) <f-lewe-prostokąty>

Dzięki tej metodzie po zsumowaniu 10 pól prostokątów z @f-lewe-prostokąty osiągnęliśmy wartość 11.51.

=== 2.1.2 Metoda środkowych prostokątów
Metoda działa analogicznie do metody lewych prostokątów, z tą różnicą, że wysokość prostokątu jest wyznaczana na podstawie środkowej wartości podprzedziału. Z @f-środkowe-prostokąty możemy zauważyć, że teraz każdy prostokąt ma obszar, w którym wystaje ponad wykres funkcji (tworząc nadmiar), oraz taki, w którym nie dosięga krzywej (pozostawiając puste miejsce). Dzięki temu błędy przeszacowania i niedoszacowania w obrębie tego samego podprzedziału częściowo się kompensują, co sprawia, że ta metoda daje zazwyczaj znacznie dokładniejsze przybliżenie całki niż warianty opierające się na skrajnych punktach, co zobaczymy później na @f-błąd-bezwzględny i @f-zbieżność-200.

#draw-rectangle-plot("f-rectangle-center.csv", x => (-x*x) + (4*x) + 1, $f(x) = -x^2 + 4x + 1$, (0, 3), (0, 6), [Wizualizacja metody środkowych prostokątów na funkcji $f(x)$, gdzie suma zacieniowanych obszarów stanowi przybliżoną wartość całki.]) <f-środkowe-prostokąty>

Dzięki tej metodzie po zsumowaniu 10 pól prostokątów z @f-środkowe-prostokąty osiągnęliśmy wartość 12.02 co jest o wiele lepszym oszacowaniem niż 11.51 z metody lewych prostokątów.

=== 2.1.3 Metoda prawych prostokątów
Działanie jest analogiczne do poprzednich metod prostokątów, z tą różnicą, że wysokość jest wyznaczana na podstawie wartości z prawego brzegu podprzedziału. Możemy zobaczyć na @f-prawe-prostokąty, że mamy odwrotną sytuację do @f-lewe-prostokąty. Tutaj mamy nadmiary kiedy funkcja rośnie i niedoszacowania w momencie, gdy funkcja osiąga wierzchołek i zaczyna maleć.

#draw-rectangle-plot("f-rectangle-right.csv", x => (-x*x) + (4*x) + 1, $f(x) = -x^2 + 4x + 1$, (0, 3), (0, 6), [Wizualizacja metody prawych prostokątów na funkcji $f(x)$, gdzie suma zacieniowanych obszarów stanowi przybliżoną wartość całki.]) <f-prawe-prostokąty>

Dzięki tej metodzie po zsumowaniu 10 pól prostokątów z @f-środkowe-prostokąty osiągnęliśmy wartość 12.41.

== 2.2 Metoda trapezów
Kolejnym podejściem, któremu się przyjrzymy, jest metoda trapezów, która dzieli przedział $[a,b]$ na $n$ trapezów. Długości ich równoległych podstaw są wyznaczane na podstawie wartości funkcji podcałkowej na obu krańcach danego podprzedziału (lewym i prawym). Szerokość każdego takiego trapezu (oznaczana jako $Delta x$) jest stała i oblicza się ją dokładnie tak samo jak szerokość prostokątów – dzieląc długość całego przedziału przez liczbę podziałów ze wzoru $(b-a)/n$. Z kolei to, co odróżnia tę metodę od poprzednich, to sposób przybliżania samej krzywej. Zamiast poziomego "daszku", wykres aproksymowany jest pochyłym odcinkiem łączącym wartości funkcji na brzegach podprzedziału, co z reguły znacznie lepiej odwzorowuje rzeczywisty kształt funkcji i redukuje błędy widoczne w metodzie prostokątów.

#draw-trapezoidal-plot("f-trapezoid.csv", x => (-x*x) + (4*x) + 1, $f(x) = -x^2 + 4x + 1$, (0, 3), (0, 6), [Wizualizacja metody trapezów na funkcji $f(x)$, gdzie suma zacieniowanych obszarów stanowi przybliżoną wartość całki.]) <f-trapezy>

Przy zsumowaniu pól 10 trapezów z @f-trapezy otrzymujemy wartość 11.96 co tak jak metoda środkowych prostokątów jest bardzo dobrym przybliżeniem.

== 2.3 Metoda Monte Carlo
Zupełnie innym podejściem, któremu się przyjrzymy, jest stochastyczna metoda Monte Carlo. W przeciwieństwie do poprzednich metod, nie dzieli ona przedziału $[a,b]$ na $n$ regularnych figur geometrycznych o stałej szerokości. Zamiast tego opiera się na prawdopodobieństwie i losowaniu. W jej podstawowym wariancie (zwanym metodą wartości średniej) wybieramy $n$ całkowicie losowych punktów z całego przedziału całkowania. Z kolei to, jakie wartości przyjmuje funkcja podcałkowa w tych wylosowanych miejscach, pozwala nam wyznaczyć jej średnią wysokość - obliczamy po prostu średnią arytmetyczną wszystkich uzyskanych wyników. Przybliżoną wartość całki uzyskujemy następnie mnożąc tę uśrednioną wysokość przez całkowitą długość przedziału, czyli $(b−a)$. Oznacza to, że dokładność tej metody nie wynika z gęstości stałej siatki podziału, lecz z odpowiednio dużej liczby "próbek" losowych.

#draw-monte-carlo-plot("f-monte-carlo-800.csv", x => (-x*x) + (4*x) + 1, $f(x) = -x^2 + 4x + 1$, (0, 3), (0, 6), [Wizualizacja metody Monte Carlo na funkcji $f(x)$, gdzie punkty zielone są częścią obczasru pod funkcją, a czerwone nie.])

W tej metodzie tak jak w poprzednich 10 próbek (tam podziałów) nie wystarczy do dokładnego przybliżenia wartości całki, ponieważ przy tak małej próbie losowy rozkład punktów nie jest w stanie dobrze zreprezentować zachowania całej funkcji. Prowadzi to do dużej wariancji i bardzo wysokiego błędu. Dopiero znaczne zwiększenie liczby losowań pozwala ustabilizować wynik i zbliżyć się do rozwiązania analitycznego - w przeprowadzonym teście zastosowanie 800 próbek pozwoliło uzyskać przybliżoną wartość równą 11.71.

== 2.4 Porównanie błędu bezwzględnego i zbieżności
#draw-error-margin-plot("f", (1, 8), (-16, 1)) <f-błąd-bezwzględny>

Pierwsza ciekawa rzecz jaką możemy zauważyć z @f-błąd-bezwzględny to pokrycie się metody lewych i prawych prostokątów, ich błąd bezwzględny nachodzi na siebie prawie idealnie. Druga rzecz jaką możemy zaobserwować, to że każda z metod tworzy linie proste na wykresie w skali podwójnie logarytmicznej, co dowodzi, że błąd dla każdej z metod maleje w sposób potęgowy. Nachylenie tych prostych obrazuje rząd zbieżności poszczególnych algorytmów. Metoda lewych i prawych prostokątów wykazuje zbieżność rzędu pierwszego, gdzie błąd jest proporcjonalny do $1/n$. Metoda trapezów i środkowych prostokątów zbiega znacznie szybciej - z rzędem drugim, gdzie błąd jest proporcjonalny do $1/n^2$.

#draw-approaching-value-plot("f", 12.0, 10, (10, 200), (11, 13)) <f-zbieżność-200>

@f-zbieżność-200 pokazuje nam, że metoda prawych prostokątów zawyża wynik, a lewych zaniża, powoli zbiegając do wartości oczekiwanej równej 12. Metoda trapezów i środkowych prostokątów niemal natychmiast "przyklejają się" do oczekiwanej wartości. Z kolei krzywa dla Monte Carlo gwałtownie skacze, a jej odchylenie standardowe potrafi pokrywać obszar od wartości poniżej 11 do ponad 13. Żeby lepiej zaobserwować metodę Monte Carlo potrzebna jest większa skala. 

#draw-approaching-value-plot("f", 12.0, 1000, (10, 10000), (11, 13)) <f-zbieżność-10000>

Na @f-zbieżność-10000 z większym przedziałem widzimy wyraźnie stabilność metod deterministycznych, których wykresy zlewają się z wartością oczekiwaną. W kontraście pozostaje metoda Monte Carlo, która mimo użycia tysięcy punktów nadal wykazuje szum i skacze wokół wyniku, a jej przedział ufności (zacieniony na fioletowo) wciąż jest zauważalnie szeroki.

= 3. Skomplikowana funkcja
Za funkcję $g(x)$ wybrałem $x sin(20x)$. Jest to już bardziej skomplikowana funkcja, która oscyluje. Do całkowania analitycznego będziemy musieli wykorzystać bardziej skomplikowane równania, w tym przypadku skorzystamy z metody przez części.
$ g(x) = x sin(20x) $
$ integral g(x) dif x = integral x sin(20x) dif x = x dot (-1/20 cos(20x)) - integral (-1/20 cos(20x)) dif x = $
$ = -x/20 cos(20x) + 1/20 integral cos(20x) dif x = -x/20 cos(20x) + 1/20 dot (1/20 sin(20x)) + C = -x/20 cos(20x) + 1/400 sin(20x) + C $
$ integral g(x) dif x = -x/20 cos(20x) + 1/400 sin(20x) + C $

Teraz możemy policzyć całkę oznaczoną do której wybrałem przedział $[0;3/2]$.

$ integral_0^(3/2) g(x) dif x = [-x/20 cos(20x) + 1/400 sin(20x)]_0^(3/2) = $
$ = (-(3/2)/20 cos(20 dot 3/2) + 1/400 sin(20 dot 3/2)) - (-0/20 cos(20 dot 0) + 1/400 sin(20 dot 0)) $
$ = (-3/40 cos(30) + 1/400 sin(30)) - (0 + 1/400 sin(0)) = ((-3/40) dot 0.15425 + 1/400 dot (-0.98803)) - 0 = $
$ = -(0.011569 + 0.002470) = -0.014039 $
$ integral_0^(3/2) g(x) dif x = -0.014039 $

Mając konkretną wartość możemy zacząć porównywać jak radzą sobie z jej uzyskaniem metody numeryczne. Działanie metod zostało wyjaśnione przy prostej funkcji, dlatego teraz skupimy się tylko na obserwacjach z wizualizacji i wykresów. Tym razem zamiast 10 podziałów użyjemy 40, jako, że funkcja ma silne oscylacje.

== 3.1 Metoda prostokątów
=== 3.1.1 Lewe prostokąty
Na @g-lewe-prostokąty widać, że w przypadku funkcji silnie oscylującej metoda lewych prostokątów bardzo słabo radzi sobie z nagłymi zmianami wartości krzywej. Płaskie wierzchołki prostokątów tworzą duże schodkowe struktury, które wyraźnie rozmijają się ze szczytami i dolinami funkcji, generując duże pola błędów na każdym zboczu.

#draw-rectangle-plot("g-rectangle-left.csv", x => x * calc.sin(20 * x), $g(x) = x sin(20x)$, (0, 1.5), (-2, 2), [Wizualizacja metody lewych prostokątów na funkcji $g(x)$, gdzie suma zacieniowanych obszarów stanowi przybliżoną wartość całki.]) <g-lewe-prostokąty>

Po zsumowaniu pól 40 prostokątów z @g-lewe-prostokąty otrzymujemy wartość 0.014178, patrząc na oryginalną wartość -0.014039 nie jest to najgorsze przybliżenie przy tak małej wartości. Zauważmy, że pomimo bliskiej numerycznej zgodności nie zgadza się znak.

=== 3.1.2 Środkowe prostokąty
W odróżnieniu od metody lewych prostokątów, z @g-środkowe-prostokąty środkowych prostokątów można zaobserwować o wiele lepsze dopasowanie do oscylującej krzywej. Słupki przecinają funkcję w takich miejscach, że trójkątne "braki" i "nadmiary" na każdym podprzedziale wizualnie dobrze się ze sobą znoszą, co znacznie poprawia pokrycie obszaru.

#draw-rectangle-plot("g-rectangle-center.csv", x => x * calc.sin(20 * x), $g(x) = x sin(20x)$, (0, 1.5), (-2, 2), [Wizualizacja metody środkowych prostokątów na funkcji $g(x)$, gdzie suma zacieniowanych obszarów stanowi przybliżoną wartość całki.]) <g-środkowe-prostokąty>

Tym razem po zsumowaniu pól 40 prostokątów z @g-środkowe-prostokąty otrzymujemy wartość -0.014254 co jest o wiele lepszym przybliżeniem.

=== 3.1.3 Prawe prostokąty
Obserwacje z @g-prawe-prostokąty prawych prostokątów są bardzo zbliżone do tych z metody lewych - algorytm jest mocno wrażliwy na gwałtowne zmiany wykresu funkcji. Wysokości prostokątów "uciekają" od rzeczywistej krzywizny w lokalnych ekstremach, co ponownie tworzy znaczne niedoszacowania oraz przeszacowania.

#draw-rectangle-plot("g-rectangle-right.csv", x => x * calc.sin(20 * x), $g(x) = x sin(20x)$, (0, 1.5), (-2, 2), [Wizualizacja metody prawych prostokątów na funkcji $g(x)$, gdzie suma zacieniowanych obszarów stanowi przybliżoną wartość całki.]) <g-prawe-prostokąty>

Gdy zsumójemy pola 40 prostokątów z @g-prawe-prostokąty otrzymujemy wartość -0.041399.

== 3.2 Metoda trapezów
Z @g-trapezy trapezów można wywnioskować, że pochyłe ramiona figur doskonale otulają kształt skomplikowanej funkcji. Dopasowanie jest wizualnie na tyle ścisłe, że przerwy pomiędzy łukami funkcji a krawędziami trapezów są niemal niedostrzegalne.

#draw-trapezoidal-plot("g-trapezoid.csv", x => x * calc.sin(20 * x), $g(x) = x sin(20x)$, (0, 1.5), (-2, 2), [Wizualizacja metody trapezów na funkcji $g(x)$, gdzie suma zacieniowanych obszarów stanowi przybliżoną wartość całki.]) <g-trapezy>

Zsumowanie pól 40 trapezów z @g-trapezy daje nam wartość -0.013611.

== 3.3 Metoda Monte Carlo
Pierwsza rzecz jaką możemy zauważyć na @g-monte-carlo jest mała ilość trafionych punktów w porównaniu do o wiele większej ilości punktów chybionych. Spowodowane jest to tym, że funkcja zaczyna od niewielkich oscylacji zajmujących bardzo małą powierzchnię, po czym zaczyna rosnąć co znacznie rozszerza pas minimalnych i maksymalnych wartości $y$ jakie algorytm może wylosować. W rezultacie funkcja tworzy bardzo małą przestrzeń w którą losowy punkt może się wstrzelić.

#draw-monte-carlo-plot("g-monte-carlo-800.csv", x => x * calc.sin(20 * x), $g(x) = x sin(20x)$, (0, 1.5), (-2, 2), [Wizualizacja metody Monte Carlo na funkcji $g(x)$, gdzie punkty zielone są częścią obczasru pod funkcją, a czerwone nie.]) <g-monte-carlo>

Tak jak przy funkcji prostej użyte zostało 800 próbek, co daje nam wynik -0.077980.

== 3.4 Porównanie błędu bezwzględnego i zbieżności
Z @g-błąd-bezwzględny błędu bezwzględnego wynika ta sama zasada, którą zaobserwowaliśmy przy prostej funkcji. Metody lewych i prawych prostokątów dają niemal identyczny, stosunkowo wysoki błąd, zbiegając wolniej. Metody środkowych prostokątów i trapezów zbiegają najszybciej, natomiast błąd metody Monte Carlo wciąż jest największy i najwolniej maleje.

#draw-error-margin-plot("g", (1, 8), (-18, 1)) <g-błąd-bezwzględny>

Na wykresach zbieżności dla małej (@g-zbieżność-200) i dużej (@g-zbieżność-10000) liczby podziałów/próbek widać dobitnie wady metody stochastycznej. Wykres Monte Carlo jest niezwykle poszarpany, a przedział ufności ucieka daleko poza skalę dla małych prób. Nawet przy wielotysięcznej próbie fioletowa linia dalej lekko oscyluje wokół właściwego wyniku. Z kolei metody deterministyczne (w szczególności środkowe prostokąty i trapezy) błyskawicznie stają się płaską linią, osiągając zamierzony cel -0.014039.

#draw-approaching-value-plot("g", -0.014039, 10, (10, 200), (-0.3, 0.3)) <g-zbieżność-200>
#draw-approaching-value-plot("g", -0.014039, 1000, (10, 10000), (-0.3, 0.3)) <g-zbieżność-10000>

= 4 Czas wykonania algorytmów
Wykres czasu wykonania algorytmów z @czas-wykonania-algorytmów zestawiony z liczbą próbek na skali logarytmicznej tworzy proste równoległe, co pokazuje, że zasobożerność wszystkich metod rośnie liniowo wraz z $n$. Z zebranych danych wyraźnie wynika, że najwolniejsza i najbardziej kosztowną obliczeniowo na każdym szczeblu jest metoda Monte Carlo dając przy tym najgorsze wyniki. Z drugiej strony, metody lewych, środkowych i prawych prostokątów (których czas wykonywania zlewa się ze względu na praktycznie identyczną implementację) są najszybsze. Metoda trapezów wymaga więcej zasobów, ale nadal jest to mniejsza ilość niż metoda Monte Carlo.

#draw-execution-time-plot("f", (1, 8), (0, 8), [Czas wykonania algorytmów w zależności od ilości podziałów/próbek w skali podwójnie logarytmicznej.]) <czas-wykonania-algorytmów>

= 5 Wnioski
Podsumowując przeprowadzone testy zarówno dla prostej, jak i skomplikowanej funkcji najlepszym kandydatem jest metoda środkowych prostokątów, bardzo szybko i wydajnie aproksymuje obszar pod wykresem. Metoda trapezów też radzi sobie świetnie, z taką samą szybkością zmniejsza błąd bezwzględny wartości, ale jest wolniejsza i wymaga więcej zasobów, wynika to prawdopodobnie z potrzeby wywołania analizowanej funkcji dwa razy dla każdego podprzedziału, aby wyliczyć lewą i prawą wysokość co zauważmy, że można zoptymalizować używając prawej wysokości z poprzedniego podprzedziału jako lewej wysokości aktualnego podprzedziału.
