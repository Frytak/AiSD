#include <chrono>
#include <cmath>
#include <cstdio>
#include <filesystem>
#include <fstream>
#include <functional>
#include <iostream>
#include <ostream>
#include <string>
#include <string_view>
#include <utility>
#include <vector>
#include <format>

#include "./data-generator.hpp"
#include "./algorithms-part-1.hpp"
#include "./algorithms-part-2.hpp"


std::chrono::nanoseconds measure_time(std::function<void (std::vector<int> &arr)> sort, std::vector<int> &arr) {
    auto start = std::chrono::high_resolution_clock::now();
    sort(arr);
    auto finish = std::chrono::high_resolution_clock::now();

    return std::chrono::duration_cast<std::chrono::nanoseconds>(finish - start);
}

void save_data_to_csv(const std::string &filename, const std::vector<int> &data, const std::string &columnName = "Value") {
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
    //std::cout << "Successfully saved data to \"" << filename << "\"\n";
}

void generate_and_save_data_to_csv(const std::string &name, std::function<std::vector<int> (int size)> generator, int size) {
    std::cout << "\t" << name << " - " << std::flush;
    std::string filename = std::format("./data/{}/{}.csv", name, size);
    std::ofstream file(filename);

    if (!file.is_open()) {
        std::cerr << "[ERROR] Failed to open \"" << filename << "\" file for writing.\n";
        std::cout << "\x1b[31mfailed\x1b[0m" << std::endl;
        return;
    }

    file << "Value\n";
    for (int value : generator(size)) {
        file << value << "\n";
    }
    file.close();

    std::cout << "\x1b[32mdone\x1b[0m" << std::endl;
}

std::vector<int> read_data_from_csv(const std::string &name, int size) {
    std::vector<int> data;
    std::string filename = std::format("./data/{}/{}.csv", name, size);
    std::ifstream file(filename);

    if (!file.is_open()) {
        std::cerr << "[ERROR] Failed to open \"" << filename << "\" file for reading.\n";
        return data;
    }

    std::string dummy_header;
    std::getline(file, dummy_header);

    data.reserve(size);

    int value;
    while (file >> value) {
        data.push_back(value);
    }

    return data;
}

void test_and_save_results_to_csv(const std::string &data_name, const std::string &sort_name, std::function<void (std::vector<int> &)> sort, int size) {
    std::cout << "\t" << data_name << " - " << std::flush;

    std::string results_filename = std::format("./results/{}/{}/{}.csv", data_name, sort_name, size);
    std::ofstream results_file(results_filename);

    std::filesystem::path pathObj(results_filename);
    std::filesystem::path dir = pathObj.parent_path();
    if (!dir.empty() && !std::filesystem::exists(dir)) {
        std::filesystem::create_directories(dir);
    }

    if (!results_file.is_open()) {
        std::cerr << "[ERROR] Failed to open \"" << results_filename << "\" file for writing.\n";
        std::cout << "\x1b[31mfailed\x1b[0m" << std::endl;
        return;
    }

    auto data = read_data_from_csv(data_name, size);
    if (data.empty()) {
        std::cout << "\x1b[31mfailed\x1b[0m" << std::endl;
        return;
    }

    results_file << "Size,Take,Duration\n";
    for (int take = -10; take < 10; take++) {
        auto arr = data;
        auto duration = measure_time(sort, arr);
        results_file << size << "," << take << "," << duration << "\n";
    }
    results_file.close();

    std::cout << "\x1b[32mdone\x1b[0m" << std::endl;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        std::cout << "Missing a command:\n"
                  << "\t- generate\n"
                  << "\t- test\n"
                  << std::endl;
    }

    int start_magnitude = 1;
    int end_magnitude = 8;
    int sub[3] = { 1, 2, 5 };

    std::string_view command = std::string_view(argv[1]);

    if (argc > 2) {
        std::string_view start_magnitued_arg(argv[2]);
        auto result = std::from_chars(start_magnitued_arg.data(), start_magnitued_arg.data() + start_magnitued_arg.size(), start_magnitude);

        std::string_view end_magnitued_arg(argv[3]);
        result = std::from_chars(end_magnitued_arg.data(), end_magnitued_arg.data() + end_magnitued_arg.size(), end_magnitude);
    }

    if (command == "generate") {
        DataGenerator data_generator{};

        for (int magnitude = start_magnitude; magnitude <= end_magnitude; magnitude++) {
            std::cout << "\x1b[1m\x1b[34m=== Generating data for magnitude " << magnitude << " ===\x1b[0m" << std::endl;

            for (int j : sub) {
                int size = std::pow(10, magnitude) * j;
                std::cout << "\x1b[1mSize: " << size << "\x1b[0m" << std::endl;

                generate_and_save_data_to_csv("random", [&data_generator](int s) { return data_generator.generate_random(s); }, size);
                generate_and_save_data_to_csv("descending", [&data_generator](int s) { return data_generator.generate_descending(s); }, size);
                generate_and_save_data_to_csv("ascending", [&data_generator](int s) { return data_generator.generate_ascending(s); }, size);
                generate_and_save_data_to_csv("adjacent-swaps", [&data_generator](int s) { return data_generator.generate_adjacent_swaps(s); }, size);
                generate_and_save_data_to_csv("random-swaps", [&data_generator](int s) { return data_generator.generate_random_swaps(s); }, size);
            }

            std::cout << std::endl;
        }
    } else if (command == "test") {
        std::vector<std::pair<std::string, std::function<void (std::vector<int> &)>>> sorts = {
            std::pair("insertion-sort", &insertion_sort),
            std::pair("selection-sort", &selection_sort),
            std::pair("bubble-sort", &bubble_sort),
            std::pair("quick-sort", &quick_sort),
            std::pair("shell-sort", &shell_sort),
            std::pair("heap-sort", &heap_sort),
        };

        std::vector<std::string> data_sets = {
            "random",
            "descending",
            "ascending",
            "adjacent-swaps",
            "random-swaps",
        };

        if (argc > 4) {
            std::string_view sort_arg(argv[4]);
            if (sort_arg != "all") {
                std::erase_if(sorts, [sort_arg](std::pair<std::string, std::function<void (std::vector<int> &)>> sort) { 
                    return sort.first != sort_arg; 
                });
            }

            std::string_view data_set_arg(argv[5]);
            if (data_set_arg != "all") {
                std::erase_if(data_sets, [data_set_arg](std::string data_set) { 
                    return data_set != data_set_arg; 
                });
            }
        }

        for (int magnitude = start_magnitude; magnitude <= end_magnitude; magnitude++) {
            std::cout << "\x1b[1m\x1b[34m=== Testing time for magnitude " << magnitude << " ===\x1b[0m" << std::endl;

            for (int j : sub) {
                int size = std::pow(10, magnitude) * j;
                std::cout << "\x1b[33m\x1b[1m=== Size: " << size << " ===\x1b[0m" << std::endl;

                for (std::pair<std::string, std::function<void (std::vector<int> &)>> sort : sorts) {
                    std::cout << "\x1b[1mSort: " << sort.first << "\x1b[0m" << std::endl;
                    for (std::string data_set : data_sets) {
                        test_and_save_results_to_csv(data_set, sort.first, sort.second, size);
                    }
                }
            }
        }
    } else {
        std::cout << "Unknown command" << std::endl;
    }
}
