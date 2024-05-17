/*
 * NextStepQueueable Class Description:
 * 
 * Implement the Queueable interface to process records asynchronously.
 * This example processes up to 10 accounts at a time.
 * It removes the Next Step from the accounts and related opportunities.
 *  
 * Benefits of using Queueable methods:
 * 
 * 1. Chaining Jobs: Allows for the chaining of jobs, meaning you can add another job to the queue from a running job.
 * 2. Stateful Execution: Supports stateful execution, which allows member variables to retain their values between job invocations.
 * 3. High Concurrency: Processes large sets of data without hitting governor limits.
 * 4. Flexibility: Useful for operations that need more flexibility in execution, especially when there's a possibility of chaining or performing related async operations.
 * 5. Enhanced Integration Capabilities: Useful for making asynchronous callouts to external systems, allowing for more extended processing times.
 * 
 * For more detailed information, refer to the official Salesforce documentation: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_queueing_jobs.htm
 * 
 * Note: The class below contains placeholders for implementing a queueable job to update accounts and opportunities.
 */
public with sharing class NextStepQueueable implements Queueable{

    // Member variable to store the accounts
    private Map<Id,Account> accounts;
    private static final Integer MAX_JOBS = 5;

    // Constructor to accept the accounts
    public NextStepQueueable() {
        //this.accounts = accounts;
    }

    // Method to queue the job
    public static void enqueueJob() {
        // Get 10 accounts with Next Step populated
        List<Account> acctList = [SELECT Id, Name, Next_Step__c from Account where Next_Step__c != null LIMIT 10];
        List<Opportunity> oppsList = [SELECT Id, Name, NextStep from Opportunity where NextStep != null LIMIT 10];
        // If there are any accounts, queue the job using System.enqueueJob

        if(acctList.isEmpty() && oppsList.isEmpty()) {
            return;
        }
        else {
            if(!acctList.isEmpty()) {
                for(Account acc : acctList) {
                    removeNextStep(acc);
                }
                update acctList;
            }

            if(!oppsList.isEmpty()) {
                for(Opportunity opp : oppsList) {
                    removeNextStep(opp);
                }
                update oppsList;
            }
        }
    }

    /*
     * Update/Uncomment the template code to create a method
     * Method to execute the queueable job
     */
    public void execute (QueueableContext queueableContext) {
        // Get the accounts from the member variable
        List<Account> acctList = [SELECT Id, Name, Next_Step__c from Account where Next_Step__c != null LIMIT 10];
            // Remove the Next Step using the helper method
        if(!acctList.isEmpty()) {
            for(Account acc : acctList) {
                removeNextStep(acc);
            }
        }
        // Update the accounts
        update acctList;

        // Get the opportunities related to the accounts
        List<Opportunity> oppsList = [SELECT Id, Name, NextStep from Opportunity where NextStep != null LIMIT 10];
            // Remove the Next Step using the helper method
        if(!oppsList.isEmpty()) {
            for(Opportunity opp : oppsList) {
                removeNextStep(opp);
            }
        }
        // Update the opportunities
        update oppsList;
        // Call the enqueueJob method to queue another job to process more records.

        System.enqueueJob(new NextStepQueueable());
    }

    // Helper method to remove the Next Step
    // Overloaded method to accept an opportunity
    private static void removeNextStep(Opportunity opp) {
        opp.NextStep = null;
    }

    // Helper method to remove the Next Step
    // Overloaded method to accept an account
    private static void removeNextStep(Account acc) {
        acc.Next_Step__c = null;
    }
}