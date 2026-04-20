#include "./algorithms-part-1.hpp"

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
    for (int i = 0; i < arr.size() - 1; i++) {
        int min_idx = i;

        for (int j = i + 1; j < arr.size(); j++) {
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
