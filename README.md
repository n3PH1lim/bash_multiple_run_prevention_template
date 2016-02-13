# bash_multiple_run_prevention_template
Template for prevent a bash script to run multiple times

Sometimes it is necessary to prevent a bash script to run multiple times.

I have done this with FLOCK
<a href="http://linux.die.net/man/1/flock" target="_blank">FLOCK Man Page</a>

Here you can find a code template to prevent a script running multiple times.

There is also a variable MAX_WORKING_TIME you can set when this prevention will be overwritten.

There are also some functions is use: decho, techo and remove_file please check the comments for more information.

One thing i had trouble with is when you use the template for a script that runs as a cronjob.
In this case please remember that the $(pwd) current directory is not the script directory!

Normally it is the home directory from the user that runs the cronjob because there will be a fresh bash session.
