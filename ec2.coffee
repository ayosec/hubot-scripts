# Manage EC2 instances.
#
# ec2 status - Get the status of the known instances.
# ec2 start - Starts all the managed instances.
# ec2 stop - Stops all running instances.

module.exports = (robot) ->

  Util = require "util"

  [ instanceTagName, instanceTagValue ] = process.env.AWS_EC2_TAG.toString().split("=")

  ec2 = require('aws2js').load('ec2',
    process.env.AWS_ACCESS_ID,
    process.env.AWS_ACCESS_SECRET)

  getInstances = (msg, callback) ->
    ec2.request "DescribeInstances", {
      "Filter.1.Name": "tag:#{instanceTagName}"
      "Filter.1.Value.1": instanceTagValue
      "Filter.2.Name": "instance-state-code"
      "Filter.2.Value.1": 0
      "Filter.2.Value.2": 16
      "Filter.2.Value.3": 32
      "Filter.2.Value.4": 48
      "Filter.2.Value.5": 64
      "Filter.2.Value.7": 80
    }, (err, response) ->

      if err
        console.log "ERROR in DescribeInstances: #{Util.inspect(err)}"
        msg.reply "Oops, I couldn't get the instances info. I'm so sorry :-("
        return

      callback(
        if items = response?.reservationSet?.item
          parseInstanceData = (item) ->
            item = item.instancesSet.item
            return {
              id: item.instanceId
              state: item.instanceState.name
              ipAddress: item.ipAddress

              isStopped: item.instanceState.name == "stopped"
              isRunning: item.instanceState.name == "running"
            }

          if typeof items.length == "undefined"
            [ parseInstanceData(items) ]
          else
            [ parseInstanceData(item) for item in items ]

        else

          # No instances
          []
      )

  robot.respond /ec2 status/i, (msg) ->
    getInstances msg, (instances) ->
      for instance in instances
        msg.send "[#{instance.state}] #{instance.id} - #{instance.ipAddress || "No IP"}"

  robot.respond /ec2 start/i, (msg) ->
    getInstances msg, (instances) ->
      ids = (instance.id for instance in instances when instance.isStopped)

      if ids.length == 0
        msg.reply "Nothing to stop."
        return

      msg.send "Starting #{ids.join(" ")}. Please wait..."

      # Call to StartInstances with all the known instances
      params = {}
      for instanceId, index in ids
        params["InstanceId.#{index + 1}"] = instanceId

      ec2.request "StartInstances", params, (err, response) ->
        if err
          console.log "ERROR in StartInstances: #{Util.inspect(err)}"
          msg.reply "Oops, I couldn't start the instances. I'm so sorry :-("


      # To notice when the instance is ready we create a limited
      # loop, which will query the instances every 5 seconds to
      # see if they are running
      pendingIds = {}
      pendingIds[id] = true for id in ids

      tries = 20
      handler = ->
        tries = tries - 1
        if tries < 0
          return

        getInstances msg, (instances) ->
          checkAgain = false
          for instance in instances
            if pendingIds[instance.id]
              if instance.isRunning
                pendingIds[instance.id] = false
                msg.send "Instance #{instance.id} running at #{instance.ipAddress}"
              else
                checkAgain = true

          if checkAgain
            setTimeout handler, 3000

      # Initialize the handler
      handler()

  robot.respond /ec2 stop/i, (msg) ->
    getInstances msg, (instances) ->
      ids = (instance.id for instance in instances when !instance.isStopped)
      msg.send "Stopping #{ids.join(" ")}. Please wait..."

      # Call to StartInstances with all the known instances
      params = {}
      for instanceId, index in ids
        params["InstanceId.#{index + 1}"] = instanceId

      ec2.request "StopInstances", params, (err, response) ->
        if err
          console.log "ERROR in StopInstances: #{Util.inspect(err)}"
          msg.reply "Oops, I couldn't stop the instances. I'm so sorry :-("
