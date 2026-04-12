#include <chrono>
#include <cstdio>
#include <fstream>
#include <functional>
#include <iostream>
#include <string>
#include <utility>
#include <vector>

#include "./data-generator.hpp"

void insertion_sort(std::vector<int> &arr) {
    for (int i = 1; i < arr.size(); i++) {
        int current_element = arr[i];

        int j = i - 1;
        for (; j >= 0 && arr[j] > current_element; j--) {
            arr[j + 1] = arr[j];
        }
        arr[j + 1] = current_element;
    }
}

void selection_sort(std::vector<int> &arr) {
    for (int i = 0; i < arr.size() - 1; ++i) {
        int min_idx = i;

        for (int j = i + 1; j < arr.size(); ++j) {
            if (arr[j] < arr[min_idx]) {
                min_idx = j; 
            }
        }

        std::swap(arr[i], arr[min_idx]);
    }
}

void bubble_sort(std::vector<int> &arr) {
    for (int i = 0; i < arr.size() - 1; i++) {
        for (int j = 0; j < arr.size() - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                std::swap(arr[j], arr[j + 1]);
            }
        }
    }
}

std::chrono::microseconds measure_time(std::function<void (std::vector<int> &arr)> sort, std::vector<int> &arr) {
    auto start = std::chrono::high_resolution_clock::now();
    sort(arr);
    auto finish = std::chrono::high_resolution_clock::now();

    return std::chrono::duration_cast<std::chrono::microseconds>(finish - start);
}

void save_data_to_csv(const std::string& filename, const std::vector<int> &data, const std::string &columnName = "Value") {
    std::ofstream file(filename);

    if (!file.is_open()) {
        std::cerr << "[ERROR] Failed to open \"" << filename << "\" file for writing.\n";
        return;
    }

    file << columnName << "\n";

    for (int value : data) {
        file << value << "\n";
    }

    file.close();
    std::cout << "Successfully saved data to \"" << filename << "\"\n";
}

int main() {
    DataGenerator data_generator{};

    //std::vector<int> test = data_generator.generate_random(100);
    //save_to_csv("test.csv", test);
}
