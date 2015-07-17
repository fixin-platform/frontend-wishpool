Template.wishpool.helpers
  widget: ->
    Widgets.findOne(@widgetId)

Template.wishpool.onCreated ->
  data = @data
  widgetId = data.widgetId
  data.subscriptionHandle = null
  @autorun ->
    data.subscriptionHandle = MasterConnection.subscribe("widgetById", widgetId)

Template.wishpool.onRendered ->

Template.wishpool.events
  'keydown input': (event, template) ->
    template.$(".placeholder .text").addClass("hidden")
  'keyup input': (event, template) ->
    feedback = template.$(".wishpool-input").val()
    defaultFeedback = Widgets.findOne(template.data.widgetId).label + " "
    if feedback isnt defaultFeedback
      template.$(".placeholder .text").addClass("hidden")
    else
      template.$(".placeholder .text").removeClass("hidden")
  'submit form.widget-form': grab encapsulate (event, template) ->
    actualText = template.$(".wishpool-input").val()
    defaultText = Widgets.findOne(template.data.widgetId).label + " "
    if actualText is defaultText or actualText is ""
      return # simple validation

#    trying to find out if user left his email
    sourceUrl = "https://widget.wishpool.me/" + template.data.widgetId + "?"
    userEmail = ""
    parentUrl = location.protocol + "//" + location.hostname + (if location.port then ':' + location.port else '') + Iron.Location.get().path
    if Foreach.currentUserReady()
      currentUser = Foreach.currentUser()
      userEmail = currentUser.emails[0].address
      sourceUrl += "userName=" + encodeURIComponent(currentUser.profile.name)
      sourceUrl += "&userEmail=" + encodeURIComponent(userEmail)
      sourceUrl += "&userAvatarUrl=" + encodeURIComponent(currentUser.profile.image)
      sourceUrl += "&userIsPaying=false&userId=" + encodeURIComponent(currentUser._id) + "&"
    sourceUrl += "url=" + encodeURIComponent(parentUrl)
    tokenEmail = TokenEmails.findOne({wishpoolOwnerToken: Wishpool.ownerToken})?.email

    if userEmail isnt "" or tokenEmail
      Feedbacks.insert(
        text: actualText
        parentUrl: parentUrl
        sourceUrl: sourceUrl
        email: userEmail or tokenEmail
      )
      $('.widget-group').fadeOut(400, ->
        $('.success').fadeIn()
      )
      Meteor.setTimeout(() ->
        $('.success').fadeOut(400, ->
          template.$(".wishpool-input").val(defaultText)
          $('.widget-group').fadeIn()
          template.$(".placeholder .text").removeClass("hidden")
        )
      , 2000)
    else
      feedbackId = Feedbacks.insert(
        text: actualText
        parentUrl: parentUrl
        sourceUrl: sourceUrl
        sourceUserToken: Wishpool.ownerToken
      )
      $('.input-group').fadeOut(400, ->
        $('.ask-email').focus()
        $('.ask-email').fadeIn()
      )

  'submit form.email-form': grab encapsulate (event, template) ->
    actualText = template.$(".wishpool-input").val()
    defaultText = Widgets.findOne(template.data.widgetId).label + " "
    email = template.$(".email-input").val()
    if not email.match(Wishpool.emailLinkRegExp)
      return
    TokenEmails.insert(
      email: email
      wishpoolOwnerToken: Wishpool.ownerToken
    )
    $('.ask-email').fadeOut(400, ->
      $('.success').fadeIn()
    )
    Meteor.setTimeout(() ->
      $('.success').fadeOut(400, ->
        template.$(".wishpool-input").val(defaultText)
        $('.widget-group').fadeIn()
        template.$(".placeholder .text").removeClass("hidden")
      )
    , 2000)

