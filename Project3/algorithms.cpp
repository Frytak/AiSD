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
    if (n < 3) return points;

    std::sort(points.begin(), points.end());

    Points hull;
    hull.reserve(2 * n);

    // Building the lower hull
    for (int i = 0; i < n; i++) {
        // Until the last 3 points do not make a left turn, discard right turns and collinear points
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

    // Building the upper hull
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

    // Last added point is the starting point of the lower hull - remove duplicate
    hull.pop_back();

    return hull;
}

Points jarvis_march(Points& points) {
    int n = points.size();
    if (n < 3) return points;

    Points hull;

    int leftmost = 0;
    for (int i = 1; i < n; i++) {
        if (points[i].x < points[leftmost].x - EPSILON || 
           (std::abs(points[i].x - points[leftmost].x) < EPSILON && points[i].y < points[leftmost].y - EPSILON)) {
            leftmost = i;
        }
    }

    int p = leftmost;
    int q;

    do {
        hull.push_back(points[p]);

        q = (p + 1) % n;

        for (int i = 0; i < n; i++) {
            if (i == p || i == q) continue;
            double cp = points[p].cross_product(points[i], points[q]);
            
            if (cp > EPSILON) {
                q = i;
            } else if (std::abs(cp) < EPSILON) {
                double dot = (points[i].x - points[p].x) * (points[q].x - points[p].x) + 
                             (points[i].y - points[p].y) * (points[q].y - points[p].y);
                
                if (dot > 0 && points[p].dist_sq(points[i]) > points[p].dist_sq(points[q])) {
                    q = i;
                }
            }
        }

        p = q;

    } while (p != leftmost);

    return hull;
}

double dist_to_line(const Point& A, const Point& B, const Point& P) {
    return std::abs(A.cross_product(B, P));
}

void find_hull(const Points& points, const Point& A, const Point& B, Points& hull) {
    int farthestIdx = -1;
    double maxDist = -1.0;

    for (int i = 0; i < (int)points.size(); i++) {
        double cp = A.cross_product(B, points[i]);
        if (cp > EPSILON) {
            double dist = dist_to_line(A, B, points[i]);
            if (dist > maxDist + EPSILON) {
                maxDist = dist;
                farthestIdx = i;
            } else if (std::abs(dist - maxDist) < EPSILON) {
                if (farthestIdx != -1 && A.dist_sq(points[i]) > A.dist_sq(points[farthestIdx]))
                    farthestIdx = i;
            }
        }
    }

    if (farthestIdx == -1) {
        hull.push_back(B);
        return;
    }

    const Point& C = points[farthestIdx];

    // Only pass points strictly to the left of each new edge
    Points leftAC, leftCB;
    for (const auto& p : points) {
        if (A.cross_product(C, p) > EPSILON) leftAC.push_back(p);
        if (C.cross_product(B, p) > EPSILON) leftCB.push_back(p);
    }

    find_hull(leftAC, A, C, hull);
    find_hull(leftCB, C, B, hull);
}

Points quick_hull(Points& points) {
    int n = points.size();
    if (n < 3) return points;

    // Find extreme points. A - leftmost, B - rightmost
    int min_x = 0, max_x = 0;
    for (int i = 1; i < n; i++) {
        if (points[i].x < points[min_x].x - EPSILON || 
           (std::abs(points[i].x - points[min_x].x) < EPSILON && points[i].y < points[min_x].y - EPSILON)) {
            min_x = i;
        }
        if (points[i].x > points[max_x].x + EPSILON || 
           (std::abs(points[i].x - points[max_x].x) < EPSILON && points[i].y > points[max_x].y + EPSILON)) {
            max_x = i;
        }
    }

    Point A = points[min_x];
    Point B = points[max_x];

    Points hull;
    hull.push_back(A);

    find_hull(points, A, B, hull); 
    find_hull(points, B, A, hull); 

    if (hull.size() > 1 && hull.front() == hull.back()) {
        hull.pop_back();
    }

    return hull;
}

Point find_tangent(const Points& hull, const Point& p) {
    Point best = hull[0];
    for (std::size_t i = 1; i < hull.size(); i++) {
        double cross = p.cross_product(best, hull[i]);
        if ((cross < -EPSILON) || (std::abs(cross) <= EPSILON && p.dist_sq(hull[i]) > p.dist_sq(best))) {
            // hull[i] is to the right of cur→best: more clockwise, update or,
            // Collinear but farther: skip intermediate collinear point
            best = hull[i];
        }
    }
    return best;
}

Points chans_algorithm(Points& points) {
    int n = points.size();
    if (n < 3) return points;

    // The minimum point (bottommost, then leftmost) is always on the hull.
    const Point start = *std::min_element(points.begin(), points.end());

    for (int t = 1; t <= 30; t++) {
        int exp_val = 1 << t;
        int m;
        if (exp_val >= 30) {
            m = n;
        } else {
            long long val = 1LL << exp_val;   // 2^(2^t)
            m = (val >= static_cast<long long>(n)) ? n : static_cast<int>(val);
        }

        // Build sub-hulls
        std::vector<Points> hulls;
        hulls.reserve(static_cast<std::size_t>((n + m - 1) / m));

        for (int i = 0; i < n; i += m) {
            int end = std::min(i + m, n);
            Points group(points.begin() + i, points.begin() + end);
            hulls.push_back(graham_scan(group));
        }

        // Jarvis march (at most m steps)
        Points hull;
        hull.reserve(m);
        hull.push_back(start);
        bool closed = false;

        for (int step = 0; step < m; step++) {
            const Point& cur = hull.back();

            Point next = find_tangent(hulls[0], cur);

            for (std::size_t k = 1; k < hulls.size(); k++) {
                Point cand = find_tangent(hulls[k], cur);
                double cross = cur.cross_product(next, cand);
                if ((cross < -EPSILON) || (std::abs(cross) <= EPSILON && cur.dist_sq(cand) > cur.dist_sq(next))) {
                    // cand is more clockwise or colinear and further
                    next = cand;
                }
            }

            // Hull closes when we return to the starting point.
            if (next == start) {
                closed = true;
                break;
            }
            hull.push_back(next);
        }

        if (closed) return hull;

        if (m >= n) break;
    }

    // Fallback
    return graham_scan(points);
}
