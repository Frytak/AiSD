#include <cstdlib>

#include "./data-structures.hpp"

bool operator<(const Point& lhs, const Point& rhs) {
    if (std::abs(lhs.x - rhs.x) > EPSILON) {
        return lhs.x < rhs.x;
    }
    return lhs.y < rhs.y - EPSILON; 
}

bool operator==(const Point& lhs, const Point& rhs) {
    return (std::abs(lhs.x - rhs.x) < EPSILON) && (std::abs(lhs.y - rhs.y) < EPSILON);
}

double Point::cross_product(const Point& A, const Point& B) const {
    return (A.x - this->x) * (B.y - this->y) - (A.y - this->y) * (B.x - this->x);
}

double Point::dist_sq(const Point& p) const {
    return (this->x - p.x) * (this->x - p.x) + (this->y - p.y) * (this->y - p.y);
}

