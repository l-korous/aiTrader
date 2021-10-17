#include "pch.h"
#include <iostream>
#include <fstream>
#include <string>
#include "HTTPRequest.hpp"

using namespace std;

string convertToString(char a[], int size)
{
  int i;
  string s = "";
  for (i = 0; i < size; i++) {
    s = s + a[i];
  }
  return s;
}

WEBREQUEST_API int a(char* json, const int size) {
  try
  {
    // you can pass http::InternetProtocol::V6 to Request to make an IPv6 request
    http::Request request{ "http://127.0.0.1:5000" };

    // send a get request
    const auto response = request.send("POST", convertToString(json, size), {
        "Content-Type: application/json"
      }
    );
    
    return std::stoi(std::string{ response.body.begin(), response.body.end() });
  }
  catch (const std::exception& e)
  {
    std::cerr << "Request failed, error: " << e.what() << '\n';
  }

  return -1;
}

int main(int argc, char* argv[]) {
  return 0;
}

BOOL APIENTRY DllMain(HMODULE hModule,
  DWORD  ul_reason_for_call,
  LPVOID lpReserved
)
{
  switch (ul_reason_for_call)
  {
  case DLL_PROCESS_ATTACH:
  case DLL_THREAD_ATTACH:
  case DLL_THREAD_DETACH:
  case DLL_PROCESS_DETACH:
    break;
  }
  return TRUE;
}