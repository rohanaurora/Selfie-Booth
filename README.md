# Selfie-Booth

As a part of the interview process for Audible, Inc., an Amazon.com, Inc. subsidiary, I was given the following task -

>Using the Instagram API, create an iOS app that displays photos tagged with hashtag #selfie. Then implement tap to enlarge feature. Complete as much as you can within one day.


- [Dependencies](#dependencies)
- [Usage](#usage)
- [Instructions](#instructions)
- [Demo](#demo)

## Dependencies 

[Instagram API Endpoints](http://instagram.com/developer/) are used to easily request data from Instagram.

I raised an issue on Github - [Tag Endpoints: __max_\__tag_\__id__ (data still limited to 20 images)](https://github.com/Instagram/instagram-ruby-gem/issues/140).

## Usage

Browse your Instagram **#selfie** photos with a double click. This was accomplished using Collection Views, Asynchronous Networking (`NSURLSession` and `Grand Central Dispatch`), and caching with on-disk persistence.

## Instructions 

1) Open *SelfieBooth.xcworkspace* in Xcode 5.1 or later.

2) Build the project Command (⌘) + R, after you choose the type of iOS Simulator.

3) Single-click (tap) on the image to see an enlarged view and repeat the same to dismiss the selfie.

## Demo
![Screenshot](http://i.imgur.com/thjWsSh.gif)
