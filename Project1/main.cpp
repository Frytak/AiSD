#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstddef>
#include <cstdio>
#include <ctime>
#include <fstream>
#include <functional>
#include <iomanip>
#include <random>

#define GEN_CSV

class NumericalIntegrator {
public:
    virtual ~NumericalIntegrator() = default;
    virtual long double integrate(const std::function<long double(long double)>& func, long double a, long double b) = 0;
};

enum RectangleMethodType {
    LEFT,
    CENTER,
    RIGHT,
};

class RectangleMethod : public NumericalIntegrator {
private:
    std::size_t subdivisions;

public:
    RectangleMethodType type;

    RectangleMethod(RectangleMethodType type, std::size_t subdivisions) : type(type), subdivisions(std::max(static_cast<std::size_t>(1), subdivisions)) {}

    std::size_t get_subdivisions() const { return this->subdivisions; }
    void set_subdivisions(std::size_t subdivisions) { this->subdivisions = std::max(static_cast<std::size_t>(1), subdivisions); }

    long double integrate(const std::function<long double (long double)> &func, long double a, long double b) override {
        long double total_area = 0;
        long double width = (b - a) / this->subdivisions;

#ifdef GEN_CSV
        std::ofstream csv_file("rectangle.csv");
        csv_file << width << "\n";
#endif

        for (size_t i = 0; i < this->subdivisions; i++) {
            long double x = a + (i * width);
            switch (this->type) {
                case LEFT:
                    break;
                case CENTER:
                    x += (width * 0.5);
                    break;
                case RIGHT:
                    x += width;
                    break;
            }

#ifdef GEN_CSV
            csv_file << func(x) << "\n";
#endif

            long double area = func(x) * width;
            total_area += area;
        }

#ifdef GEN_CSV
            csv_file.close();
#endif
        return total_area;
    }
};

class TrapezoidalMethod : public NumericalIntegrator {
private:
    std::size_t subdivisions;

public:
    TrapezoidalMethod(std::size_t subdivisions) : subdivisions(std::max(static_cast<std::size_t>(1), subdivisions)) {}

    std::size_t get_subdivisions() const { return this->subdivisions; }
    void set_subdivisions(std::size_t subdivisions) { this->subdivisions = std::max(static_cast<std::size_t>(1), subdivisions); }

    long double integrate(const std::function<long double (long double)> &func, long double a, long double b) override {
        long double total_area = 0;
        long double width = (b - a) / this->subdivisions;

#ifdef GEN_CSV
        std::ofstream csv_file("trapezoid.csv");
        csv_file << width << ",0" << "\n";
#endif

        for (size_t i = 0; i < this->subdivisions; i++) {
            long double x1 = a + (i * width);
            long double x2 = a + ((i + 1) * width);

#ifdef GEN_CSV
            csv_file << func(x1) << "," << func(x2) << "\n";
#endif

            long double area = ((func(x1) + func(x2)) / 2.) * width;
            total_area += area;
        }

#ifdef GEN_CSV
            csv_file.close();
#endif
        return total_area;
    }
};

class MonteCarloMethod : public NumericalIntegrator {
private:
    std::size_t samples;
    long double resolution = 0.001;
    std::mt19937 gen{std::random_device{}()};
    std::uniform_real_distribution<long double> rand{0., 1.};

public:
    MonteCarloMethod(std::size_t samples) : samples(std::max(static_cast<std::size_t>(1), samples)) {};

    std::size_t get_samples() const { return this->samples; }
    void set_samples(std::size_t samples) { this->samples = std::max(static_cast<std::size_t>(1), samples); }

    long double get_resolution() const { return this->resolution; }
    void set_resolution(long double resolution) { this->resolution = std::max(static_cast<long double>(0.00000000001), std::abs(resolution)); }

    long double integrate(const std::function<long double (long double)> &func, long double a, long double b) override {
        long double max_y = 0.0;
        long double min_y = 0.0;
        
        int probe_count = static_cast<int>((b - a) / resolution); 
        long double step = (b - a) / probe_count;

        for (int i = 0; i <= probe_count; ++i) {
            long double x = a + i * step;
            long double y = func(x);
            if (y > max_y) max_y = y;
            if (y < min_y) min_y = y;
        }

        if (max_y > 0) max_y *= 1.05;
        if (min_y < 0) min_y *= 1.05;
        
        if (max_y == 0.0 && min_y == 0.0) { max_y = 1.0; min_y = -1.0; }

#ifdef GEN_CSV
        std::ofstream csv_file("monte-carlo.csv");
        csv_file << min_y << "," << max_y << ",0" << "\n";
#endif

        long long positive_hits = 0;
        long long negative_hits = 0;

        for (size_t i = 0; i < this->samples; ++i) {
            long double x = a + ((b - a) * rand(gen));
            long double y = min_y + ((max_y - min_y) * rand(gen));

            long double fx = func(x);

#ifdef GEN_CSV
            csv_file << x << "," << y << ",";
#endif
            if (fx > 0 && y > 0 && y <= fx) {
                positive_hits++;
#ifdef GEN_CSV
                csv_file << 1 << "\n";
#endif
            }
            else if (fx < 0 && y < 0 && y >= fx) {
                negative_hits++;
#ifdef GEN_CSV
                csv_file << -1 << "\n";
            } else {
                csv_file << 0 << "\n";
#endif
            }
        }

#ifdef GEN_CSV
            csv_file.close();
#endif
        long double box_area = (b - a) * (max_y - min_y);
        return box_area * (static_cast<long double>(positive_hits - negative_hits) / this->samples);
    }
};

long double f(long double x) { return (-std::pow(x, 2)) + (4.*x) + 1.; }
long double f_integrated(long double x) { return ((-1./3.) * std::pow(x, 3)) + (2. * std::pow(x, 2)) + x; }

long double g(long double x) { return (x * std::sin(20. * x)); }
long double g_integrated(long double x) { return ((-x/20.) * std::cos(20. * x)) + ((1./400.) * std::sin(20. * x)); }

void error_margin_test() {
    int magnitude = 8;

    long double f_0integrated3 = f_integrated(3) - f_integrated(0);
    long double g_0integrated1u5 = g_integrated(1.5) - g_integrated(0);

    //{
    //    RectangleMethod rectangle_left_method(LEFT, 10);
    //    std::ofstream csv_file("f-rectangle-left-error-margin.csv");
    //    for (int i = 1; i <= magnitude; i++) {
    //        std::printf("Magnitude %d (%lu subdivisions) for Rectangle Left Method\n", i, rectangle_left_method.get_subdivisions());
    //        long double result = rectangle_left_method.integrate(f, 0, 3);
    //        long double error_margin = std::abs(result - f_0integrated3);

    //        csv_file << std::fixed << std::setprecision(18) << i << "," << result << "," << error_margin << "\n";
    //        rectangle_left_method.set_subdivisions(rectangle_left_method.get_subdivisions() * 10);
    //    }
    //    csv_file.close();
    //}

    //{
    //    RectangleMethod rectangle_center_method(CENTER, 10);
    //    std::ofstream csv_file("f-rectangle-center-error-margin.csv");
    //    for (int i = 1; i <= magnitude; i++) {
    //        std::printf("Magnitude %d (%lu subdivisions) for Rectangle Center Method\n", i, rectangle_center_method.get_subdivisions());
    //        long double result = rectangle_center_method.integrate(f, 0, 3);
    //        long double error_margin = std::abs(result - f_0integrated3);

    //        csv_file << std::fixed << std::setprecision(18) << i << "," << result << "," << error_margin << "\n";
    //        rectangle_center_method.set_subdivisions(rectangle_center_method.get_subdivisions() * 10);
    //    }
    //    csv_file.close();
    //}

    //{
    //    RectangleMethod rectangle_right_method(RIGHT, 10);
    //    std::ofstream csv_file("f-rectangle-right-error-margin.csv");
    //    for (int i = 1; i <= magnitude; i++) {
    //        std::printf("Magnitude %d (%lu subdivisions) for Rectangle Right Method\n", i, rectangle_right_method.get_subdivisions());
    //        long double result = rectangle_right_method.integrate(f, 0, 3);
    //        long double error_margin = std::abs(result - f_0integrated3);

    //        csv_file << std::fixed << std::setprecision(18) << i << "," << result << "," << error_margin << "\n";
    //        rectangle_right_method.set_subdivisions(rectangle_right_method.get_subdivisions() * 10);
    //    }
    //    csv_file.close();
    //}

    //{
    //    TrapezoidalMethod trapezoidal_method(10);
    //    std::ofstream csv_file("f-trapezoid-error-margin.csv");
    //    for (int i = 1; i <= magnitude; i++) {
    //        std::printf("Magnitude %d (%lu subdivisions) for Trapezoidal Method\n", i, trapezoidal_method.get_subdivisions());
    //        long double result = trapezoidal_method.integrate(f, 0, 3);
    //        long double error_margin = std::abs(result - f_0integrated3);

    //        csv_file << std::fixed << std::setprecision(18) << i << "," << result << "," << error_margin << "\n";
    //        trapezoidal_method.set_subdivisions(trapezoidal_method.get_subdivisions() * 10);
    //    }
    //    csv_file.close();
    //}

    //{
    //    MonteCarloMethod monte_carlo_method(10);
    //    std::ofstream csv_file("f-monte-carlo-error-margin.csv");
    //    for (int i = 1; i <= magnitude; i++) {
    //        std::printf("Magnitude %d (%lu samples) for Monte Carlo Method\n", i, monte_carlo_method.get_samples());
    //        for (int j = 0; j < 10; j++) {
    //            long double result = monte_carlo_method.integrate(f, 0, 3);
    //            long double error_margin = std::abs(result - f_0integrated3);

    //            csv_file << std::fixed << std::setprecision(18) << i << "," << j << "," << result << "," << error_margin << "\n";
    //        }
    //        monte_carlo_method.set_samples(monte_carlo_method.get_samples() * 10);
    //    }
    //    csv_file.close();
    //}





    //{
    //    RectangleMethod rectangle_left_method(LEFT, 10);
    //    std::ofstream csv_file("g-rectangle-left-error-margin.csv");
    //    for (int i = 1; i <= magnitude; i++) {
    //        std::printf("Magnitude %d (%lu subdivisions) for Rectangle Left Method\n", i, rectangle_left_method.get_subdivisions());
    //        long double result = rectangle_left_method.integrate(g, 0, 1.5);
    //        long double error_margin = std::abs(result - g_0integrated1u5);

    //        csv_file << std::fixed << std::setprecision(18) << i << "," << result << "," << error_margin << "\n";
    //        rectangle_left_method.set_subdivisions(rectangle_left_method.get_subdivisions() * 10);
    //    }
    //    csv_file.close();
    //}

    //{
    //    RectangleMethod rectangle_center_method(CENTER, 10);
    //    std::ofstream csv_file("g-rectangle-center-error-margin.csv");
    //    for (int i = 1; i <= magnitude; i++) {
    //        std::printf("Magnitude %d (%lu subdivisions) for Rectangle Center Method\n", i, rectangle_center_method.get_subdivisions());
    //        long double result = rectangle_center_method.integrate(g, 0, 1.5);
    //        long double error_margin = std::abs(result - g_0integrated1u5);

    //        csv_file << std::fixed << std::setprecision(18) << i << "," << result << "," << error_margin << "\n";
    //        rectangle_center_method.set_subdivisions(rectangle_center_method.get_subdivisions() * 10);
    //    }
    //    csv_file.close();
    //}

    //{
    //    RectangleMethod rectangle_right_method(RIGHT, 10);
    //    std::ofstream csv_file("g-rectangle-right-error-margin.csv");
    //    for (int i = 1; i <= magnitude; i++) {
    //        std::printf("Magnitude %d (%lu subdivisions) for Rectangle Right Method\n", i, rectangle_right_method.get_subdivisions());
    //        long double result = rectangle_right_method.integrate(g, 0, 1.5);
    //        long double error_margin = std::abs(result - g_0integrated1u5);

    //        csv_file << std::fixed << std::setprecision(18) << i << "," << result << "," << error_margin << "\n";
    //        rectangle_right_method.set_subdivisions(rectangle_right_method.get_subdivisions() * 10);
    //    }
    //    csv_file.close();
    //}

    //{
    //    TrapezoidalMethod trapezoidal_method(10);
    //    std::ofstream csv_file("g-trapezoid-error-margin.csv");
    //    for (int i = 1; i <= magnitude; i++) {
    //        std::printf("Magnitude %d (%lu subdivisions) for Trapezoidal Method\n", i, trapezoidal_method.get_subdivisions());
    //        long double result = trapezoidal_method.integrate(g, 0, 1.5);
    //        long double error_margin = std::abs(result - g_0integrated1u5);

    //        csv_file << std::fixed << std::setprecision(18) << i << "," << result << "," << error_margin << "\n";
    //        trapezoidal_method.set_subdivisions(trapezoidal_method.get_subdivisions() * 10);
    //    }
    //    csv_file.close();
    //}

    //{
    //    MonteCarloMethod monte_carlo_method(10);
    //    std::ofstream csv_file("g-monte-carlo-error-margin.csv");
    //    for (int i = 1; i <= magnitude; i++) {
    //        std::printf("Magnitude %d (%lu samples) for Monte Carlo Method\n", i, monte_carlo_method.get_samples());
    //        for (int j = 0; j < 10; j++) {
    //            long double result = monte_carlo_method.integrate(g, 0, 1.5);
    //            long double error_margin = std::abs(result - g_0integrated1u5);

    //            csv_file << std::fixed << std::setprecision(18) << i << "," << j << "," << result << "," << error_margin << "\n";
    //        }
    //        monte_carlo_method.set_samples(monte_carlo_method.get_samples() * 10);
    //    }
    //    csv_file.close();
    //}
}

void approaching_value_test() {
    int magnitude = 10000;

    long double f_0integrated3 = f_integrated(3) - f_integrated(0);
    long double g_0integrated1u5 = g_integrated(1.5) - g_integrated(0);

    //{
    //    RectangleMethod rectangle_left_method(LEFT, 10);
    //    std::ofstream csv_file("approaching-value/f-rectangle-left.csv");
    //    for (; rectangle_left_method.get_subdivisions() <= magnitude; rectangle_left_method.set_subdivisions(rectangle_left_method.get_subdivisions() + 10)) {
    //        std::printf("%lu subdivisions for Rectangle Left Method\n", rectangle_left_method.get_subdivisions());
    //        long double result = rectangle_left_method.integrate(f, 0, 3);
    //        long double error_margin = std::abs(result - f_0integrated3);

    //        csv_file << std::fixed << std::setprecision(18) << rectangle_left_method.get_subdivisions() << "," << result << "," << error_margin << "\n";
    //    }
    //    csv_file.close();
    //}

    //{
    //    RectangleMethod rectangle_center_method(CENTER, 10);
    //    std::ofstream csv_file("approaching-value/f-rectangle-center.csv");
    //    for (; rectangle_center_method.get_subdivisions() <= magnitude; rectangle_center_method.set_subdivisions(rectangle_center_method.get_subdivisions() + 10)) {
    //        std::printf("%lu subdivisions for Rectangle Center Method\n", rectangle_center_method.get_subdivisions());
    //        long double result = rectangle_center_method.integrate(f, 0, 3);
    //        long double error_margin = std::abs(result - f_0integrated3);

    //        csv_file << std::fixed << std::setprecision(18) << rectangle_center_method.get_subdivisions() << "," << result << "," << error_margin << "\n";
    //    }
    //    csv_file.close();
    //}

    //{
    //    RectangleMethod rectangle_right_method(RIGHT, 10);
    //    std::ofstream csv_file("approaching-value/f-rectangle-right.csv");
    //    for (; rectangle_right_method.get_subdivisions() <= magnitude; rectangle_right_method.set_subdivisions(rectangle_right_method.get_subdivisions() + 10)) {
    //        std::printf("%lu subdivisions for Rectangle Right Method\n", rectangle_right_method.get_subdivisions());
    //        long double result = rectangle_right_method.integrate(f, 0, 3);
    //        long double error_margin = std::abs(result - f_0integrated3);

    //        csv_file << std::fixed << std::setprecision(18) << rectangle_right_method.get_subdivisions() << "," << result << "," << error_margin << "\n";
    //    }
    //    csv_file.close();
    //}

    //{
    //    TrapezoidalMethod trapezoidal_method(10);
    //    std::ofstream csv_file("approaching-value/f-trapezoid.csv");
    //    for (; trapezoidal_method.get_subdivisions() <= magnitude; trapezoidal_method.set_subdivisions(trapezoidal_method.get_subdivisions() + 10)) {
    //        std::printf("%lu subdivisions for Trapezoidal Method\n", trapezoidal_method.get_subdivisions());
    //        long double result = trapezoidal_method.integrate(f, 0, 3);
    //        long double error_margin = std::abs(result - f_0integrated3);

    //        csv_file << std::fixed << std::setprecision(18) << trapezoidal_method.get_subdivisions() << "," << result << "," << error_margin << "\n";
    //    }
    //    csv_file.close();
    //}

    //{
    //    MonteCarloMethod monte_carlo_method(10);
    //    std::ofstream csv_file("approaching-value/f-monte-carlo.csv");
    //    for (; monte_carlo_method.get_samples() <= magnitude; monte_carlo_method.set_samples(monte_carlo_method.get_samples() + 10)) {
    //        std::printf("%lu samples for Monte Carlo Method\n", monte_carlo_method.get_samples());
    //        for (int j = 0; j < 10; j++) {
    //            long double result = monte_carlo_method.integrate(f, 0, 3);
    //            long double error_margin = std::abs(result - f_0integrated3);

    //            csv_file << std::fixed << std::setprecision(18) << monte_carlo_method.get_samples() << "," << j << "," << result << "," << error_margin << "\n";
    //        }
    //    }
    //    csv_file.close();
    //}





    {
        RectangleMethod rectangle_left_method(LEFT, 10);
        std::ofstream csv_file("approaching-value/g-rectangle-left.csv");
        for (; rectangle_left_method.get_subdivisions() <= magnitude; rectangle_left_method.set_subdivisions(rectangle_left_method.get_subdivisions() + 10)) {
            std::printf("%lu subdivisions for Rectangle Left Method\n", rectangle_left_method.get_subdivisions());
            long double result = rectangle_left_method.integrate(g, 0, 1.5);
            long double error_margin = std::abs(result - g_0integrated1u5);

            csv_file << std::fixed << std::setprecision(18) << rectangle_left_method.get_subdivisions() << "," << result << "," << error_margin << "\n";
        }
        csv_file.close();
    }

    {
        RectangleMethod rectangle_center_method(CENTER, 10);
        std::ofstream csv_file("approaching-value/g-rectangle-center.csv");
        for (; rectangle_center_method.get_subdivisions() <= magnitude; rectangle_center_method.set_subdivisions(rectangle_center_method.get_subdivisions() + 10)) {
            std::printf("%lu subdivisions for Rectangle Center Method\n", rectangle_center_method.get_subdivisions());
            long double result = rectangle_center_method.integrate(g, 0, 1.5);
            long double error_margin = std::abs(result - g_0integrated1u5);

            csv_file << std::fixed << std::setprecision(18) << rectangle_center_method.get_subdivisions() << "," << result << "," << error_margin << "\n";
        }
        csv_file.close();
    }

    {
        RectangleMethod rectangle_right_method(RIGHT, 10);
        std::ofstream csv_file("approaching-value/g-rectangle-right.csv");
        for (; rectangle_right_method.get_subdivisions() <= magnitude; rectangle_right_method.set_subdivisions(rectangle_right_method.get_subdivisions() + 10)) {
            std::printf("%lu subdivisions for Rectangle Right Method\n", rectangle_right_method.get_subdivisions());
            long double result = rectangle_right_method.integrate(g, 0, 1.5);
            long double error_margin = std::abs(result - g_0integrated1u5);

            csv_file << std::fixed << std::setprecision(18) << rectangle_right_method.get_subdivisions() << "," << result << "," << error_margin << "\n";
        }
        csv_file.close();
    }

    {
        TrapezoidalMethod trapezoidal_method(10);
        std::ofstream csv_file("approaching-value/g-trapezoid.csv");
        for (; trapezoidal_method.get_subdivisions() <= magnitude; trapezoidal_method.set_subdivisions(trapezoidal_method.get_subdivisions() + 10)) {
            std::printf("%lu subdivisions for Trapezoidal Method\n", trapezoidal_method.get_subdivisions());
            long double result = trapezoidal_method.integrate(g, 0, 1.5);
            long double error_margin = std::abs(result - g_0integrated1u5);

            csv_file << std::fixed << std::setprecision(18) << trapezoidal_method.get_subdivisions() << "," << result << "," << error_margin << "\n";
        }
        csv_file.close();
    }

    {
        MonteCarloMethod monte_carlo_method(10);
        std::ofstream csv_file("approaching-value/g-monte-carlo.csv");
        for (; monte_carlo_method.get_samples() <= magnitude; monte_carlo_method.set_samples(monte_carlo_method.get_samples() + 10)) {
            std::printf("%lu samples for Monte Carlo Method\n", monte_carlo_method.get_samples());
            for (int j = 0; j < 10; j++) {
                long double result = monte_carlo_method.integrate(g, 0, 1.5);
                long double error_margin = std::abs(result - g_0integrated1u5);

                csv_file << std::fixed << std::setprecision(18) << monte_carlo_method.get_samples() << "," << j << "," << result << "," << error_margin << "\n";
            }
        }
        csv_file.close();
    }
}

void time_test() {
    int repeats = 10;
    int magnitude = 8;

    long double f_0integrated3 = f_integrated(3) - f_integrated(0);
    long double g_0integrated1u5 = g_integrated(1.5) - g_integrated(0);

    //{
    //    RectangleMethod rectangle_left_method(LEFT, 10);
    //    std::ofstream csv_file("execution-time/f-rectangle-left.csv");
    //    for (int i = 1; i <= magnitude; i++) {
    //        for (int j = 0; j < repeats; j++) {
    //            std::printf("Magnitude %d (%lu subdivisions, %d repeat) for Rectangle Left Method\n", i, rectangle_left_method.get_subdivisions(), j);

    //            auto start = std::chrono::high_resolution_clock::now();
    //            rectangle_left_method.integrate(f, 0, 3);
    //            auto finish = std::chrono::high_resolution_clock::now();
    //            auto duration = std::chrono::duration_cast<std::chrono::microseconds>(finish - start);

    //            csv_file << std::fixed << std::setprecision(18) << i << "," << j << "," << duration.count() << "\n";
    //        }

    //        rectangle_left_method.set_subdivisions(rectangle_left_method.get_subdivisions() * 10);
    //    }
    //    csv_file.close();
    //}

    {
        RectangleMethod rectangle_center_method(CENTER, 10);
        std::ofstream csv_file("execution-time/f-rectangle-center.csv");
        for (int i = 1; i <= magnitude; i++) {
            for (int j = 0; j < repeats; j++) {
                std::printf("Magnitude %d (%lu subdivisions, %d repeat) for Rectangle Center Method\n", i, rectangle_center_method.get_subdivisions(), j);

                auto start = std::chrono::high_resolution_clock::now();
                rectangle_center_method.integrate(f, 0, 3);
                auto finish = std::chrono::high_resolution_clock::now();
                auto duration = std::chrono::duration_cast<std::chrono::microseconds>(finish - start);

                csv_file << std::fixed << std::setprecision(18) << i << "," << j << "," << duration.count() << "\n";
            }

            rectangle_center_method.set_subdivisions(rectangle_center_method.get_subdivisions() * 10);
        }
        csv_file.close();
    }

    {
        RectangleMethod rectangle_right_method(RIGHT, 10);
        std::ofstream csv_file("execution-time/f-rectangle-right.csv");
        for (int i = 1; i <= magnitude; i++) {
            for (int j = 0; j < repeats; j++) {
                std::printf("Magnitude %d (%lu subdivisions, %d repeat) for Rectangle Right Method\n", i, rectangle_right_method.get_subdivisions(), j);

                auto start = std::chrono::high_resolution_clock::now();
                rectangle_right_method.integrate(f, 0, 3);
                auto finish = std::chrono::high_resolution_clock::now();
                auto duration = std::chrono::duration_cast<std::chrono::microseconds>(finish - start);

                csv_file << std::fixed << std::setprecision(18) << i << "," << j << "," << duration.count() << "\n";
            }

            rectangle_right_method.set_subdivisions(rectangle_right_method.get_subdivisions() * 10);
        }
        csv_file.close();
    }

    {
        TrapezoidalMethod trapezoidal_method(10);
        std::ofstream csv_file("execution-time/f-trapezoid.csv");
        for (int i = 1; i <= magnitude; i++) {
            for (int j = 0; j < repeats; j++) {
                std::printf("Magnitude %d (%lu subdivisions, %d repeat) for Trapezoidal Method\n", i, trapezoidal_method.get_subdivisions(), j);

                auto start = std::chrono::high_resolution_clock::now();
                trapezoidal_method.integrate(f, 0, 3);
                auto finish = std::chrono::high_resolution_clock::now();
                auto duration = std::chrono::duration_cast<std::chrono::microseconds>(finish - start);

                csv_file << std::fixed << std::setprecision(18) << i << "," << j << "," << duration.count() << "\n";
            }

            trapezoidal_method.set_subdivisions(trapezoidal_method.get_subdivisions() * 10);
        }
        csv_file.close();
    }

    {
        MonteCarloMethod monte_carlo_method(10);
        std::ofstream csv_file("execution-time/f-monte-carlo.csv");
        for (int i = 1; i <= magnitude; i++) {
            for (int j = 0; j < repeats; j++) {
                std::printf("Magnitude %d (%lu samples, %d repeat) for Monte Carlo Method\n", i, monte_carlo_method.get_samples(), j);

                auto start = std::chrono::high_resolution_clock::now();
                monte_carlo_method.integrate(f, 0, 3);
                auto finish = std::chrono::high_resolution_clock::now();
                auto duration = std::chrono::duration_cast<std::chrono::microseconds>(finish - start);

                csv_file << std::fixed << std::setprecision(18) << i << "," << j << "," << duration.count() << "\n";
            }

            monte_carlo_method.set_samples(monte_carlo_method.get_samples() * 10);
        }
        csv_file.close();
    }
}

int main() {
    RectangleMethod rectangle_method(RIGHT, 40);
    TrapezoidalMethod trapezoidal_method(40);
    MonteCarloMethod monte_carlo_method(800);

    std::printf("\x1b[1m\x1b[34m=== Integracja analityczna ===\x1b[0m\n");
    std::printf("Funkcja `f` od 0 do 3: %Lf\n", f_integrated(3) - f_integrated(0));
    std::printf("Funkcja `g` od 0 do 1.5: %Lf\n", g_integrated(1.5) - g_integrated(0));
    std::printf("\n");

    //error_margin_test();
    //approaching_value_test();
    //time_test();

    //std::printf("\x1b[1m\x1b[34m=== Integracja metodą kwadratów ===\x1b[0m\n");
    //std::printf("Funkcja `f` od 0 do 3: %Lf\n", rectangle_method.integrate(f, 0, 3));
    //std::printf("Funkcja `g` od 0 do 1.5: %Lf\n", rectangle_method.integrate(g, 0, 1.5));
    //std::printf("\n");

    //std::printf("\x1b[1m\x1b[34m=== Integracja metodą trapezów ===\x1b[0m\n");
    //std::printf("Funkcja `f` od 0 do 3: %Lf\n", trapezoidal_method.integrate(f, 0, 3));
    //std::printf("Funkcja `g` od 0 do 1.5: %Lf\n", trapezoidal_method.integrate(g, 0, 1.5));
    //std::printf("\n");

    //std::printf("\x1b[1m\x1b[34m=== Integracja metodą Monte Carlo ===\x1b[0m\n");
    //std::printf("Funkcja `f` od 0 do 3: %Lf\n", monte_carlo_method.integrate(f, 0, 3));
    std::printf("Funkcja `g` od 0 do 1.5: %Lf\n", monte_carlo_method.integrate(g, 0, 1.5));
}
