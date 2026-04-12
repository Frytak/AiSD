#include <random>

// Generates data for sorting algorithm test where each value is unique
class DataGenerator {
private:
    std::mt19937 gen;

public:
    DataGenerator();

    // Completely random data
    std::vector<int> generate_random(int n);

    // Sorted descending (reversed)
    std::vector<int> generate_descending(int n);

    // Sorted ascending
    std::vector<int> generate_ascending(int n);

    // ~10% neighboring elements swapped from sorted data
    std::vector<int> generate_adjacent_swaps(int n, double swapRatio = 0.1);

    // ~10% elements swapped from sorted data
    std::vector<int> generate_random_swaps(int n, double swapRatio = 0.1);
};
