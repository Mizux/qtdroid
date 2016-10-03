[![build status](https://gitlab.com/Mizux/qtdroid/badges/master/build.svg)](https://gitlab.com/Mizux/qtdroid/commits/master)
# Qt Android CMake utility

This utility tries to provide a CMake way example of doing Qt/Android compilation and deployment.  
Note: This project is "hardcoded" for:  
* host: Linux x86_64
* target: armv7_a
* API-19 (android 4.4.2)
* stl: gnustl_static (with rtti and exception enabled).

**WARNING**
Qt5.7 provide armv7_a and x86 libraries currently, here only armv7 is use.  
Qt **androiddeployqt** don't seems to work with bidl tools 19.1.0 -> need build-tools 24.0.3 (could work in between).  
For a more complete toolchain, look at the two year old https://github.com/taka-no-me/android-cmake  
side note: Google (Android Studio 2.2+) have integrated cmake and "taka-no-me" hack in "its" cmake 3.6 package...

# HowTo build samples
## Native/Host Build 
```
mkdir build && cd build
cmake ..
make
```

## Android Build
To build for android:  
First, you must make sure that the following environment variables are defined:
* ```JAVA_HOME```: root directory of the Java JDK (e.g. /usr/lib/jvm/default)
* ```ANDROID_HOME```: root directory of the Android SDK (e.g. /usr/local/android-sdk-linux),
 NDK should be at ```${ANDROID_HOME}/ndk-bundle``` like Android Studio did...
* ```ANDROID_QT```: root directory of the android Qt5 framework (e.g. ~/Qt/5.4/android_armv7)

Then you can run cmake as usual specifying the toolchain:
```
mkdir build-android && cd build-android
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=../cmake/android.cmake ..
make
```

# Getting started
## HowTo integrate it to your CMake configuration

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

## Options of the ```create_apk``` macro

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
