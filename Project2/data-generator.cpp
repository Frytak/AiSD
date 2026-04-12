#include "./data-generator.hpp"

#include <algorithm>

DataGenerator::DataGenerator() {
    std::random_device rd;
    gen = std::mt19937(rd());
}

std::vector<int> DataGenerator::generate_random(int n) {
    std::vector<int> data(n);
    std::iota(data.begin(), data.end(), 1);
    std::shuffle(data.begin(), data.end(), gen);
    return data;
}

std::vector<int> DataGenerator::generate_descending(int n) {
    std::vector<int> data(n);
    std::iota(data.rbegin(), data.rend(), 1);
    return data;
}

std::vector<int> DataGenerator::generate_ascending(int n) {
    std::vector<int> data(n);
    std::iota(data.begin(), data.end(), 1);
    return data;
}

std::vector<int> DataGenerator::generate_adjacent_swaps(int n, double swapRatio) {
    std::vector<int> data = generate_ascending(n);

    int numSwaps = static_cast<int>(n * swapRatio);
    if (n < 2) return data;

    std::uniform_int_distribution<> dist(0, n - 2);
    for (int i = 0; i < numSwaps; ++i) {
        int idx = dist(gen);
        std::swap(data[idx], data[idx + 1]);
    }
    return data;
}

std::vector<int> DataGenerator::generate_random_swaps(int n, double swapRatio) {
    std::vector<int> data = generate_ascending(n);
    
    int numSwaps = static_cast<int>((n * swapRatio) / 2.0);
    if (n < 2 || numSwaps < 1) return data;

    std::uniform_int_distribution<> dist(0, n - 1);
    for (int i = 0; i < numSwaps; ++i) {
        int idx1 = dist(gen);
        int idx2 = dist(gen);
        
        while (idx1 == idx2) {
            idx2 = dist(gen);
        }
        
        std::swap(data[idx1], data[idx2]);
    }

    return data;
}
