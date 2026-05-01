#include "./data-generator.hpp"
#include <algorithm>
#include <functional>
#include <tuple>

DataGenerator::DataGenerator() {
    std::random_device rd;
    gen = std::mt19937(rd());
}

Points DataGenerator::random(int amount, double width, double height) {
    Points points;
    points.reserve(amount);
    
    std::uniform_real_distribution<double> dist_x(-width / 2.0, width / 2.0);
    std::uniform_real_distribution<double> dist_y(-height / 2.0, height / 2.0);

    for (int i = 0; i < amount; i++) {
        points.push_back({dist_x(gen), dist_y(gen)});
    }

    return points;
}

Points DataGenerator::circle(int amount, double r) {
    Points points;
    points.reserve(amount);

    std::uniform_real_distribution<double> dist_angle(0.0, 2.0 * M_PI);

    for (int i = 0; i < amount; i++) {
        double angle = dist_angle(gen);
        points.push_back({r * std::cos(angle), r * std::sin(angle)});
    }

    return points;
}

Points DataGenerator::grid(int amount, std::uint32_t width, std::uint32_t height) {
    Points points;
    points.reserve(amount);
    
    int half_width = static_cast<int>(width) / 2;
    int half_height = static_cast<int>(height) / 2;
    
    std::uniform_int_distribution<int> dist_x(-half_width, half_width);
    std::uniform_int_distribution<int> dist_y(-half_height, half_height);

    for (int i = 0; i < amount; i++) {
        points.push_back({static_cast<double>(dist_x(gen)), static_cast<double>(dist_y(gen))});
    }

    return points;
}

Points DataGenerator::cluster(int amount, const Point& p, double ratio, double clusterRadius, double outlierRadius) {
    Points points;
    points.reserve(amount);
    
    int cluster_count = static_cast<int>(amount * ratio);
    std::uniform_real_distribution<double> dist_angle(0.0, 2.0 * M_PI);
    std::uniform_real_distribution<double> dist_radius(0.0, 1.0);

    auto generate_in_ring = [&](double min_r, double max_r) {
        double angle = dist_angle(gen);
        double min_r_sq = min_r * min_r;
        double max_r_sq = max_r * max_r;
        
        double r = std::sqrt(min_r_sq + dist_radius(gen) * (max_r_sq - min_r_sq)); 
        return Point{p.x + r * std::cos(angle), p.y + r * std::sin(angle)};
    };

    for (int i = 0; i < cluster_count; i++) {
        points.push_back(generate_in_ring(0.0, clusterRadius)); 
    }
    
    for (int i = cluster_count; i < amount; i++) {
        points.push_back(generate_in_ring(clusterRadius, outlierRadius)); 
    }

    std::shuffle(points.begin(), points.end(), gen);
    
    return points;
}

Points DataGenerator::triangle(int amount, const Point& a, const Point& b, const Point& c, double bias) {
    Points points;
    points.reserve(amount);
    
    std::uniform_real_distribution<double> dist(0.0, 1.0);

    double power = 1.0 / (1.0 - std::max(0.0, std::min(bias, 0.999)));

    for (int i = 0; i < amount; i++) {
        double w_c = std::pow(dist(gen), power);
        
        std::uniform_real_distribution<double> dist_wa(0.0, 1.0 - w_c);
        double w_a = dist_wa(gen);
        double w_b = 1.0 - w_c - w_a;

        points.push_back({
            w_a * a.x + w_b * b.x + w_c * c.x,
            w_a * a.y + w_b * b.y + w_c * c.y
        });
    }
    return points;
}
