#ifndef DATA_GENERATOR_HPP
#define DATA_GENERATOR_HPP

#include "./data-structures.hpp"
#include <cstdint>
#include <random>

// Generates data for convex hull algorithms tests
class DataGenerator {
private:
    std::mt19937 gen;

public:
    DataGenerator();

    // Random points uniformly distributed inside a rectangle
    Points random(int amount, double width = 1, double height = 1);

    // Random points on the circumference of a circle
    Points circle(int amount, double r = 1);

    // Random points uniformly distributed on a grid with integer coordinates
    Points grid(int amount, std::uint32_t width = 100, std::uint32_t height = 100);

    // Heavily clustered points around point P.
    // ratio: fraction of points inside the cluster (e.g., 0.9 for 90%).
    // clusterRadius: max distance for clustered points.
    // outlierRadius: max distance for the remaining % of points.
    Points cluster(int amount, const Point& p = Point(0, 0), double ratio = 0.9, double clusterRadius = 1.0, double outlierRadius = 100.0);

    // Random points in the shape of a triangle defined by vertices A, B, C.
    // Points are intentionally packed denser near the edge A-B.
    // bias (0.0 to 1.0): controls how strongly points are attracted to the A-B edge (higher = closer to edge).
    Points triangle(int amount, const Point& a = Point(0, 0), const Point& b = Point(50, 100), const Point& c = Point(100, 50), double bias = 0.9);
};

#endif
