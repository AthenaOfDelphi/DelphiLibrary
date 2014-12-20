# classSingleton.pas #

## Introduction ##
A singleton is a truly single instance class... i.e. every call to create will return the same instance.  Implementing them usually requires you to worry about reference counting and other stuff like that.  There are lots of example singleton classes out there, but they generally require you to add the singleton implementation code to the class you want to be a singleton.

TSingleton allows you to create singletons a plenty with no additional code, just a couple of rules you need to follow.

## Usage ##

To use this sub-classable singleton, simply include the unit 'classSingleton', derive your class from TSingleton and use your new singleton class.

The rules you must follow are that you must override 'createVars' and 'destroyVars'.

These functions are used to provide the initialisation and cleanup that might otherwise be placed in the constructor and destructor.

The ZIP file includes a simple example of it's usage.

## Compatibilty ##

This version has been tested with Delphi XE7 using Win32 and Win64 targets.  The debug routine 'singletonStoreToStrings' uses 'NativeInt' for converting pointers to hex, as such it should cope regardless of which platform it is compiled for.

## Version History ##

    Date        Version Author                 Description
    ----------- ------- ---------------------- ----------------------------------------------------------
    19-Dec-2014 1.0      C L Warne             Original release
    ----------- ------- ---------------------- ----------------------------------------------------------
