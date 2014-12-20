AthenaOfDelphi's Library
==

This repository contains the parts of my Delphi library that I am making publicly available.

It is offered under the MPL (Version 2.0), details of which can be found in LICENSE.

## Structure ##

My initial commits were based on organising the library into different sections, grouping the files together by subject area (e.g. game development).  However, this makes for a painful check out process if you want to use multiple files.  I have restructured the library and separated the files by content type.

- **Source** - Contains the source files for the library itself
- **Documentation** - Contains the documentation provided for the library where available.  The files are named to correspond with the source file they relate to
- **Examples** - Contains example projects that illustrate the usage of the library.  The sub-directories are named to correspond with the source file they relate to

## Library Content ##

The library contains the following files:-

- **classSingleton.pas** - A sub-classable singleton that allows easy, no hassle creation of singleton classes
- **unitGenericBinaryTree.pas** - An implementation of a binary tree class using generics to remove the need for lots of typecasting in the client code
- **unitXInput.pas** - An XInput interface for Delphi that allows you to use game pads supported by XInput in your Delphi code 

## Compatability ##

The library has been tested with Delphi XE7 (in most cases only with Win32 and Win64 targets).  However, many of the items it contains began life on early versions, many on Delphi 2009.  If have a specific target and experience difficulties, please report an issue and I will attempt to resolve it.

## Support ##

I'm a full time software engineer who is busy studying for a degree.  Couple that with the fact I have a few personal software projects on the go, and I don't have a lot of time to provide support so, like my WordPress plug-ins, it's offered on a 'when I can' basis.

If you would like to report an issue with the code I provide here, then please do so using the Github issue tracker.  If you require urgent assistance then you may email me at **athena at outer hyphen reaches dot com**.

When reporting issues, please provide as much information as you can.

## Copyright and Trademarks

Unless otherwise stated, all content is Copyright (c) Christina Louise Warne (aka. AthenaOfDelphi).

All trademarks are the property of their respective owners.

## Disclaimer ##

The source code provided here is done so 'as is'.  I provide no warranty (implied or otherwise) that it is fit for a particular purpose.  I am not responsible for any costs or damages incurred as a result of the direct or in-direct use of the code provided here.  You use it at your own risk.