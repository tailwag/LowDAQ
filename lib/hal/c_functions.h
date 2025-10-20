#include <Arduino.h>
#include <SD.h>

struct FileList {
    char ** names;   // array of strings
    uint16_t count;  // number of files
};

FileList * ls(const char * dirname);