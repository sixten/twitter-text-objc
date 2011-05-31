twitter-text-objc
===========

Translation of the [twitter-text-*](http://engineering.twitter.com/2010/02/introducing-open-source-twitter-text.html) processing libraries to Objective-C for use on iOS.

There's probably a lot of very naïve code in here: writing this, I was reminded how little I like doing intensive string processing in Objective-C/Cocoa. Performance patches welcome. :-)

I've also incorporated the excellent [RegExKitLite](http://regexkit.sourceforge.net/RegexKitLite/)—but foregone the block-based methods recently introduced—so that this code will (hopefully) be backwards-compatible with iOS 3.x.
