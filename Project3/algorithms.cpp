#include "./algorithms.hpp"
#include <algorithm>
#include <cstdlib>

Points graham_scan(Points& points) {
    int n = points.size();
    if (n < 3) return points;

    // Find lowest point
    int min_idx = 0;
    for (int i = 1; i < n; i++) {
        if (points[i].y < points[min_idx].y - EPSILON || 
           (std::abs(points[i].y - points[min_idx].y) < EPSILON && points[i].x < points[min_idx].x - EPSILON)) {
            min_idx = i;
        }
    }

    // Set p0 as first point
    std::swap(points[0], points[min_idx]);
    Point p0 = points[0];

    // Sort by angle
    std::sort(points.begin() + 1, points.end(), [&p0](const Point& p1, const Point& p2) {
        double cp = p0.cross_product(p1, p2);
        
        // Left turn = smaller angle
        if (std::abs(cp) > EPSILON) {
            return cp > 0; 
        }

        // If colinear, sort by distance
        return p0.dist_sq(p1) < p0.dist_sq(p2);
    });

    // Filter colinear points leaving only the furthest one from p0
    int m = 1; 
    for (int i = 1; i < n; i++) {
        while (i < n - 1 && std::abs(p0.cross_product(points[i], points[i+1])) < EPSILON) {
            i++; 
        }
        points[m++] = points[i];
    }

    // If less than 3 points remain there is no polygon
    if (m < 3) {
        return Points(points.begin(), points.begin() + m);
    }

    // Scanning with the vector as our stack
    Points hull;
    hull.reserve(m);
    hull.push_back(points[0]);
    hull.push_back(points[1]);
    hull.push_back(points[2]);

    for (int i = 3; i < m; i++) {
        // Take points of the stack until last points make a left turn
        while (hull.size() > 1) {
            Point top = hull.back();
            Point next_to_top = hull[hull.size() - 2];
            
            // Pop the point if it creates a right turn
            if (next_to_top.cross_product(top, points[i]) < EPSILON) {
                hull.pop_back();
            } else {
                break;
            }
        }
        hull.push_back(points[i]);
    }

    return hull;
}

Points monotone_chain(Points& points) {
    int n = points.size();
    
    // Zabezpieczenie przed zbyt małą liczbą punktów
    if (n < 3) return points;

    // 1. Sortowanie leksykograficzne (wykorzystuje Twój operator < ze struktury Point)
    std::sort(points.begin(), points.end());

    // Opcjonalnie: usunięcie duplikatów dla pełnego bezpieczeństwa (wymaga operatora ==)
    points.erase(std::unique(points.begin(), points.end()), points.end());
    n = points.size();
    if (n < 3) return points;

    Points hull;
    hull.reserve(2 * n); // Rezerwacja pamięci, maksymalny rozmiar to obwód wte i wewte

    // 2. Budowa dolnej otoczki (Lower Hull)
    for (int i = 0; i < n; i++) {
        // Dopóki 3 ostatnie punkty nie tworzą skrętu w lewo (odrzucamy prawe skręty i współliniowe)
        while (hull.size() >= 2) {
            Point top = hull.back();
            Point next_to_top = hull[hull.size() - 2];
            
            if (next_to_top.cross_product(top, points[i]) < EPSILON) {
                hull.pop_back();
            } else {
                break;
            }
        }
        hull.push_back(points[i]);
    }

    // 3. Budowa górnej otoczki (Upper Hull)
    // Zapamiętujemy rozmiar dolnej otoczki, żeby nie usunąć jej punktów
    int t = hull.size() + 1; 
    for (int i = n - 2; i >= 0; i--) {
        while (hull.size() >= t) {
            Point top = hull.back();
            Point next_to_top = hull[hull.size() - 2];
            
            if (next_to_top.cross_product(top, points[i]) < EPSILON) {
                hull.pop_back();
            } else {
                break;
            }
        }
        hull.push_back(points[i]);
    }

    // Ostatni dodany punkt to punkt startowy dolnej otoczki - usuwamy duplikat
    hull.pop_back();

    return hull;
}

Points jarvis_march(Points& points) {
    int n = points.size();
    if (n < 3) return points;

    Points hull;

    // 1. Znajdź punkt startowy: najmniejszy X (w lewo). 
    // W razie remisu bierzemy najmniejszy Y (najniżej).
    int leftmost = 0;
    for (int i = 1; i < n; i++) {
        if (points[i].x < points[leftmost].x - EPSILON || 
           (std::abs(points[i].x - points[leftmost].x) < EPSILON && points[i].y < points[leftmost].y - EPSILON)) {
            leftmost = i;
        }
    }

    int p = leftmost;
    int q;

    // 2. Owijanie (Gift Wrapping)
    do {
        // Dodaj obecny punkt do otoczki
        hull.push_back(points[p]);

        // Wybieramy następny punkt 'q' jako (p + 1) % n. 
        // Będziemy go aktualizować, jeśli znajdziemy punkt bardziej na lewo.
        q = (p + 1) % n;

        for (int i = 0; i < n; i++) {
            // Szukamy punktu 'i', który tworzy skręt w lewo względem wektora p -> q
            double cp = points[p].cross_product(points[i], points[q]);
            
            if (cp > EPSILON) {
                // Znaleziono punkt bardziej "na zewnątrz" (skręt w lewo)
                q = i;
            } else if (std::abs(cp) < EPSILON) {
                // Punkty są współliniowe. Wybieramy ten, który jest dalej od 'p'.
                // Dzięki temu odrzucamy niepotrzebne punkty wewnątrz krawędzi (np. w siatce).
                if (points[p].dist_sq(points[i]) > points[p].dist_sq(points[q])) {
                    q = i;
                }
            }
        }

        // q staje się naszym nowym punktem startowym do następnej iteracji
        p = q;

    } while (p != leftmost); // Zakończ, gdy zamkniemy obwód (wrócimy do startu)

    return hull;
}

double dist_to_line(const Point& A, const Point& B, const Point& P) {
    return std::abs(A.cross_product(B, P));
}

// Główna funkcja rekurencyjna algorytmu
void find_hull(const Points& points, const Point& A, const Point& B, Points& hull) {
    int farthestIdx = -1;
    double maxDist = -1.0;

    for (int i = 0; i < points.size(); i++) {
        // Interesują nas TYLKO punkty znajdujące się ściśle po lewej stronie wektora A -> B
        double cp = A.cross_product(B, points[i]);
        
        if (cp > EPSILON) {
            double dist = dist_to_line(A, B, points[i]);
            
            if (dist > maxDist + EPSILON) {
                maxDist = dist;
                farthestIdx = i;
            } else if (std::abs(dist - maxDist) < EPSILON) {
                // Remis: dwa punkty leżą na prostej równoległej do AB (np. na siatce).
                // Wybieramy ten najdalszy od punktu A, by maksymalnie "rozciągnąć" trójkąt
                // i odrzucić jak najwięcej punktów znajdujących się w jego wnętrzu.
                if (farthestIdx != -1 && A.dist_sq(points[i]) > A.dist_sq(points[farthestIdx])) {
                    farthestIdx = i;
                }
            }
        }
    }

    if (farthestIdx == -1) {
        // Warunek końcowy: brak punktów po lewej stronie prostej.
        // Oznacza to, że punkt B jest wierzchołkiem otoczki wypukłej.
        // Punktu A nie dodajemy, by uniknąć duplikatów (dodała go poprzednia ramka rekurencji).
        hull.push_back(B);
        return;
    }

    Point C = points[farthestIdx];

    // Rekurencyjne wywołania dla dwóch nowych krawędzi.
    // UWAGA: Kolejność jest krytyczna, aby otoczka była posortowana kątowo (CCW)!
    find_hull(points, A, C, hull); // Szukaj po lewej od wektora AC
    find_hull(points, C, B, hull); // Szukaj po lewej od wektora CB
}

Points quick_hull(Points& points) {
    int n = points.size();
    if (n < 3) return points;

    // 1. Znajdź punkty skrajne: najbardziej wysunięty na lewo (A) i na prawo (B)
    int min_x = 0, max_x = 0;
    for (int i = 1; i < n; i++) {
        // Minimalny X (w lewo). W razie remisu najmniejszy Y.
        if (points[i].x < points[min_x].x - EPSILON || 
           (std::abs(points[i].x - points[min_x].x) < EPSILON && points[i].y < points[min_x].y - EPSILON)) {
            min_x = i;
        }
        // Maksymalny X (w prawo). W razie remisu największy Y.
        if (points[i].x > points[max_x].x + EPSILON || 
           (std::abs(points[i].x - points[max_x].x) < EPSILON && points[i].y > points[max_x].y + EPSILON)) {
            max_x = i;
        }
    }

    Point A = points[min_x];
    Point B = points[max_x];

    Points hull;
    hull.push_back(A); // Inicjujemy otoczkę punktem startowym

    // 2. Odpalamy rekurencję dla punktów "nad" i "pod" prostą wyznaczoną przez skrajne punkty
    find_hull(points, A, B, hull); 
    find_hull(points, B, A, hull); 

    // Ostatnie wywołanie rekurencji dla powrotu po "dolnej" części zazwyczaj
    // dorzuca punkt A ponownie na koniec. Usuwamy ten duplikat.
    if (hull.size() > 1 && hull.front() == hull.back()) {
        hull.pop_back();
    }

    return hull;
}

// Funkcja pomocnicza: szuka "stycznej" z punktu 'p' do wypukłej podotoczki 'subhull'.
Point find_tangent(const Points& subhull, const Point& p) {
    Point q = subhull[0];
    for (size_t i = 1; i < subhull.size(); i++) {
        double cp = p.cross_product(subhull[i], q);
        // Szukamy punktu najbardziej wysuniętego na zewnątrz (w lewo)
        if (cp > EPSILON) {
            q = subhull[i];
        } else if (std::abs(cp) < EPSILON) {
            // Remis (współliniowość) - bierzemy najdalszy punkt
            if (p.dist_sq(subhull[i]) > p.dist_sq(q)) {
                q = subhull[i];
            }
        }
    }
    return q;
}

Points chans_algorithm(Points& points) {
    int n = points.size();
    if (n < 3) return points;

    // 1. Znajdź absolutnie pewny punkt startowy (najmniejszy X, potem Y)
    Point p0 = points[0];
    for (int i = 1; i < n; i++) {
        if (points[i].x < p0.x - EPSILON || 
           (std::abs(points[i].x - p0.x) < EPSILON && points[i].y < p0.y - EPSILON)) {
            p0 = points[i];
        }
    }

    // 2. Główna pętla zgadująca 'm' (rozmiar otoczki)
    // m rośnie potęgując się: 3, 9, 81, 6561... (zapobiega to zbyt wielu iteracjom)
    for (long long m = 3; m <= n; m = std::min((long long)n, m * m)) {
        
        // Faza A: Podział na podzbiory i budowa podotoczek (Divide & Conquer)
        std::vector<Points> subhulls;
        for (int i = 0; i < n; i += m) {
            Points subset;
            int end = std::min((long long)n, (long long)i + m);
            for (int j = i; j < end; j++) {
                subset.push_back(points[j]);
            }
            // Używamy Łańcucha Monotonicznego jako bardzo szybkiego "sub-algorytmu"
            subhulls.push_back(monotone_chain(subset)); 
        }

        // Faza B: Zmodyfikowany Marsz Jarvisa pomiędzy podotoczkami
        Points hull;
        hull.push_back(p0);
        Point p = p0;

        for (int step = 0; step < m; step++) {
            // Inicjalizacja szukanego następnego punktu jakimkolwiek innym punktem
            Point next_p = (points[0] == p) ? points[1] : points[0];

            // Szukamy najlepszej stycznej ze wszystkich podotoczek
            for (const auto& sh : subhulls) {
                Point q = find_tangent(sh, p);
               
                double cp = p.cross_product(q, next_p);
                if (cp > EPSILON) {
                    next_p = q;
                } else if (std::abs(cp) < EPSILON && p.dist_sq(q) > p.dist_sq(next_p)) {
                    next_p = q;
                }
            }

            if (next_p == p0) {
                // Zamknęliśmy obwód wewnątrz limitu 'm' kroków! Zgadliśmy dobre 'm'.
                return hull;
            }

            hull.push_back(next_p);
            p = next_p;
        }

        // Jeśli zrobiliśmy 'm' kroków i nie wróciliśmy do p0, m było za małe.
        // Pętla się obróci i spróbujemy ponownie z m = m * m.
        if (m == n) break; // Zabezpieczenie skrajnego przypadku
    }

    // Fallback bezpieczeństwa (nigdy nie powinien się wykonać przy poprawnych danych)
    return monotone_chain(points); 
}
