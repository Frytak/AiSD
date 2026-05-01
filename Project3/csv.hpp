#ifndef CSV_HPP
#define CSV_HPP

#include <string>
#include "./data-structures.hpp"

namespace csv {
    void save_points(std::string path, const Points& points);
    Points read_points(std::string path);
}

#endif
