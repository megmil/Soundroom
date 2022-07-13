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
- [x] Interacts with a database
- [x] Integrates at least one SDK or API
- [x] Ability to log in / logout as a user
- [x] Ability to sign up with a new user profile
- [ ] Uses at least one gesture
- [x] Incorporates at least one external library to add visual polish
- [ ] Uses at least one animation


## 2. Product Spec

### User Stories

#### Required Stories
- [x] Users can create rooms
- [ ] Users can join private rooms
- [ ] Users can play the room queue through the Spotify app
- [ ] Users can vote on songs
- [ ] Songs change position in the queue based on their "score"
- [x] Users can search songs
- [x] Users can add songs to the queue
- [ ] Users can view details on past sessions
- [ ] Alerts the user when the queue is empty
- [ ] Users can leave a room
- [ ] Hosts can swipe to remove a song from the queue

#### Stretch goals
- [ ] Users can save past session queues as a Spotify playlist
- [ ] Users can lock songs together
- [ ] Fill in songs when queue is empty
- [ ] Users can vote on volume
- [ ] Users can vote on queue order
- [ ] Users can mix transitions between songs

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
| **Property**   | **Type** | **Description**           |
|----------------|----------|---------------------------|
| idString       | NSString | Spotify song ID           |
| title          | NSString | track name                |
| artist         | NSString | track artist name         |
| albumTitle     | NSString | album name                |
| albumImageData | NSData   | album image data from URL |
| durationString | NSString | song length as mm:ss.     |

#### Queue Song
| **Property** | **Type**  | **Description**                      |
|--------------|-----------|--------------------------------------|
| idString     | NSString  | Spotify song ID                      |
| score        | NSInteger | sum of upvotes and downvotes         |
| requester    | User      | user who added the song to the queue |

#### Room
| **Property** | **Type**                    | **Description**                               |
|--------------|-----------------------------|-----------------------------------------------|
| host         | User                        | user who created the room                     |
| members      | NSMutableArray (Users)      | list of users who can collaborate in the room |
| currentSong  | QueueSong                   | currently playing song                        |
| queue        | NSMutableArray (QueueSongs) | list of songs to be played                    |
| playedSongs  | NSMutableArray (QueueSongs) | list of songs that have been played           |
| title        | NSString                    | name of room                                  |
| cover        | ?                           | image for room                                |

#### User
| **Property** | **Type**               | **Description**           |
|--------------|------------------------|---------------------------|
| username     | NSString               | user ID?                  |
| password     | NSString               | login info                |
| profileImage | ?                      | profile image for display |
| recentRooms  | NSMutableArray (Rooms) | list of past sessions     |
