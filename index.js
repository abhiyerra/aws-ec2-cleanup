var config = require('./config.json')

var chef = require('./chef')

var terminationsEvents = [
    'autoscaling:EC2_INSTANCE_TERMINATE',
];

var ChefApi = require("chef-api");

cleanupChef = function() {
    var chef = new ChefApi();

    chef.config(options);

    chef.getNodes(function(err, res) {
        if(err) {
            throw err;
        }

        // TODO: Delete the Node here.
    });
}

exports.handler = function(event, context) {
    var records = event.Records;
    var record;
    var snsMessage;

    if(!records || records.length == 0) {
        return context.fail(new Error('aws-ec2-cleanup: no records provided in event: ' + event));
    }

    record = records[0];
    if(record.EventSource != 'aws:sns') {
        return context.fail(new Error('aws-ec2-cleanup: unexpected event source ' + record.EventSource + ': ' + event));
    }

    if(!record.Sns || !record.Sns.Message) {
        return context.fail(new Error('aws-ec2-cleanup: No SNS message in event: ' + event));
    }

    try {
        snsMessage = JSON.parse(record.Sns.Message);
        if(!terminationsEvents.includes(snsMessage.Event)) {
            return context.done();
        }

        if(snsMessage.AccountId != config.awsAccountId) {
            return context.fail(new Error('aws-ec2-cleanup: Invalid Account id passed: ' + snaMessage.AccountId))
        }
    } catch (error) {
        return context.fail(new Error('aws-ec2-cleanup: Invalid JSON in SNS message: ' + eventString));
    }

    cleanupChef(config.chef);
}
