# Soundroom

## Table of Contents
1. [Overview](#overview)
2. [Product Spec](#product-spec)
3. [Project Plan](#project-plan)
4. [Schema](#schema)

## 1. Overview

### Description
A collaborative music queue where users can create/join virtual music rooms to request and vote on songs.

### Requirements
From [Project Expections](https://docs.google.com/document/d/1TvGTVGsH0b3HSVh_tRvQZDizWwBSQVCfRiS4sqMZY6Y/edit#heading=h.8l153mzbgh5r).
- [x] Interacts with a database (Parse/Back4App)
- [x] Integrates at least one SDK or API (Spotify iOS SDK, Spotify Web API, Deezer API, MusicKit)
- [x] Ability to log in / logout as a user
- [x] Ability to sign up with a new user profile
- [x] Uses at least one gesture (tap to dismiss keyboards, swipe to remove song from queue)
- [x] Incorporates at least one external library to add visual polish (SkyFloatingLabelTextField)
- [x] Uses at least one animation (vote button animations, loading cell shimmer, add button animation, reload table with animation, insert/delete/move cell with animation)


## 2. Product Spec

### User Stories

#### Required Stories
- Users can create rooms
- Users can join private rooms
- Users can play the room queue through the Spotify app
- Users can vote on songs
- Songs change position in the queue based on their "score"
- Users can search songs
- Users can add songs to the queue
- Users can leave a room
- Hosts can swipe to remove a song from the queue

#### Stretch goals
- Users can participate in a room without connecting to Spotify or Apple Music
- Users can swap out Spotify, MusicKit, and Deezer to search tracks and load track data
- Users can swap out Spotify and Apple Music to play the queue
- Hosts can create rooms in party mode (i.e. only the host plays music) or remote mode (i.e. all members play music)
- Search bar throttles search requests to reduce the number of API calls
- Animate queue for individual changes (e.g. song moves up/down, song is deleted, song is inserted)
- Show animated shimmer layer over empty track/user views while data is loading

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


## 3. Project Plan

### Wireframes
<img width="650" alt="wireframe" src="https://user-images.githubusercontent.com/101139170/177431593-f5094072-df7e-4d8d-904b-70a5da8a0066.png">

### Gantt Chart
<img width="760" alt="gantt" src="https://user-images.githubusercontent.com/101139170/177448765-d558fb32-1be6-43d9-a352-cfb01e51b752.png">


## 4. Schema

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
