#include "./algorithms-part-2.hpp"

int partition(std::vector<int>& arr, int low, int high) {
    int pivot = arr[high];
    int i = low;

    for (int j = low; j < high; j++) {
        if (arr[j] < pivot) {
            std::swap(arr[i], arr[j]);
            i++;
        }
    }

    std::swap(arr[i], arr[high]);
    return i;
}

void quick_sort_helper(std::vector<int>& arr, int low, int high) {
    if (low < high) {
        int pi = partition(arr, low, high);

        quick_sort_helper(arr, low, pi - 1);
        quick_sort_helper(arr, pi + 1, high);
    }
}

void quick_sort(std::vector<int> &arr) {
    if (!arr.empty()) {
        quick_sort_helper(arr, 0, arr.size() - 1);
    }
}

void shell_sort(std::vector<int> &arr) {
    for (int gap = arr.size() / 2; gap > 0; gap /= 2) {
        for (int i = gap; i < arr.size(); i += 1) {
            int temp = arr[i];

            int j = i;
            for (; j >= gap && arr[j - gap] > temp; j -= gap) {
                arr[j] = arr[j - gap];
            }
            
            arr[j] = temp;
        }
    }
}

void heapify(std::vector<int>& arr, int size, int i) {
    int largest = i;
    int left = 2 * i + 1;
    int right = 2 * i + 2;

    if (left < size && arr[left] > arr[largest]) {
        largest = left;
    }

    if (right < size && arr[right] > arr[largest]) {
        largest = right;
    }

    if (largest != i) {
        std::swap(arr[i], arr[largest]);
        heapify(arr, size, largest);
    }
}

void heap_sort(std::vector<int> &arr) {
    int n = arr.size();

    for (int i = n / 2 - 1; i >= 0; i--) {
        heapify(arr, n, i);
    }

    for (int i = n - 1; i > 0; i--) {
        std::swap(arr[0], arr[i]);
        heapify(arr, i, 0);
    }
}
