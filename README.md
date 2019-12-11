# FlickrSearch

Sample app to play with some techniques and APIs

## Networking

For networking, I wanted to experiment with composing the networking request and reusable responses renderers. It's based on some ideas I've gotten from from SwiftBySundell, ObjC.io, and probably a few other places 

## JSON Parsing

JSON parsing is done with `Decodable`, with some custom decoding initializers.

## Feautres

* Allows for public searchs of Flickr
* Saves past searches for quick access
* Full-screen photo viewer
* Supports multiple pages of Flickr results

## Requirements
iOS 13

I wanted to try our Diffable Data Sources and the new storyboard-based view controller initialization support, so I targeted the latest system
