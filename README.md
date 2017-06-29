# Google Test libraries builder #

Builder for libraries with [Google Test Framework](https://github.com/google/googletest) in C++.


## Overview ##

Makefile project whith building GTest libraries for linking with developed tests.


### Makefile targets ###

  * `archives`  - Builds archives (static libraries) with gtest, gmock and main function for running test program.
  * `libraries` - Builds libraries (shared libraries) with gtest, gmock and main function for running test program.
  * `includes`  - Copies googletest headers (needed for writing test cases) into `${INSTALL_PREFIX}/include/` folder.
  * `libs`      - Copies archives and libraries into `${INSTALL_PREFIX}/lib/` folder.
    * `libs-a`  - Copies only archives.
    * `libs-so` - Copies only libraries.
  * `all`       - Run `includes` and `libs` targets 
  * `clean`

##### variables for parameterization: #####

  * `INSTALL_PREFIX` - directory where include headers and libraries will be copied (default: `.`).
  * `LIB_PREFIX`     - default: `lib`
  * `AR_EXT`         - for linux default: `.a`
  * `DLL_EXT`        - for linux default: `.so`

#### Compilation products ####

  * `gtest`      - google test sources
  * `gtest_main` - google test sources with *main* function for running test program
  * `gmock`      - google test and google mock sources
  * `gmock_main` - google test and google mock sources with *main* function for running test program

There are several products (listed above) made in two types (*archives* and *libraries*).
File names are generated in following pattern: `${LIB_PREFIX}<product_name>(${AR_EXT}|${DLL_EXT})` e.q. `libgmock_main.a`.


### Usage of build libraries ###


You should compile your test source file with `${INSTALL_PREFIX}/include` in the system header search path,
and link it with gtest/gmock and any other necessary libraries:

    g++ -isystem ${INSTALL_PREFIX}/include -lgtest -L${INSTALL_PREFIX}/lib -pthread \
        -o your_test  path/to/your_test.cc

(We need `-pthread` as Google Test uses threads.)

In case when you use shared library with google test, `LD_LIBRARY_PATH` variable should be set for loader program.

    ( export LD_LIBRARY_PATH=${INSTALL_PREFIX}/lib:${LD_LIBRARY_PATH} && \
        ./your_test )
