#ifndef ALGORITHMS_HPP
#define ALGORITHMS_HPP

#include "./data-structures.hpp"

Points graham_scan(Points& points);
Points monotone_chain(Points& points);
Points jarvis_march(Points& points);
Points quick_hull(Points& points);
Points chans_algorithm(Points& points);

#endif
