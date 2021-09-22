#pragma once

#define WIN32_LEAN_AND_MEAN             // Exclude rarely-used stuff from Windows headers
// Windows Header Files
#include <windows.h>

#ifdef WEBREQUEST_EXPORTS
#define WEBREQUEST_API extern "C" __declspec(dllexport)
#else
#define WEBREQUEST_API __declspec(dllimport)
#endif