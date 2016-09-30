#include <algorithm>
using std::sort;

#include <iostream>
using std::cin;
using std::cout;
using std::endl;

#include <vector>
using std::vector;

#include <string>
using std::string;

#include <fstream>
using std::ifstream;


int rank(int key, const vector<int>& a);

int main(int argc, char* argv[]) {
    ifstream in(argv[1]);
    vector<int> whitelist;
    string word;
    while (in >> word) {
        whitelist.push_back(stoi(word));
    }

    sort(whitelist.begin(), whitelist.end());
    int key= 0;
    while (cin >> key) {
        if (rank(key, whitelist) < 0) {
            cout << key << endl;
        }
    }
}

int rank(int key, const vector<int>& a) {
    int lo = 0;
    int hi = a.size() - 1;

    while (lo <= hi) {
        int mid = lo + (hi - lo) / 2;
        if (key < a[mid]) {
            hi = mid - 1;
        } else if (key > a[mid]) {
            lo = mid + 1;
        } else {
            return mid;
        }
    }
    return -1;
}