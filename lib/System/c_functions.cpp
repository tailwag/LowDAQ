#include <c_functions.h>

FileList * ls(const char * dirname) {
    File dir = SD.open(dirname);

    if (!dir || !dir.isDirectory())
        return nullptr;

    // temporary dynamic array
    std::vector<String> temp;

    File entry; 

    while((entry = dir.openNextFile())) {
        if (!entry.isDirectory())
            temp.push_back(String(entry.name()));
        
        entry.close();
    }
    dir.close();

    // allocate result structure
    FileList * result = new FileList;
    result->count = temp.size();
    result->names = new char * [result->count]; 

    for (uint16_t i = 0; i < result->count; i++) {
        // allocate and copy each filename
        uint16_t pushStrLen = temp[i].length() + 1;
        result->names[i] = new char[pushStrLen];
        strcpy(result->names[i], temp[i].c_str());
    }

    return result;
}