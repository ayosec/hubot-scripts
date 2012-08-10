# Description:
#   cafe
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot cafe - show the current person to clean the coffee machine
#   hubot cafe add <person> - Add a new person at the end of the list
#   hubot cafe remove <person> - Remove a person to the list
#   hubot cafe replace <person-a> with <person-a> - Replace one name with other
#   hubot cafe next - move the assigned person to the next
#   hubot cafe set <person> - move the pointer to a specified person
#   hubot cafe list - Show current list
#
# Author:
#   @ayosec

module.exports = (robot) ->

  assignedPeople = ->
    robot.brain.data.cafe?.assignedPeople ? []

  robot.respond /cafe\s*$/i, (msg) ->
    person = robot.brain.data.cafe?.currentPerson
    if person
      msg.send "Dirty coffee for #{person}. Problem?"
    else
      msg.send "Nobody is assigned"

  robot.respond /cafe next\s*$/i, (msg) ->
    people = robot.brain.data.cafe?.people
    currentPerson = robot.brain.data.cafe?.currentPerson

    setCurrentPerson = (person) ->
      robot.brain.data.cafe.currentPerson = person
      msg.send "Now, #{person} will have to clean the coffee machine. LOL!!!11one"

    if people
      oldCurrentWasFound = false
      for person in people
        if oldCurrentWasFound
          setCurrentPerson person
          return
        else if person == currentPerson
          oldCurrentWasFound = true

      # currentPerson is at the end, or not present in the list
      setCurrentPerson people[0]

    else
      msg.send "WAT!? You have to add people with “hubot cafe add the name”"

  robot.respond /cafe set (.*)\s*$/i, (msg) ->
    people = robot.brain.data.cafe?.people
    currentPerson = robot.brain.data.cafe?.currentPerson

    unless people
      msg.send "WAT!? You have to add people with “hubot cafe add the name”"

    person = msg.match[1]

    if robot.brain.data.cafe.people.indexOf(person) == -1
      msg.send "Are You Fucking Kidding Me? #{person} is NOT in the list."
    else
      robot.brain.data.cafe.currentPerson = person
      msg.send "Now, #{person} will have to clean the coffee machine. LOL!!!11one"

  robot.respond /cafe add (.+)*$/i, (msg) ->
    if not robot.brain.data.cafe
      robot.brain.data.cafe = { people: [] }

    addedPeople = []
    for person in msg.match[1].split(",")
      person = person.replace(/^\s*/, "").replace(/\s*·/, "")

      if robot.brain.data.cafe.people.indexOf(person) == -1
        robot.brain.data.cafe.people.push person
        addedPeople.push person
    
    msg.send "Added #{addedPeople.join(", ")}."

  robot.respond /cafe remove (.+)\s*$/i, (msg) ->
    if not robot.brain.data.cafe
      msg.send "Dude! The list is empty!!!!!11one"
      return

    person = msg.match[1]
    index = robot.brain.data.cafe.people.indexOf(person)

    if index > -1
      delete robot.brain.data.cafe.people[index]
      msg.send "Congrats for #{person}. The name was removed from the list"
    else
      msg.send "Are You Fucking Kidding Me? #{person} is NOT in the list."

  robot.respond /cafe list$/i, (msg) ->
    people = robot.brain.data.cafe?.people
    if !people or people.length < 1
      msg.send "Nobody!"
      return

    msg.send people.join("\n")

  robot.respond /cafe replace (.+) with (.+)\s*$/i, (msg) ->
    if not robot.brain.data.cafe
      msg.send "Dude! The list is empty!!!!!11one"
      return

    sourceName = msg.match[1]
    destName = msg.match[2]
    index = robot.brain.data.cafe.people.indexOf(sourceName)

    if index > -1
      robot.brain.data.cafe.people[index] = destName
      msg.send "#{sourceName} is now #{destName}"
    else
      msg.send "Are You Fucking Kidding Me? #{sourceName} is NOT in the list."

  robot.respond /cafe validate list$/i, (msg) ->
    people = robot.brain.data.cafe?.people
    if people?.length > 0
      robot.brain.data.cafe.people = (item for item in people when "#{item}".length == 0)
    msg.send "Done!"
