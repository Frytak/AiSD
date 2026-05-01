#ifndef DATA_STRUCTURES_HPP
#define DATA_STRUCTURES_HPP

#include <vector>

const double EPSILON = 1e-12;

struct Point {
    double x;
    double y;

    friend bool operator<(const Point& lhs, const Point& rhs);

    friend bool operator==(const Point& lhs, const Point& rhs);

    // > 0 (left turn)
    // < 0 (right turn)
    // 0 (colinear)
    double cross_product(const Point& A, const Point& B) const;

    // Squared distance
    double dist_sq(const Point& p) const;
};

typedef std::vector<Point> Points;

#endif
