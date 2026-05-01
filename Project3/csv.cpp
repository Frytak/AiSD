#include "./csv.hpp"
#include <fstream>
#include <iomanip>
#include <ios>
#include <iostream>

namespace csv {
    void save_points(std::string path, const Points& points) {
        std::ofstream file(path);

        if (!file.is_open()) {
            std::cerr << "Failed to open `" << path << "` for writing." << std::endl;
            return;
        }

        file << "X,Y\n";
        for (Point p : points) {
            file << std::fixed << std::setprecision(17) << p.x << "," << p.y << "\n";
        }
    }

    Points read_points(std::string path) {
        Points points{};
        std::ifstream file(path);

        std::string line;
        std::getline(file, line); 

        while (std::getline(file, line)) {
            std::stringstream line_stream(line);
            std::string x_str, y_str;

            if (std::getline(line_stream, x_str, ',') && std::getline(line_stream, y_str)) {
                double x = std::stod(x_str);
                double y = std::stod(y_str);

                points.push_back(Point(x, y));
            }
        }

        file.close();
        return points;
    }
};
