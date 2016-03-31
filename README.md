# RubyOS

[![Build Status](https://travis-ci.org/wspurgin/ruby-os.svg?branch=master)](https://travis-ci.org/wspurgin/ruby-os)

RubyOS is a fun simulate Operating System written in Ruby!

Please review the [Usage](#user-content-usage) section and particular the notes
on [Implementation](#user-content-special-notes-on-implementation).

## Installation

### Getting the source

You can either clone this repository with `git` or get the tarball directly from
the [homepage](https://github.com/wspurgin/ruby-os) and extract the source from
that.

Using `git` simply clone the repository:

```
git clone https://github.com/wspurgin/ruby-os.git
```

### Requirements to Run

In order to run RubyOS, you need a `ruby` version `>= 2.0.0`. All ruby version
greater than or equal to `2.0.0` have been tested using
[RSpec](http://rspec.info/) on [Travis CI](https://travis-ci.org/wspurgin/ruby-os).

### Convenience

For your convenience, a `rake` task as been added to generate random test data
that conforms to the input specification for `ruby-os`. However, to use this
task you will have to have `rake` installed. See the
[Development](#user-content-development) section for how to install development
dependencies such as `rake`


## Usage

RubyOS is written very modularly. All the basic components used to build it are
under the `lib` directory. You can run the include simulated OS by running the
executable `exe/ruby-os`

### `ruby-os` Simulated OS

The simulated OS executable `exe/ruby-os` runs interactively to build a set of
Queues and PCBs. After which a number of scheduling simulations can be run.
After lunching, `ruby-os` includes a `help` command that lists the available
commands within the simulation. Here's a short explanation of some of the key
commands.

```
add_proc
```
As the name suggests, this command allows you to interactively create a PCB and
add it to a queue. You'll have to enter in the PID, starting address, priority,
remaining processing time for the process, and then pick which queue to enter it
in.

```
delete_proc
```
This command removes process(es) with the given PID.


```
simulate [scheduler]
```
This command runs the actually OS simulation. The `scheduler` argument accepts
three different choices for the scheduler: `sjf`, `robin`, and `priority`.
RubyOS uses fuzzy matching so if you misspell _priority_ as *poirety*, it'll be
okay. RubyOS will know you meant _priority_. Since the three options all start
with different letters any input that _starts_ with the same letter as a
scheduler will work. Thus the shorthand for `sjf` is just `s`

### Using an Input File

Manually adding a set of process would be rough… as such, RubyOS takes a command
line argument to specify a file to read and initialize the queues. An example
lives in `doc/test_procs.csv`. The format for these files is very specific. PCBs
are separated by newline characters. PCBs themselves follow this format:

```
pid, starting_address, state, [option:value]
```

The `option:value` format is used to specify other key information, in the case
of this OS, it's recommended to include the following options:

```
remaining_processing_time:[integer], priority:[integer]
```

Therefore a final PCB entry that can run with all schedulers, looks like this:

```
1, 0xa8, ready, remaining_processing_time:18, priority:3
```


### Example Run

Nothing helps like an example, here's a run from scratch:

```
$ ./exe/ruby-os
Initializing Queues
Ready Queue: <Queue: []>
Waiting Queue: <Queue: []>
This is RubyOS, a simulated OS written in Ruby ✓
Enter Commands (enter help for usage)
>add_proc
Enter process id
>1
Enter starting address (e.g. 0x2) (hit enter to use default)
>
Enter process' priority (hit enter to use default of 4)
>
Enter process' remaining processing time (hit enter to use default of 8)
>10
Which queue do you want to add the process to? ('waiting', or 'ready')
>ready
Enter the position you wish to insert the process (hit enter to use the default location)
>
Ready Queue: <Queue: [<PCB pid=1 remaining=10 priority=4>]>
Waiting Queue: <Queue: []>
Enter Commands (enter help for usage)
>add_proc
Enter process id
>2
Enter starting address (e.g. 0x2) (hit enter to use default)
>
Enter process' priority (hit enter to use default of 4)
>dalkjgw
Value entered is not an integer, please enter integer value
>3
Enter process' remaining processing time (hit enter to use default of 8)
>5
Which queue do you want to add the process to? ('waiting', or 'ready')
>ANYOFTHEM!!
Unrecognized queue 'ANYOFTHEM!!', please enter a valid queue (ready,waiting)
>ready
Enter the position you wish to insert the process (hit enter to use the default location)
>
Ready Queue: <Queue: [<PCB pid=1 remaining=10 priority=4>, <PCB pid=2 remaining=5 priority=3>]>
Waiting Queue: <Queue: []>
Enter Commands (enter help for usage)
>add_proc
Enter process id
>3
Enter starting address (e.g. 0x2) (hit enter to use default)
>
Enter process' priority (hit enter to use default of 4)
>
Enter process' remaining processing time (hit enter to use default of 8)
>
Which queue do you want to add the process to? ('waiting', or 'ready')
>ready
Enter the position you wish to insert the process (hit enter to use the default location)
>
Ready Queue: <Queue: [<PCB pid=1 remaining=10 priority=4>, <PCB pid=2 remaining=5 priority=3>, <PCB pid=3 remaining=8 priority=4>]>
Waiting Queue: <Queue: []>
Enter Commands (enter help for usage)
>help
The following are the accepted commands:
help        - prints this usuage guide
add_proc    - interactively adds a process to a queue
delete_proc - interactively remove a process from a queue
show_queues - prints queues to STDOUT
simulate [scheduler] - runs simulation with the given scheduler. Choices are sjf, robin, priority. Default is sjf.
exit        - quits the program
quit        - alias for exit
Enter Commands (enter help for usage)
>simulate priority
Beginning simulation with RubyOS::PriorityScheduler
Max iterations calculated from process time: 260
Current Proc in CPU: <PCB pid=2 remaining=4 priority=3>
Ready Queue: <Queue: [<PCB pid=1 remaining=10 priority=4>, <PCB pid=3 remaining=8 priority=4>]>
Current Proc in CPU: <PCB pid=2 remaining=3 priority=3>
Ready Queue: <Queue: [<PCB pid=1 remaining=10 priority=4>, <PCB pid=3 remaining=8 priority=4>]>
Current Proc in CPU: <PCB pid=2 remaining=2 priority=3>
Ready Queue: <Queue: [<PCB pid=1 remaining=10 priority=4>, <PCB pid=3 remaining=8 priority=4>]>
Current Proc in CPU: <PCB pid=2 remaining=1 priority=3>
Ready Queue: <Queue: [<PCB pid=1 remaining=10 priority=4>, <PCB pid=3 remaining=8 priority=4>]>
<PCB pid=2 remaining=0 priority=3> Completed
Ready Queue: <Queue: [<PCB pid=1 remaining=10 priority=4>, <PCB pid=3 remaining=8 priority=4>]>
Perfroming context switch with <PCB pid=1 remaining=10 priority=4>
Current Proc in CPU: <PCB pid=1 remaining=9 priority=4>
Ready Queue: <Queue: [<PCB pid=3 remaining=8 priority=4>]>
Current Proc in CPU: <PCB pid=1 remaining=8 priority=4>
Ready Queue: <Queue: [<PCB pid=3 remaining=8 priority=4>]>
Current Proc in CPU: <PCB pid=1 remaining=7 priority=4>
Ready Queue: <Queue: [<PCB pid=3 remaining=8 priority=4>]>
Current Proc in CPU: <PCB pid=1 remaining=6 priority=4>
Ready Queue: <Queue: [<PCB pid=3 remaining=8 priority=4>]>
Current Proc in CPU: <PCB pid=1 remaining=5 priority=4>
Ready Queue: <Queue: [<PCB pid=3 remaining=8 priority=4>]>
Current Proc in CPU: <PCB pid=1 remaining=4 priority=4>
Ready Queue: <Queue: [<PCB pid=3 remaining=8 priority=4>]>
Current Proc in CPU: <PCB pid=1 remaining=3 priority=4>
Ready Queue: <Queue: [<PCB pid=3 remaining=8 priority=4>]>
Current Proc in CPU: <PCB pid=1 remaining=2 priority=4>
Ready Queue: <Queue: [<PCB pid=3 remaining=8 priority=4>]>
Current Proc in CPU: <PCB pid=1 remaining=1 priority=4>
Ready Queue: <Queue: [<PCB pid=3 remaining=8 priority=4>]>
<PCB pid=1 remaining=0 priority=4> Completed
Ready Queue: <Queue: [<PCB pid=3 remaining=8 priority=4>]>
Perfroming context switch with <PCB pid=3 remaining=8 priority=4>
Current Proc in CPU: <PCB pid=3 remaining=7 priority=4>
Current Proc in CPU: <PCB pid=3 remaining=6 priority=4>
Current Proc in CPU: <PCB pid=3 remaining=5 priority=4>
Current Proc in CPU: <PCB pid=3 remaining=4 priority=4>
Current Proc in CPU: <PCB pid=3 remaining=3 priority=4>
Current Proc in CPU: <PCB pid=3 remaining=2 priority=4>
Current Proc in CPU: <PCB pid=3 remaining=1 priority=4>
<PCB pid=3 remaining=0 priority=4> Completed
Completed Procs: [<PCB pid=2 remaining=0 priority=3>, <PCB pid=1 remaining=0 priority=4>, <PCB pid=3 remaining=0 priority=4>]


The Results using the RubyOS::PriorityScheduler are here:
Average Wait Time: 6 time units
Average Context Switches per Process: 0.6666666666666666
Total Number of Context Switches: 2
Total Processes: 3
Total Completed Procs: 3
Enter Commands (enter help for usage)
>show_queues
Ready Queue: <Queue: [<PCB pid=1 remaining=10 priority=4>, <PCB pid=2 remaining=5 priority=3>, <PCB pid=3 remaining=8 priority=4>]>
Waiting Queue: <Queue: []>
Enter Commands (enter help for usage)
>simulate sjf
Beginning simulation with RubyOS::SrptScheduler
Max iterations calculated from process time: 260
Current Proc in CPU: <PCB pid=2 remaining=4 priority=3>
Ready Queue: <Queue: [<PCB pid=3 remaining=8 priority=4>, <PCB pid=1 remaining=10 priority=4>]>
Current Proc in CPU: <PCB pid=2 remaining=3 priority=3>
Ready Queue: <Queue: [<PCB pid=3 remaining=8 priority=4>, <PCB pid=1 remaining=10 priority=4>]>
Current Proc in CPU: <PCB pid=2 remaining=2 priority=3>
Ready Queue: <Queue: [<PCB pid=3 remaining=8 priority=4>, <PCB pid=1 remaining=10 priority=4>]>
Current Proc in CPU: <PCB pid=2 remaining=1 priority=3>
Ready Queue: <Queue: [<PCB pid=3 remaining=8 priority=4>, <PCB pid=1 remaining=10 priority=4>]>
<PCB pid=2 remaining=0 priority=3> Completed
Ready Queue: <Queue: [<PCB pid=3 remaining=8 priority=4>, <PCB pid=1 remaining=10 priority=4>]>
Perfroming context switch with <PCB pid=3 remaining=8 priority=4>
Current Proc in CPU: <PCB pid=3 remaining=7 priority=4>
Ready Queue: <Queue: [<PCB pid=1 remaining=10 priority=4>]>
Current Proc in CPU: <PCB pid=3 remaining=6 priority=4>
Ready Queue: <Queue: [<PCB pid=1 remaining=10 priority=4>]>
Current Proc in CPU: <PCB pid=3 remaining=5 priority=4>
Ready Queue: <Queue: [<PCB pid=1 remaining=10 priority=4>]>
Current Proc in CPU: <PCB pid=3 remaining=4 priority=4>
Ready Queue: <Queue: [<PCB pid=1 remaining=10 priority=4>]>
Current Proc in CPU: <PCB pid=3 remaining=3 priority=4>
Ready Queue: <Queue: [<PCB pid=1 remaining=10 priority=4>]>
Current Proc in CPU: <PCB pid=3 remaining=2 priority=4>
Ready Queue: <Queue: [<PCB pid=1 remaining=10 priority=4>]>
Current Proc in CPU: <PCB pid=3 remaining=1 priority=4>
Ready Queue: <Queue: [<PCB pid=1 remaining=10 priority=4>]>
<PCB pid=3 remaining=0 priority=4> Completed
Ready Queue: <Queue: [<PCB pid=1 remaining=10 priority=4>]>
Perfroming context switch with <PCB pid=1 remaining=10 priority=4>
Current Proc in CPU: <PCB pid=1 remaining=9 priority=4>
Current Proc in CPU: <PCB pid=1 remaining=8 priority=4>
Current Proc in CPU: <PCB pid=1 remaining=7 priority=4>
Current Proc in CPU: <PCB pid=1 remaining=6 priority=4>
Current Proc in CPU: <PCB pid=1 remaining=5 priority=4>
Current Proc in CPU: <PCB pid=1 remaining=4 priority=4>
Current Proc in CPU: <PCB pid=1 remaining=3 priority=4>
Current Proc in CPU: <PCB pid=1 remaining=2 priority=4>
Current Proc in CPU: <PCB pid=1 remaining=1 priority=4>
<PCB pid=1 remaining=0 priority=4> Completed
Completed Procs: [<PCB pid=2 remaining=0 priority=3>, <PCB pid=3 remaining=0 priority=4>, <PCB pid=1 remaining=0 priority=4>]


The Results using the RubyOS::SrptScheduler are here:
Average Wait Time: 6 time units
Average Context Switches per Process: 0.6666666666666666
Total Number of Context Switches: 2
Total Processes: 3
Total Completed Procs: 3
Enter Commands (enter help for usage)
>exit
```

## Special Notes on Implementation

Normally, Operating System's assign PID to process and that uniquely identifies
that process. The current implementation of this simulated OS is meant to be
more of a scheduling simulator. As such, it does not check for the uniqueness of
PIDs when they are entered (either interactively or via file input).

Additionally, when processes are in the `waiting` queue, they are typically
waiting on things like I/O, and once they are ready, raise some sort of
interrupt for the OS to stick them back in the ready queue. In the case of this
simulated OS, these process don't have a way to 'interrupt' and get themselves
moved to the ready queue. As such, and to facilitate accurate simulations across
different scheduling methods, **if there are any PCBs in the waiting queue, one
is moved to the ready queue every cycle**.

## Development

### Install `bundler`

If you don't have it, you'll need to install [bundler](http://bundler.io/).

### Developing

After checking out the repo, run `bin/setup` to install dependencies (this
requires having bundler installed). Then, run `rake` to run the tests. You can
also run `bin/console` for an interactive prompt that will allow you to
experiment. Run `bundle exec ruby-os` to use the gem in this directory, ignoring
other installed copies of this gem.

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/wspurgin/ruby-os).


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

