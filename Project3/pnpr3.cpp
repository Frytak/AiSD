#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <fstream>
#include <functional>
#include <iostream>
#include <ostream>
#include <string>

#include "./data-generator.hpp"
#include "./algorithms.hpp"
#include "./csv.hpp"
#include "./args.hxx"
#include "data-structures.hpp"

std::chrono::nanoseconds measure_time(std::function<void ()> func) {
    auto start = std::chrono::high_resolution_clock::now();
    func();
    auto finish = std::chrono::high_resolution_clock::now();

    return std::chrono::duration_cast<std::chrono::nanoseconds>(finish - start);
}

args::Group arguments("Argumenty:", args::Group::Validators::DontCare, args::Options::Global);
args::ValueFlag<int> start_magnitude(arguments, "start_magnitude", "Początkowa potęga dziesiątki", {'s', "start_magnitude"}, 1);
args::ValueFlag<int> end_magnitude(arguments, "end_magnitude", "Końcowa potęga dziesiątki", {'e', "end_magnitude"}, 4);
args::ValueFlagList<int> sub_steps(arguments, "sub_steps", "Pod przedziały ilości punktów dla potęg dziesiątki", {'p', "sub_steps"}, {1, 2, 5});
args::ValueFlagList<std::string> scenarios(arguments, "scenarios", "Scenariusze danych", {'d', "scenarios"}, {"random", "circle", "grid", "cluster", "triangle"});
args::HelpFlag help(arguments, "help", "Wyświetl pomoc", {'h', "help"});

void GenerateCommand(args::Subparser &parser) {
    parser.Parse();

    std::sort(sub_steps->begin(), sub_steps->end());
    sub_steps->erase(std::unique(sub_steps->begin(), sub_steps->end()), sub_steps->end());
    scenarios->erase(std::unique(scenarios->begin(), scenarios->end()), scenarios->end());

    DataGenerator data_generator{};

    for (auto &&magnitude = start_magnitude.Get(); magnitude <= end_magnitude.Get(); magnitude++) {
        std::cout << "\x1b[1m\x1b[34m=== Generowanie danych dla " << magnitude << " potęgi 10 ===\x1b[0m" << std::endl;
        for (auto &&sub_step : sub_steps) {
            int amount = std::pow(10, magnitude) * sub_step;
            std::cout << "\x1b[1m\x1b[33mIlość punktów: " << amount << "\x1b[0m" << std::endl;

            for (auto &&scenario : scenarios) {
                std::cout << "\x1b[1mScenariusz: " << scenario << "\x1b[0m" << std::endl;

                Points points;
                if (scenario == "random") {
                    points = data_generator.random(amount);
                } else if (scenario == "circle") {
                    points = data_generator.circle(amount);
                } else if (scenario == "grid") {
                    points = data_generator.grid(amount);
                } else if (scenario == "cluster") {
                    points = data_generator.cluster(amount);
                } else if (scenario == "triangle") {
                    points = data_generator.triangle(amount);
                } else {
                    std::cout << "Scenariusz `" << scenario << "` nie jest zaimplementowany." << std::endl;
                    continue;
                }

                csv::save_points(std::format("./data/{}/{}.csv", scenario, amount), points);
            }
        }
    }
}

void TestCommand(args::Subparser &parser) {
    args::ValueFlagList<std::string> algorithms(parser, "algorithms", "Algorytmy do testowania", {'a', "algorithms"}, {"graham-scan", "monotone-chain", "jarvis-march", "quick-hull", "chans-algorithm"});
    parser.Parse();

    algorithms->erase(std::unique(algorithms->begin(), algorithms->end()), algorithms->end());

    for (auto &&magnitude = start_magnitude.Get(); magnitude <= end_magnitude.Get(); magnitude++) {
        std::cout << "\x1b[1m\x1b[34m=== Testowanie dla " << magnitude << " potęgi 10 ===\x1b[0m" << std::endl;
        for (auto &&sub_step : sub_steps) {
            int amount = std::pow(10, magnitude) * sub_step;
            std::cout << "\x1b[1m\x1b[33mIlość punktów: " << amount << "\x1b[0m" << std::endl;

            for (auto &&scenario : scenarios) {
                std::cout << "\x1b[1mScenariusz: " << scenario << "\x1b[0m" << std::endl;
                Points points = csv::read_points(std::format("./data/{}/{}.csv", scenario, amount));
                
                for (auto &&algorithm : algorithms) {
                    std::cout << "\t" << algorithm << " - " << std::flush;

                    std::function<void (Points& points)> algorithm_func;
                    if (algorithm == "graham-scan") {
                        algorithm_func = [](Points& points) { graham_scan(points); };
                    } else if (algorithm == "monotone-chain") {
                        algorithm_func = [](Points& points) { monotone_chain(points); };
                    } else if (algorithm == "jarvis-march") {
                        algorithm_func = [](Points& points) { jarvis_march(points); };
                    } else if (algorithm == "quick-hull") {
                        algorithm_func = [](Points& points) { quick_hull(points); };
                    } else if (algorithm == "chans-algorithm") {
                        algorithm_func = [](Points& points) { chans_algorithm(points); };
                    } else {
                        std::cout << "Algorytm `" << algorithm << "` nie jest zaimplementowany." << std::endl;
                        continue;
                    }

                    std::ofstream file(std::format("./results/{}/{}/{}.csv", algorithm, scenario, amount));
                    file << "Take,Duration(ns)" << std::endl;

                    for (int take = -10; take < 100; take++) {
                        Points points_copy = points;
                        std::chrono::nanoseconds duration = measure_time([&]() { algorithm_func(points_copy); });
                        file << take << "," << duration.count() << std::endl;
                    }

                    file.close();
                    std::cout << "\x1b[32mdone\x1b[0m" << std::endl;
                }
            }
        }
    }
}

void print_points(const Points& points) {
    std::cout << "[";
    for (int i = 0; i < points.size() - 1; i++) {
        std::cout << "(" << points[i].x << ", " << points[i].y << "), ";
    }
    std::cout << "(" << points[points.size()-1].x << ", " << points[points.size()-1].y << ")]";
}

int main(int argc, char *argv[]) {
    args::ArgumentParser parser("Generator danych testowych i tester algorytmów Convex Hull");

    args::Group commands(parser, "Komendy:");
    args::Command generate(commands, "generate", "Generuje dane do testów", &GenerateCommand);
    args::Command test(commands, "test", "Testuje algorytmy na wygenerowanych danych", &TestCommand);

    args::GlobalOptions globals(parser, arguments);

    try {
        parser.ParseCLI(argc, argv);
    } catch (const args::Help&) {
        std::cout << parser;
        return 0;
    } catch (args::Error& e) {
        std::cerr << e.what() << std::endl << parser;
        return 1;
    }

    return 0;
}
