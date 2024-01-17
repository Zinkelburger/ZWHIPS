# ZWHIPS
**Z**inkelburger's
**W**indows
**H**ardening and
**I**nitial 
**P**rotection
**S**cripts

# Overview
Need to run the scripts asynchronously, they can finish faster if they don't block.

## Dump Everything
Dump logs to get an initial state so we can restore to it later. For example: DNS records, static IPs.

1. Dump static IP / default IP of the machine (score checks may be looking for this)
2. Dump DNS records on the DC
3. Dump DNS servers it uses
4. Dump AD domain information
5. Dump the firewall information

## Antivirus Installation

## Deleting Autoruns
1. Delete all files on the desktops of all users, move them to a folder in the admin's Documents directory
2. Delete all files that are not signed by Microsoft, move them to a folder in the admin's Documents directory. (it is possible to restore these, we log the location they are removed from)
3. Delete all registry keys in the run and runOnce. Log these
4. Set other registry keys, such as disabling the WDigest authentication's feature of storing credentials in memory in plaintext

## Hunting Services & Scheduler
- Note: possible to delete all task scheduler things with minimal impact over the 2 day competition
1. Identify all task scheduler items not in a predetermined list
2. Give the user the option to delete those task scheduler items not in the predetermined list
3. Identify all services not in a predeterminted list of services and suspend them, take a closer look. Also look into hidden services?

## Disabling Accounts
1. Disable all AD accounts besides yourself and the black team (can only be run on the DC)
2. Disable all local accounts (besides the administrator user on the DC, as this is also a domain account)
3. Change the password of the kerberos account to mitigate Gold Tickets
4. Change the password of the services accounts to mitigate Silver Tickets

## Removing Sessions
1. Kick all users off of RDP sessions
2. Kick all users off of SSH sessions
3. Kick all users off of WinRM sessions / restart WinRM
4. Removing the openssh server
5. Disabling WinRM
6. Disabling RPC

## Remove File Shares
1. Removes all file shares to prevent the entire C drive from being shared on the network (a Justin Marwad classic)

## Delete GPO
1. Disables/unlinks all GPO
2. Puts the default GPO policy
3. Docs on how to manually enable powershell if it is disabled from GPO

## Networking
1. Note all ports open by the firewall, the processes using them, and if any of them look suspicious