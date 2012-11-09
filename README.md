AIR Makefiles
=============
This is a set of Makefile includes that simplify the creation of
AIR projects (incl. ANE's) from the command line. Most goodies are
there, including:

* ANE creation from source (`make ane`)
* IPA/APK creation (`make ipa` or `make apk`)
* Mobile installation (ipa/apk) via USB (`make install`)
* Mobile launch (apk) via USB (`make run-apk`)
* Test mobile apps on the desktop (`make test`)
* Native code compilation (Objective-C, Objective-C++, Java)
* Full dependency tracking including header files
* Automatic code signing key selection
* Automatic app descriptor version generation from git

Requirements
------------
I have only tested this on OS X. Given the Xcode dependency, it's
unlikely this could run elsewhere, but I guess given the toolchain
it might work...

You'll need:
* git
* Xcode command line tools
* [Flex SDK overlaid with Air][1]
* Android SDK
* ideviceinstaller if you want to install via USB to an iDevice

Add both SDKs to your path and you're ready to go.

Usage
-----
1. Create a folder under your existing project where your build files
will reside, say `dist`

    cd my-project
    mkdir dist

2. Add the AIR Makefile project as a submodule under this folder as `mk`:

    git submodule init
    git submodule add git@github.com:jlopez/air-mk.git dist/mk
    git submodule update

3. Create a `Makefile` defining configuration information about your
AIR application (see _Variables_ below)

4. Include one of `mk/air.mk' or `mk/ane.mk` depending if you plan to
build a straight AIR application or an ANE with a test app.

5. Invoke `make`. See _Targets_ for a list of possible make targets.

Variables
---------
You should define all these variables in your `Makefile`:

### Basic
* APP_ID: Your AIR application ID
* NAME: Will be used to name your build products (NAME.ipa, NAME.apk, NAME.ane)

### Signing
* KEYDIR: A directory containing a list of companies. Each company should
  contain your keys (e.g. development.p12, distribution.p12, android.pfx, etc.)
  If not defined, will default to ../..
* COMPANY: The name of the directory under KEYDIR containing your keys.
* VERSION: Version in MAJOR.MINOR form, will be added to app descriptor

### Testflight
* TESTFLIGHT_API_TOKEN: For `make upload` target
* TESTFLIGHT_TEAM_TOKEN: For `make upload` target
* TESTFLIGHT_DLS: Distribution lists for `make upload` target

### Source
* SRCDIR: The root of your source files for your AIR project
* SRC_MAIN: The path to the main source file of your AIR project (.mxml or .as)
* APP_XML_IN: The path to your app descriptor template file
* ANES: Space separated list of paths to ANEs that your app should link to
* OTHER_RESOURCES: Other files that should be included in your ipa/apk

### ANE Source (relevant only when including mk/ane.mk)
* EXT_ID: Extension ID
* ANE_IOS_LIB_SOURCES: A list of your iOS native source files
* ANE_IOS_LIB_CFLAGS: Additional CFLAGS, usually -I<dir>, etc.
* ANE_IOS_RESOURCE_DIRS: Additional resource directories to include in the ANE
* ANE_ANDROID_JAR_SOURCES: List of android projects / jar files to compile
* ANE_ANDROID_JAR_CLASSPATH: Additional android jars to compile against
* ANDROID_SRC_SEARCH_PATHS: List of source roots, default "src"

Application Descriptor Template
-------------------------------
The APP_XML_IN file may contain macros of the form @MACRO@, where MACRO
is one of the variables above, as well as any of the generated variables
such as:

* REVISION: Current revision number, defined as the number of commits on
  the current branch since the initial commit
* COMMIT: Abbreviated hash of the current HEAD, with a '*' appended if the
  working directory is dirty.
* EXT_ID: Extension ID of ANE being built

Targets
-------
* `make swf`: Build AIR swf
* `make test`: Run AIR swf on desktop. May specify SCREEN variable to
  change iPhoneRetina default.
* `make ipa`: Build iOS .ipa file
* `make upload`: Uploads .ipa to TestFlight
* `make install`: Installs .ipa to plugged iDevice
* `make apk`: Build Android .apk file
* `make install-apk`: Installs .apk file to plugged Android device
* `make run-apk`: Launches app on plugged Android device
* `make ane`: Builds ANE file (available only when including mk/ane.mk)

Future Enhancements
-------------------
This is a laundry list of things that may or may not be done in the
future:

* Better error detection
* Better documentation
* Ensure operability under a single environment (just Android, or just iOS)

[1]: http://www.funky-monkey.nl/blog/2012/04/24/overlaying-flex-4-6-with-air-3-2-the-easy-way/ "Overlayiing Air SDK"
