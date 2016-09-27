[![build status](https://gitlab.com/Mizux/qtdroid/badges/master/build.svg)](https://gitlab.com/Mizux/qtdroid/commits/master)
# Qt Android CMake utility

This utility tries to provide a CMake way of doing Qt/Android compilation and deployment.  
Note: This project is "hardcoded" for Linux x86_64 host and use armv7 gnustl_static API-19
(android 4.4.2) device target (with rtti and exception enabled).

**WARNING**
Qt5.7 provide armv7 and x86 libraries currently, here only armv7 is use.
For a more complete toolchain, look at  https://github.com/taka-no-me/android-cmake

## HowTo build samples

To build for linux (i.e. host):
```
mkdir build && cd build
cmake ..
make
```

To build for android:  
First, you must make sure that the following environment variables are defined:
* ```JAVA_HOME```: root directory of the Java JDK (e.g. /usr/lib/jvm/default)
* ```ANDROID_NDK```: root directory of the Android NDK (e.g. /usr/local/android-ndk)
* ```ANDROID_SDK```: root directory of the Android SDK (e.g. /usr/local/android-sdk-linux)
* ```ANDROID_QT```: root directory of the android Qt5 framework (e.g. ~/Qt/5.4/android_armv7)

Then you can run cmake as usual:
```
mkdir build-android && cd build-android
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=../cmake/android.cmake ..
make
```

## Getting started

### HowTo integrate it to your CMake configuration

The toolchain file defines ```ANDROID``` CMake variable which can be used to add Android-specific stuff:

```cmake
if(ANDROID)
    message(STATUS "Hello from Android build!")
endif()
```

The first thing to do is to change your executable target into a library.  
On Android, the entry point has to be a Java activity, and your C++ code is then loaded (as a library) and called by this activity.

```cmake
if(ANDROID)
    add_library(my_app SHARED ...)
else()
    add_executable(my_app ...)
endif()
```

The second thing to do is to generate the apk using androiddeployqt utility provided by Qt (wrapped in a cmake macro).

```cmake
if(ANDROID)
    create_apk(my_app_apk my_app)
endif()
```

### Options of the ```create_apk``` macro

The first two arguments of the macro are the name of the APK target to be created, and the target it must be based on (your executable). These are of course mandatory.

The macro also accepts optional named arguments. Any combination of these arguments is valid, so that you can customize the generated APK according to your own needs.

Here is the full list of possible arguments:

**NAME**

The name of the application. If not given, the name of the source target is taken.  
Example:
```cmake
create_apk(my_app_apk my_app
    NAME "My App"
)
```

**PACKAGE_NAME**

The name of the application package. If not given, "org.qtproject.${source_target}" , where source_target is the name of the source target, is taken.  
Example:
```cmake
create_apk(my_app_apk my_app
    PACKAGE_NAME "net.mizux.myapp"
)
```

# License
_qtdroid_ is distributed under the terms of [GPL v3 License](http://opensource.org/licenses/GPL-3.0)
