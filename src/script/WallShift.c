
#define _WIN32_WINNT 0x0602
#define NTDDI_VERSION 0x06020000

#include <windows.h>
#include <shobjidl.h>
#include <shellapi.h>

int WINAPI wWinMain(
    HINSTANCE instance,
    HINSTANCE previous,
    PWSTR commandLine,
    int show
) {
    int argc = 0;
    LPWSTR *argv = CommandLineToArgvW(
        GetCommandLineW(), &argc
    );

    if (!argv)
        return 1;

    if (argc != 2) {
        LocalFree(argv);
        return 2;
    }

    WCHAR path[MAX_PATH];

    DWORD length = GetFullPathNameW(
        argv[1], MAX_PATH, path, NULL
    );

    LocalFree(argv);

    if (length == 0 || length >= MAX_PATH)
        return 3;

    DWORD attrs = GetFileAttributesW(path);

    if (attrs == INVALID_FILE_ATTRIBUTES ||
        (attrs & FILE_ATTRIBUTE_DIRECTORY))
        return 4;

    HRESULT hr = CoInitializeEx(
        NULL, COINIT_APARTMENTTHREADED
    );

    if (FAILED(hr))
        return 5;

    IDesktopWallpaper *desktop = NULL;

    hr = CoCreateInstance(
        &CLSID_DesktopWallpaper,
        NULL,
        CLSCTX_ALL,
        &IID_IDesktopWallpaper,
        (void **)&desktop
    );

    if (FAILED(hr)) {
        CoUninitialize();
        return 6;
    }

    hr = desktop->lpVtbl->SetWallpaper(
        desktop,
        NULL,
        path
    );

    desktop->lpVtbl->Release(desktop);
    CoUninitialize();

    return SUCCEEDED(hr) ? 0 : 7;
}
