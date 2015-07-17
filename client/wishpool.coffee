MasterConnection = DDP.connect("https://wishpool.me")

Widgets = new Mongo.Collection("widgets", MasterConnection)
Feedbacks = new Mongo.Collection("feedbacks", MasterConnection)
TokenEmails = new Mongo.Collection("token_emails", MasterConnection)

Wishpool.ownerToken = store.get("wishpoolOwnerToken")
if not Wishpool.ownerToken
  Wishpool.ownerToken = "token_" + Random.id()
  store.set("wishpoolOwnerToken", Wishpool.ownerToken)

MasterConnection.subscribe("TokenEmails", Wishpool.ownerToken)


