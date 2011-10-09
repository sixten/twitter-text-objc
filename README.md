twitter-text-objc
===========

Translation of the [twitter-text-*](http://engineering.twitter.com/2010/02/introducing-open-source-twitter-text.html) processing libraries to Objective-C for use on iOS.

There's probably a lot of very naïve code in here: writing this, I was reminded how little I like doing intensive string processing in Objective-C/Cocoa. Performance patches welcome. :-)

I've also incorporated the excellent [RegExKitLite](http://regexkit.sourceforge.net/RegexKitLite/). I am using the block-based methods introduced in version 4, so this code does require iOS 4+.

For the tests and conformance suite, please see [sixten/twitter-text-objc-tests](https://github.com/sixten/twitter-text-objc-tests).