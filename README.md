I'm using this for a server that needs a DV cert but isn't using it for HTTP/s, thus, since the ACME protocol requires 80/443 for verification, I wrote this to fix that. The intent is that it is used as a weekly cron in order to check for renewal. **It is NOT meant to be used, obviously, on webservers, otherwise you will defintiely create problems with closing ports and whatnot.** 

Please only use for servers that aren't otherwise using 80/443. For other methods, consider webroot with an alternative location:

https://gist.github.com/xenithorb/b60006405f9eb1ff8f79a3e9854cc3bf 