# Twitter

#How to run
1. Go to root directory of the mix umbrella project
2. type 'mix phx.server'
3. Go to http://0.0.0.0:4000/ to look at the website

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
1. Entering teh value of the hashtag in the TEXT-BOX
2. Hit the 'Hashtag' button
All the tweets will be printed in your feed

**Retweet**: You can retweet a tweet of one of the users you are subscribed to by using the tweet's id:
1. Get the tweet's id. Everytime a user tweets, all it's subscribers feeds get the tweet along with the tweet id. The id can be used to reetweet. I have included how to do this in the demo
2. Enter the tweet-id in the TEXT-BOX
3. Hit Retweet


#Implementation 
##index.html
It contains the 