# Soundroom

## Overview

### Description
A collaborative music queue that allows users to create/join virtual music rooms where other members can request and vote on queue songs.

### Requirements
From [Project Expections](https://docs.google.com/document/d/1TvGTVGsH0b3HSVh_tRvQZDizWwBSQVCfRiS4sqMZY6Y/edit#heading=h.8l153mzbgh5r).
* Interacts with a database
* Integrates at least one SDK or API
* Ability to log in / logout as a user
* Ability to sign up with a new user profile
* Uses at least one gesture
* Incorporates at least one external library to add visual polish
* Uses at least one animation

## Product Spec

### User Stories

#### Required Stories
* Users can create rooms
* Users can join private rooms
* Users can play the room queue through the Spotify app
* Users can vote on songs
* Songs change position in the queue based on their "score"
* Users can search songs
* Users can add songs to the queue
* Users can view details on past sessions
* Alerts the user when the queue is empty
* Users can leave a room
* Hosts can swipe to remove a song from the queue

#### Stretch goals
* Users can save past session queues as a Spotify playlist
* Users can lock songs together
* Fill in songs when queue is empty
* Users can vote on volume
* Users can vote on queue order
* Users can mix transitions between songs

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


## Wireframes
<img src="https://user-images.githubusercontent.com/101139170/177431593-f5094072-df7e-4d8d-904b-70a5da8a0066.png" alt="drawing" width="650"/>


## Schema

### Models
Made with [Table Generator](https://www.tablesgenerator.com/markdown_tables).

#### Song
| **Property** | **Type** | **Description**                  |
|--------------|----------|----------------------------------|
| title        | NSString | track name                       |
| artist       | NSString | track artist name                |
| albumString  | NSString | album name                       |
| albumImage   | ?        | album image to show next to song |
| length       | ?        | song length (formatted?)         |

#### Queue Song
| **Property** | **Type**  | **Description**                      |
|--------------|-----------|--------------------------------------|
| title        | NSString  | track name                           |
| artist       | NSString  | track artist name                    |
| albumString  | NSString  | album name                           |
| albumImage   | ?         | album image to show next to song     |
| length       | ?         | song length (formatted?)             |
| score        | NSInteger | sum of upvotes and downvotes         |
| requester    | User      | user who added the song to the queue |

#### Room
| **Property** | **Type**                    | **Description**                                   |
|--------------|-----------------------------|---------------------------------------------------|
| host         | User                        | user who created the room                         |
| members      | NSMutableArray (Users)      | list of users who can collaborate in the room     |
| queue        | NSMutableArray (QueueSongs) | list of songs to be played (or currently playing) |
| playedSongs  | NSMutableArray (QueueSongs) | list of songs that have been played               |
| title        | NSString                    | name of room                                      |
| cover        | ?                           | image for room                                    |

#### User
| **Property** | **Type**               | **Description**           |
|--------------|------------------------|---------------------------|
| username     | NSString               | user ID?                  |
| password     | NSString               | login info                |
| profileImage | ?                      | profile image for display |
| recentRooms  | NSMutableArray (Rooms) | list of past sessions     |


## Project Plan

### Week 1
* Search

### Week 2

### Week 3

### Week 4

### Week 5

### Week 6
