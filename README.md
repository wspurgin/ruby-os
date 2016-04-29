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
simulate [scheduler] [memory_manager]
```
This command runs the actually OS simulation. The `scheduler` argument accepts
three different choices for the scheduler: `sjf`, `robin`, and `priority`.
RubyOS uses fuzzy matching so if you misspell _priority_ as *poirety*, it'll be
okay. RubyOS will know you meant _priority_. Since the three options all start
with different letters any input that _starts_ with the same letter as a
scheduler will work. Thus the shorthand for `sjf` is just `s`

Likewise the command also takes an optional `memory_manager` argument that can
be used to specify the algorithm used to load processes into memory. The choices
are `firstfit`, `bestfit`, and `worstfit`. As with the `scheduler` argument,
fuzzy matching is used so `firstfit` can simply be inputed as `ff` or `first`,
`bestfit` as `bf` or `best`, and lastly `worstfit` as `wf` or `worst`. `fit` is
ambiguous, but if entered it will default to `firstfit`. The default, if not
specified at all, is `firstfit`.

### Using an Input File

Manually adding a set of process would be rough… as such, RubyOS takes a command
line argument to specify a file to read and initialize the queues. An example
lives in `doc/test_procs.csv`. The format for these files is very specific. PCBs
are separated by newline characters. PCBs themselves follow this format:

```
pid, state, [option:value]
```

The `option:value` format is used to specify other key information, in the case
of this OS, it's recommended to include the following options:

```
remaining_processing_time:[integer], priority:[integer], arrival_time:[integer],memory_required:[integer]
```

Therefore a final PCB entry that can run with all schedulers, looks like this:

```
1, ready, remaining_processing_time:18, priority:3, arrival_time:0, memory_required:200
```

**NOTE**, a less dynamic format is accepted, but is not recommended. It can,
however, be used to specify an initial "memory state". This format is supported
for SMU CSE 7343 primarily. It goes as thus:

```
MemorySize
[number of holes in memory (or blank line)]
starting_address,size
...
[number of processes (or blank line)]
pid,arrival_time,duration,size_of_memory
```


## Special Notes on Implementation

When processes are in the `waiting` queue, they are typically
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

