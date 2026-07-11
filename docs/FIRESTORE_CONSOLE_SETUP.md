# Firestore Console Setup

This is the copy/paste-friendly Firestore structure for the current NeighborHub design. Use it as the exact order when creating collections, documents, and fields in the Firebase Console.

For the current MVP, the app only targets one building. That means every document that has a `buildingId` field should use the same project-wide value, and the app should prefill that automatically when creating records.

## 1. Root Collections

Create these top-level collections only:

- `buildings`
- `users`
- `apartments`
- `apartment_requests`
- `posts`
- `post_authorship`
- `bookmarks`
- `announcements`
- `polls`
- `notifications`
- `conversations`

## 2. Build These Documents

### 2.1 `buildings/{buildingId}`

Add fields:

- `name` (string)
- `address` (string)
- `totalFloors` (number)
- `apartmentsPerFloor` (number)
- `createdAt` (timestamp)

Use the same single `buildingId` value everywhere else in the database.

### 2.2 `users/{uid}` public profile

Document ID: Firebase Auth `uid`

Add fields:

- `displayName` (string)
- `authProvider` (string)
- `photoUrl` (string or null)
- `buildingId` (string or null)
- `apartmentId` (string or null)
- `createdAt` (timestamp)

When the app creates this document, it should set `buildingId` automatically to the one project building.

### 2.3 `users/{uid}/private/account`

Subcollection: `private`

Document ID: `account`

Add fields:

- `email` (string)
- `role` (string)
- `accountStatus` (string)
- `fcmToken` (string or null)
- `createdAt` (timestamp)

### 2.4 `apartments/{apartmentId}`

Add fields:

- `buildingId` (string)
- `number` (string)
- `floor` (number)
- `description` (string or null)
- `status` (string)
- `primaryResidentUid` (string or null)
- `updatedAt` (timestamp)

Set `buildingId` automatically to the project building value.

### 2.5 `apartment_requests/{uid}`

Document ID: requester `uid`

Add fields:

- `buildingId` (string)
- `apartmentId` (string)
- `familyNote` (string or null)
- `status` (string)
- `decidedBy` (string or null)
- `createdAt` (timestamp)
- `decidedAt` (timestamp or null)

Set `buildingId` automatically to the project building value.

### 2.6 `posts/{postId}`

Document ID: auto-ID

Add fields:

- `buildingId` (string)
- `authorUid` (string or null)
- `isAnonymous` (boolean)
- `category` (string or null)
- `text` (string)
- `isPinned` (boolean)
- `isLocked` (boolean)
- `reactionCount` (number)
- `commentCount` (number)
- `bookmarkCount` (number)
- `createdAt` (timestamp)
- `updatedAt` (timestamp)

Set `buildingId` automatically to the project building value.

### 2.7 `post_authorship/{postId}`

Document ID: same as `posts/{postId}`

Add fields:

- `authorUid` (string)
- `isAnonymous` (boolean)
- `buildingId` (string)
- `createdAt` (timestamp)

Set `buildingId` automatically to the project building value.

### 2.8 `posts/{postId}/reactions/{uid}`

Document ID: reacting user `uid`

Add fields:

- `type` (string)
- `createdAt` (timestamp)

### 2.9 `posts/{postId}/comments/{commentId}`

Document ID: auto-ID

Add fields:

- `authorUid` (string)
- `text` (string)
- `createdAt` (timestamp)

### 2.10 `bookmarks/{uid_postId}`

Document ID: `${uid}_${postId}`

Add fields:

- `uid` (string)
- `postId` (string)
- `buildingId` (string)
- `createdAt` (timestamp)

Set `buildingId` automatically to the project building value.

### 2.11 `announcements/{announcementId}`

Add fields:

- `buildingId` (string)
- `title` (string)
- `body` (string)
- `createdBy` (string)
- `createdAt` (timestamp)

Set `buildingId` automatically to the project building value.

### 2.12 `polls/{pollId}`

Add fields:

- `buildingId` (string)
- `question` (string)
- `options` (array of maps)
- `status` (string)
- `createdBy` (string)
- `createdAt` (timestamp)
- `closesAt` (timestamp or null)

Set `buildingId` automatically to the project building value.

### 2.13 `polls/{pollId}/votes/{uid}`

Document ID: voter `uid`

Add fields:

- `optionId` (string)
- `createdAt` (timestamp)

### 2.14 `notifications/{notificationId}`

Add fields:

- `recipientUid` (string)
- `buildingId` (string)
- `category` (string)
- `title` (string)
- `body` (string)
- `relatedPostId` (string or null)
- `relatedConversationId` (string or null)
- `isRead` (boolean)
- `createdAt` (timestamp)

Set `buildingId` automatically to the project building value.

### 2.15 `conversations/{conversationId}`

Document ID: `${sortedUid1}_${sortedUid2}`

Add fields:

- `buildingId` (string)
- `participantUids` (array of 2 strings)
- `lastMessage` (string)
- `lastMessageAt` (timestamp)
- `createdAt` (timestamp)

Set `buildingId` automatically to the project building value.

### 2.16 `conversations/{conversationId}/messages/{messageId}`

Document ID: auto-ID

Add fields:

- `senderUid` (string)
- `text` (string)
- `createdAt` (timestamp)

## 3. Console Build Order

If you want the simplest manual sequence, create them in this order:

1. `buildings`
2. `users` with `private/account`
3. `apartments`
4. `apartment_requests`
5. `posts` and `post_authorship`
6. `reactions` and `comments`
7. `bookmarks`
8. `announcements`
9. `polls` and `votes`
10. `notifications`
11. `conversations` and `messages`

## 4. Rule File

Copy the content of [firestore.rules](../firestore.rules) into the Firestore Rules editor.
