# Hubot

The scripts are designed to be used with [Hubot](https://github.com/github/hubot/).

## ec2

This script helps to start and stop EC2 instances. It has to be configured via `env` variables:

* `AWS_ACCESS_ID` The access ID for the AWS account
* `AWS_ACCESS_SECRET` The access secret for the AWS account
* `AWS_EC2_TAG` A filter to selecto which machines are managed

It is highly recommended that you use [IAM](http://aws.amazon.com/es/iam/) to get the access account.

The `AWS_EC2_TAG` is in the form of `name=value`. Only machines that has the value `value` in the tags `name` will be stopped and started via Hubot.

### Commands

*hubot ec2 status*

Retrieve the status of all instances, and show its state (running, stopped, etc), it instance ID, and its public IP address (if any)

*hubot ec2 start*

Starts all the instances

*hubot ec2 stop*

Stop all the instances
