# Selfie-Booth

As a part of the interview process for Audible, Inc., I was given the following task:

>Using the Instagram API, create an iOS app that displays photos tagged with hashtag #selfie. Then implement tap to enlarge feature. Complete as much as you can within one day.


- [Dependencies](#dependencies)
- [Usage](#usage)
- [Instructions](#instructions)
- [Demo](#demo)

## Issues 

[Instagram API](http://instagram.com/developer/) is used to request data from Instagram.

I raised an [issue on Github](https://github.com/Instagram/instagram-ruby-gem/issues/140) - *Tag Endpoints: max_tag_id (data still limited to 20 images)*.

## Usage

Browse your Instagram **#selfie** photos with a double click. This was accomplished using Collection Views, Asynchronous Networking (`NSURLSession` and `Grand Central Dispatch`), and caching with on-disk persistence.

## Instructions 

1) Open *SelfieBooth.xcworkspace* in Xcode 5.1 or later.

2) Build the project Command (⌘) + R, after you choose the type of iOS Simulator.

3) Use pull-to-refresh feature to download update the photos.

4) Long press on the image to set an Instagram like.

5) Single-click (tap) on the image to see an enlarged view and repeat the same to dismiss the selfie.

## Demo
![Screenshot](http://i.imgur.com/thjWsSh.gif)
