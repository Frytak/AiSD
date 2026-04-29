#include "./algorithms-part-3.hpp"
#include <algorithm>
#include <random>

void stooge_sort_helper(std::vector<int> &arr, int l, int r) {
    if (arr[l] > arr[r]) {
        std::swap(arr[l], arr[r]);
    }

    if (r - l + 1 > 2) {
        int t = (r - l + 1) / 3;
        stooge_sort_helper(arr, l, r - t);
        stooge_sort_helper(arr, l + t, r);
        stooge_sort_helper(arr, l, r - t);
    }
}

void stooge_sort(std::vector<int> &arr) {
    stooge_sort_helper(arr, 0, arr.size()-1);
}

void remove_half(std::vector<int>& arr) {
    std::mt19937 rng(std::random_device{}());
    
    std::vector<size_t> indices(arr.size());
    std::iota(indices.begin(), indices.end(), 0);
    std::shuffle(indices.begin(), indices.end(), rng);
    indices.resize(arr.size() / 2);
    
    std::sort(indices.begin(), indices.end(), std::greater<size_t>());
    for (size_t i : indices) {
        arr.erase(arr.begin() + i);
    }
}

void thanos_sort(std::vector<int> &arr) {
    while (!std::is_sorted(arr.begin(), arr.end())) {
        remove_half(arr);
    }
}

void stalin_sort(std::vector<int> &arr) {
    int max_so_far = arr[0];
    for (size_t i = 1; i < arr.size(); i++) {
        if (arr[i] >= max_so_far) {
            max_so_far = arr[i];
        } else {
            arr.erase(arr.begin() + i);
            i--;
        }
    }
}
