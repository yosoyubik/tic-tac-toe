# TIC-TAC-TOE for Urbit

This is an homage to [urbit's](https://urbit.org/) tic-tac-toe [app](https://www.youtube.com/watch?v=_acTt4_IXYM&t=225s), based on the [example](https://github.com/joshuareagan/doc-drafts/blob/master/Hoon-Ch2-10.md) written by [Joshua Reagan](http://www.joshuareagan.com/) (aka ~taglux-nidsep)

![Alt Text](toe.low.gif)

## Features

- Network multiplayer
- Board state printed in the console
- Structures in `/=home=/sur` and marks for updates
- ~~Fixes an [issue](https://github.com/urbit/arvo/issues/1100) with removing the head of a queue using a custom library (`%cola`)
  - Sadly this [didn't fix anything](https://github.com/urbit/arvo/issues/1100#issuecomment-483845590). Better to replace the `+qeu` with a list.
- Notifications for game invitation
- Uses queue instead of list to keep track of incoming and outgoing subscriptions
  - TODO: Research Gall/Hall to replace this
- Pending requests are queued and pulled after current game finishes
- Styled text to print crosses and noughts on board, and game notifications

## Local install

This might take some time to compile, seat tight!

    cp toe/app/toe.hoon /path/to/your-urbit/home/app
    cp -r toe/mar/toe /path/to/your-urbit/home/mar
    cp toe/sur/toe.hoon /path/to/your-urbit/home/sur
    cp toe/lib/cola.hoon /path/to/your-urbit/home/lib

## Start playing!!

In your urbit's Dojo, run the command:

    ~your-urbit:dojo> |start %toe

The list of commands are:

- `'~ship-name'`: sends request to ~ship
  - Only if the prompt is `| shall we play a game?`
- `'!'`: cancels the current game. (if any, unqueues next subscription)
- `'l'`: list current subscriptions (any time during the game)
  - ![list|20%](subs.png)
- `'1/1'`: board coordinates (`[1-3/1-3]`)
  - Only if the prompt is `| ~zod:[X] <- ~dev:[O] |`
- `'Y'`: confirm/reject request to play `[Y/N]`
  - Only if the prompt is:
    - `| ~zod wins! continue? (Y/N) |`
    - `| waiting for ~zod (!=quit) |`

## In Progress
- Refactor code
- Follow `/=home=/gen/deco.hoon` best-coding practices (deprecated)
- Follow [code style](https://urbit.org/docs/learn/arvo/style/)
- Remove old three/four letter variable names
- Using Hoonian idioms

## TODO
- Partial board re-paint on each move.
- Web frontend
- Integrate with Hall to allow for rooms in chat
- Single-player mode
- Send multple requests to multiple ships
- Don't block game waiting for a confirmation
- Cancel a specific request from the list of subscribers
- Documentation

## References

- https://github.com/joshuareagan/doc-drafts/blob/master/Hoon-Ch2-10.md
- https://urbit.org/
- https://www.youtube.com/watch?v=_acTt4_IXYM
