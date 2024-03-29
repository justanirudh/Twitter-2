// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token to the Socket constructor as above.
// Or, remove it from the constructor if you don't care about
// authentication.

socket.connect()

// Now that you are connected, you can join channels with a topic:
// let channel = socket.channel("topic:subtopic", {})
let channel           = socket.channel("room:lobby", {})
let chatInput         = document.querySelector("#chat-input")
let messagesContainer = document.querySelector("#messages")
let register = document.querySelector("#register")
let tweet = document.querySelector("#tweet")
let subscribe = document.querySelector("#subscribe")
let hashtag = document.querySelector("#hashtag")
let mention = document.querySelector("#mention")
let retweet = document.querySelector("#retweet")

//register
register.addEventListener("click", function(){
  channel.push("register", {}) //push to channel
})

//tweet
tweet.addEventListener("click", function(){
  channel.push("tweet", {body: chatInput.value}) //push to channel
  chatInput.value = "" //to reset it
})

//subscribe
subscribe.addEventListener("click", function(){
  channel.push("subscribe", {body: chatInput.value}) //push to channel
  chatInput.value = "" //to reset it
})

//hashtag
hashtag.addEventListener("click", function(){
  channel.push("tag", {body: chatInput.value}) //push to channel
  chatInput.value = "" //to reset it
})

//mention (same as hashtag)
mention.addEventListener("click", function(){
  channel.push("tag", {body: chatInput.value}) //push to channel
  chatInput.value = "" //to reset it
})

//retweet
retweet.addEventListener("click", function(){
  channel.push("retweet", {body: chatInput.value}) //push to channel
  chatInput.value = "" //to reset it
})

//append message coming from channel to end of msg container
channel.on("new_msg", payload => {
  let messageItem = document.createElement("li"); //create list element
  messageItem.innerText = `[${Date()}] ${payload.body}` //add date and stuff to it
  messagesContainer.appendChild(messageItem) //append at the end of list
})

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket
