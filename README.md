# TIC-TAC-TOE in Hoon

This is an homage to [urbit's](https://urbit.org/) tic-tac-toe [app](https://www.youtube.com/watch?v=_acTt4_IXYM&t=225s), based on the [example](https://github.com/joshuareagan/doc-drafts/blob/master/Hoon-Ch2-10.md) written by Joshua Reagan (aka ~taglux-nidsep)

_Teaser... ~~(don't mind the error at the end)~~_

![Alt Text](zod.gif)
## Docs

We are basicailly modelling a state machine between two ships running the same
app and the console (%sole).

~zod
             %sole
~marzod

## Features

- Network multiplayer. [Done! check [network](https://github.com/josl/tic-tac-toe/tree/network) branch for updates]
- Board state printed in the console
- Structures in `/=home=/sur` and marks for updates
- Notification for game invitation

## Network install

TODO

## Local install

TODO

## Get started!

In your urbit's Dojo, run the command:

    ~your-urbit:dojo> |start %toe

## In Progress
- Refactor code (remove redundant code)
- Keep track of incoming request
- Use queue instead of list to keep track on subscriptions on hold

## TODO
- Fix hardcoded toers (`[%x %o]`) when player doesn't select icon (`[X O]`)
- Partial board re-paint on each move.
- Web frontend
- Follow `/=home=/gen/deco.hoon` best-coding practices
- Improve game state transtition
- Both apps need to be running before sending request to play

## References

- https://github.com/joshuareagan/doc-drafts/blob/master/Hoon-Ch2-10.md
- https://urbit.org/
- https://www.youtube.com/watch?v=_acTt4_IXYM
