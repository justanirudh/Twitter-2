# Twitter

#How to run
1. Go to root directory of the mix umbrella project
2. type 'mix phx.server'
3. Go to http://0.0.0.0:4000/ to look at the website

#Link to video
#TODO

#Overview
I have created a website with very minimal UI to demonstrate the usage of websockets in Phoenix. The backend of the UI is the Twitter engine I created in Project-4. I have also included the simulator from Project-4 but it is not being used anywhere as it is replaced by Phoenix being the new client.

#How to operate the website
You should see 6 buttons and 1 textbox in the website:

Button-1: Register
Button-2: Tweet
Button-3: Subscribe to
Button-4: Get Hashtag
Button-5: Get mention
Button-6: Retweet
TEXT-BOX

**Register**: First and foremost, click on Register button. This will assign a userid to your session. You can start another session in a different tab and click register again to start another session. You cannot do anything unless you have registered

**Tweet**: Once registered, you can start tweeting. Type something in the TEXT-BOX and click on Tweet button. This will tweet what you wrote in the textbox.

**Subscribe to**: You can subscribe to another user by:
1. Entering the userid of the user you want to subscribe to in the TEXT-BOX
2. Hit the 'Subscribe to' button
Now anytime the user you have subscribed to tweets, you will see it in your feed

**Get Hashtag**: You can get all tweets that contain a particualr hashtag by:
1. Entering teh value of the hashtag in the TEXT-BOX
2. Hit the 'Hashtag' button
All the tweets will be printed in your feed

**Get Mention**: You can get all tweets that contain a particualr hashtag by:
1. Entering the value of the hashtag in the TEXT-BOX
2. Hit the 'Hashtag' button
All the tweets will be printed in your feed

**Retweet**: You can retweet a tweet of one of the users you are subscribed to by using the tweet's id:
1. Get the tweet's id. Everytime a user tweets, all it's subscribers feeds get the tweet along with the tweet id. The id can be used to reetweet. I have included how to do this in the demo
2. Enter the tweet-id in the TEXT-BOX
3. Hit Retweet


#Implementation and Error handling

##index.html
It contains the Ui logic

##socket.js (APIs in javascript)
It contains the API logic. Phoenix takes care of serializing and deserializing the javascript objects. Hence, it is not required to be done by hand. Every button has a listener associated with it. In accordance with what button was pressed, I send the relevant information to the Channel. Except register for all the other API calls, I prepend a string that gets matched in Channel to perform appripiate action. 
For example, for tweeting, I attach a prefix of 'tweet:' to each tweet

##room_channel.ex (Client using Phoenix)
This is the primary interface between Twitter engine and client. It has methods that ping the engine. It is also pinged by the engine for sending feed information
###API endpoints
1. "register" - registering a userid
2. "tweet: [TWEET]" - tweeting by a user
3. "subscribe: [SUBSCRIBE_TO_ID]" = subscribing to a user by a user
4. "get: [# | @]" - getting all tweets that have a particular hashtag or a particular mention
5. "retweet: [TWEET_ID]" - retweeting a tweet that came in a user's feed from another user.

#modifications to the engine (Changed in engine using Phoenix)
I had to do a few modifications to the engine to work with channels
1. I added a new table that saves mapping of userid to channel-pid. This helps in efficient forwarding of feed information to subscribers of a user that just tweeted
2. Addition of a subscribers column to userid-subscribedto table for efficient retreival of subscribers for a user

##ERROR Handling and Logging
**Logging**: After every query on the webpage, I print the user specific log, along with the timestamp, on the webpage itself. It is helpful for the user to see if his/her query went through
**Error**
I have done error handling at 2 levels:
1. Channel Level
At channel level, I am handling errors that do not require querying the database such as a user being already registered, an empty tweet. More demonstration can be found in the video
2. Engine Level
I handle queries that requrie database (table) access in the engine and forward it to the Channel which then forwards it to the UI.

