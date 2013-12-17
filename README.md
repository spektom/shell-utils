shell-utils
===========

Various shell utilities

### jp.sh - Job pool ###

This utility allows creating a named job pool limited by specified size,
and run some commands through it. That means that if a pool size is N,
at most N commands will be run simultaneously, others will wait until
a slot will be freed.

#### USAGE ####

```
USAGE: ./jp.sh <ID> <limit> <command>

Where:
  <ID>       Job pool identifier
  <limit>    Job pool size
  <command>  Command to run
```

