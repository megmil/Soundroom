# Soundroom

## Table of Contents
1. [Overview](#overview)
2. [Product Spec](#product-spec)
3. [Project Plan](#project-plan)
4. [Schema](#schema)

## Overview

### Description
A collaborative music queue where users can create and join virtual music rooms to request and vote on songs. Users can participate in a room without connecting to a music streaming account, or they can optionally link their Spotify account to control playback through the Soundroom app. Allows two room listening modes: Party Mode, where only the host's device plays the queue; and Remote Mode, where all devices play the queue.

### Technical Challenges
- Live implementation: Parse LiveQuery subscribes to 5 queries (invitations for current user, current room, song requests in current room, upvotes in current room, downvotes in current room) to respond to real-time updates from multiple users
- Search bar: throttle search requests to reduce the number of API calls and allow typeahead
- Allow multiple music players / catalogs: swap out Spotify for Apple Music (for search/get API calls and playback) or use Deezer to search/get tracks without connecting to a music streaming service
- Custom animations: tap resize animation, vote button bounce, loading cell shimmer layer, queue insert/delete/move row animations

### Databases, SDKs, APIs, and libraries incorporated
- Parse and Parse Live Query + Back4App
- Spotify iOS SDK
- MusicKit
- Spotify Web API
- Deezer API
- Apple Music API
- SkyFloatingLabelTextField


## Product Spec

### User Stories

#### Required Stories
- Users can register / login / logout as a user
- Users can create rooms

<img src="https://user-images.githubusercontent.com/101139170/184420868-bc6e1163-925e-4fb8-981e-5821ff053371.gif" width=20% height=20%>

- Users can join private rooms

<img src="https://user-images.githubusercontent.com/101139170/184419037-b8bada2f-09d3-4fe4-b6d0-5e4246856f5b.gif" width=20% height=20%> <img src="https://user-images.githubusercontent.com/101139170/184418889-3e872a38-e8af-429d-9ca9-5ab7604e4826.gif" width=20% height=20%>

- Users can control playback through the Spotify app

<img src="https://user-images.githubusercontent.com/101139170/184420012-48c0c5ef-2837-4dea-9515-53ad349608cb.gif" width=30% height=30%> <img src="https://user-images.githubusercontent.com/101139170/184420036-5dc1c5ca-af2e-4675-8ece-b5dd710e003a.gif" width=30% height=30%>

<img src="https://user-images.githubusercontent.com/101139170/184420425-ff6e9172-619a-45f0-b402-dd9a1a313767.gif" width=30% height=30%> <img src="https://user-images.githubusercontent.com/101139170/184420433-32efb213-aad2-4c00-b0bf-4ab5fd397bc6.gif" width=30% height=30%>

- Users can vote on songs

<img src="https://user-images.githubusercontent.com/101139170/184419681-251c6f4a-fcf6-4779-a11f-cfa3db263b18.gif" width=30% height=30%> <img src="https://user-images.githubusercontent.com/101139170/184419699-ca324faf-fbf7-4f5a-87bd-623edc97d487.gif" width=30% height=30%> <img src="https://user-images.githubusercontent.com/101139170/184419690-8c49bcd6-f47c-45c1-b5b4-92f30dc16aeb.gif" width=30% height=30%>

- Songs change position in the queue based on their "score"

<img src="https://user-images.githubusercontent.com/101139170/184419951-2cd9ee36-c492-4ae0-b901-ca11d488dd16.gif" width=30% height=30%>

- Users can search songs

<img src="https://user-images.githubusercontent.com/101139170/184417817-050f4c55-aed1-4686-8f3c-2c462158e317.gif" width=20% height=20%> <img src="https://user-images.githubusercontent.com/101139170/184418309-bc541ab1-f473-4db1-91d3-2cc2b56263b4.gif" width=20% height=20%>

- Users can add songs to the queue

<img src="https://user-images.githubusercontent.com/101139170/184419244-b19546e9-7833-4579-981f-ad6431c84180.gif" width=20% height=20%> <img src="https://user-images.githubusercontent.com/101139170/184419190-eb4e6f00-6ca5-4a70-a133-7deff8839b1d.gif" width=20% height=20%>

- Users can leave a room

<img src="https://user-images.githubusercontent.com/101139170/184421036-e0db9ec6-0af2-4d31-a3e4-5cd1b144f9e7.gif" width=20% height=20%>

- Hosts can swipe to remove a song from the queue

<img src="https://user-images.githubusercontent.com/101139170/184419901-86b465bb-a4e7-49e5-9cc2-d0ce0044de74.gif" width=30% height=30%>


#### Stretch goals
- Search bar throttles search requests to reduce the number of API calls
- Users can participate in a room without connecting to Spotify or Apple Music
- Users can swap out Spotify, MusicKit, and Deezer to search tracks and load track data
- Users can swap out Spotify and Apple Music to play the queue
- Hosts can create rooms in party mode (i.e. only the host plays music) or remote mode (i.e. all members play music)
- Animate queue for individual changes (e.g. song moves up/down, song is deleted, song is inserted)
- Animate button taps
- Shimmer animation covers empty track/user views while data is loading


### Screen Archetypes
* Login
  * Create account or login
* Profile
  * See recent rooms
  * Connect to Spotify through Settings
* Room
  * Start a new room
  * Join a room
  * Vote on songs
* Search
  * Search songs
  * Add songs to the queue


## Project Plan

### Wireframes
<img alt="wireframe" src="https://user-images.githubusercontent.com/101139170/177431593-f5094072-df7e-4d8d-904b-70a5da8a0066.png" width=40% height=40%>

### Gantt Chart
<img alt="gantt" src="https://user-images.githubusercontent.com/101139170/177448765-d558fb32-1be6-43d9-a352-cfb01e51b752.png" width=60% height=60%>


## Schema

### Models
Made with [Table Generator](https://www.tablesgenerator.com/markdown_tables).

#### Song
| **Property** | **Type** | **Description**                      |
|--------------|----------|--------------------------------------|
| track        | Track    | track information from music catalog |
| requestId    | String   | Request objectId                     |
| userId       | String   | requester PFUser userId              |
| isrc         | String   | standard code for track              |

#### Track
| **Property**  | **Type** | **Description**                         |
|---------------|----------|-----------------------------------------|
| deezerId      | String   | deezer identifier                       |
| isrc          | String   | standard code for track                 |
| streamingId   | String   | spotify URI or MusicKit ID              |
| title         | String   | song name                               |
| artist        | String   | artist name (or formatted artists name) |
| albumImageURL | URL      | album cover image URL                   |

#### Request
| **Property** | **Type** | **Description**                                                               |
|--------------|----------|-------------------------------------------------------------------------------|
| objectId     | String   | PFObject objectId for request                                                 |
| roomId       | String   | PFObject objectId for the requester's current room when this request was made |
| userId       | String   | PFUser userId for the requester                                               |
| isrc         | String   | standard song code for the requested track                                    |

#### Room
| **Property**  | **Type** | **Description**                                |
|---------------|----------|------------------------------------------------|
| roomId        | String   | PFObject objectId                              |
| hostId        | String   | PFUser userId of user that created this room   |
| currentISRC   | String   | standard song code for currently playing track |
| title         | String   | room name                                      |
| listeningMode | Integer  | remote or party mode                           |

#### Upvote
| **Property** | **Type** | **Description**                                          |
|--------------|----------|----------------------------------------------------------|
| objectId     | String   | PFObject objectId for upvote                             |
| requestId    | String   | PFObject objectId for the request the upvote was made on |
| roomId       | String   | PFObject objectId for the room the upvote is in          |
| userId       | String   | PFUser userId for the upvoter                            |

#### Downvote
| **Property** | **Type** | **Description**                                            |
|--------------|----------|------------------------------------------------------------|
| objectId     | String   | PFObject objectId for downvote                             |
| requestId    | String   | PFObject objectId for the request the downvote was made on |
| roomId       | String   | PFObject objectId for the room the downvote is in          |
| userId       | String   | PFUser userId for the downvoter                            |

#### Invitation
| **Property** | **Type** | **Description**                                               |
|--------------|----------|---------------------------------------------------------------|
| objectId     | String   | PFObject objectId for invitation                              |
| roomId       | String   | PFObject objectId for the room the invitation is to           |
| userId       | String   | PFUser userId for the user the invitation is to               |
| isPending    | Boolean  | indicates whether or not the user has accepted the invitation |

#### PFUser
| **Property**    | **Type** | **Description**                                       |
|-----------------|----------|-------------------------------------------------------|
| userId          | String   | PFUser userId                                         |
| username        | String   | username for login                                    |
| password        | String   | password for login                                    |
| avatarImageType | Integer  | random value that corresponds to 1 of 5 avatar images |
