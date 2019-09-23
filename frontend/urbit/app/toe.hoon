::  Tic-Tac-Toe
::
/-  toe
/+  sole, *server
::
:: This imports the tile's JS file from the file system as a variable.
/=  tile-js
  /^  octs
  /;  as-octs:mimes:html
  /:  /===/app/toe/js/tile
  /|  /js/
      /~  ~
  ==
::
=,  toe
=,  sole
=,  format
::
!:
::
=>  |%
    ::
    +|  %models
    ::
    +$  state
      $:  ::  see (see %/sur/toe/hoon)
          ::
          toers=players
          subs=subscribers
          game=game-state
          board=board-state
          ::  $who: player that can perform a move
          ::
          who=ship
          ::  $next: flag to indicate a replay
          ::
          next=?
          ::
          ::  $front: id for frontend connection
          ::
          front=bone
          ::  $consol: console state
          ::
          ::     $conn:  id for console connection
          ::     $state: what's in the console
          ::
          consol=[conn=bone state=sole-share]
          ::consol=[conn=bone state=sole-share]
      ==
    ::
    +$  move  (pair bone card)
    ::
    +$  card
      $%  [%diff diff-data]
          [%peer wire dock path]
          [%pull wire dock ~]
          [%poke wire dock poke-data]
          [%wait wire p=@da]
          [%http-response =http-event:http]
          [%connect wire binding:eyre term]
      ==
    ::
    +$  diff-data
      $%  ::  See %/mar/toe/* for specific details
          ::    * = [turno, player, winner]
          ::
          ::    FIXME: replace wiht =toe-{mark} ?
          ::
          [%toe-turno toe-turno]
          [%toe-player toe-player]
          [%toe-winner toe-winner]
          [%sole-effect sole-effect]
          [%json json]
       ==
    ::
    +$  poke-data
      $%  [%toe-cancel toe-cancel]
          [%launch-action [@tas path @t]]
      ==
    ::
    ::  FIXME: $spot has to be redefined
    ::     even though it's already in sur...
    ::     it gave nest fails in +-moves-start
    ::     ?:  (~(has by board.sat) (spot-val u.try))
    ::     -find.a
    ::     which i assume references a/(tree (pair)) from +by
    ::
    +$  spot  [coord coord]
    --
::
::  %app
::
::    Our app is defined as a "door" (multi-armed core with a sample).
::    Arms are grouped in chapters (+|) based on common functionality
::
|_  [bol=bowl:gall %0 sat=state]
::
::  %alias: shortened
::
+|  %alias
::
::  %me: alias for our.bol
::
++  me  our.bol
::
::  %ze: alias for src.bol
::
++  ze  src.bol
::
::  %state
::
::    Arms to innitialize (and restart) our app's state
::
+|  %state
::
::  %this: common idiom to refer to our whole %app door and its context
::
++  this  .
::
++  prep
  ::  TODO: we need to treat old state differently. how? good question
  ::    rather than reseting old the time
  ::
  =>  |%
      ++  states
        $%  [%0 s=state]
        ==
      --
  |=  old=(unit states)
  ^-  (quip move _this)
  =/  launcha=poke-data
    [%launch-action [%toe /toetile '/~toe/js/tile.js']]
  =/  moves=(list move)
    :~  :: %connect here tells %eyre to mount at the /~toe endpoint.
        [ost.bol %connect / [~ /'~toe'] %toe]
        [ost.bol %poke /toe [our.bol %launch] launcha]
    ==
  ?~  old
    ::  we haven't modified the previous state
    ::
    (wipe moves)
  ::  the old state needs to be adapted to the new one
  ::
  ?-  -.u.old
    %0  (restore s.u.old moves)
  ==
::
++  wipe
  |=  moves=(list move)
  ^-  (quip move _this)
  :-  moves
  %=  this
      subs.sat   ~
      toers.sat  ~
      board.sat  ~
      next.sat   %.n
      game.sat   %select-opponent
  ==
::
::  TODO: something needs to be fixed here...
::
++  restore
  |=  [s=state moves=(list move)]
  ^-  (quip move _this)
  :-  moves
  this(sat s)
::
::  After timer kicks, we reset the prompt, cleaning the log message
::    FIXME: breaks %sole, more research needed...
::
++  wake
  |=  [wir=wire ~]
  ^-  (quip move _this)
  =^  edit  state.consol.sat  (transmit-sole reset)
  [[(effect det+edit)]~ this]
::
::  %core
::
::    Game engine logic
::
+|  %core
::
++  ge
  ::
  |_  buf=(list @c)
  ::
  ::  %processes user action
  ::
  ++  action
    ~&  game.sat^buf
    ?-    game.sat
        ::  Game Engine Step 1: selects opponent
        ::
        %select-opponent  select-opponent
        ::  Game Engine Step 2: waits for confirmation
        ::
        %confirm          wait-confirm
        ::  Game Engine Step 3: moves start
        ::
        %start            moves-start
        ::  Game Engine Step 4: game ends, waits for end/continue?
        ::
        %replay           continue-replay
    ==
  ::
  ::  $select-opponent: step 1
  ::    sends a request to play to opponent (e.g. ~zod)
  ::
  ::    FIXME:  error when app is not running
  ::            gall: %toe: move: invalid card (bone 0)
  ::            mack
  ::
  ++  select-opponent
    ^-  (quip move _this)
    =/  try  (rust (tufa buf) ;~(pfix sig fed:ag))
    ?~  try
      [~ this]
    ?:  =(u.try me)
      =/  front-error
        :~  [%status s+'error']
            [%message (tape:enjs:format +>->.frowned-upon)]
        ==
      :_  this
      :~  (effect frowned-upon)
          (send-tile-diff front-error)
          :: [front.sat %diff %json (front-error +>->.frowned-upon)]
      ==
    =^  edit  state.consol.sat  (transmit-sole reset)
    =/  new-prompt
      (prompt "{waiting}{(scow %p u.try)} {abort} | ")
    =/  front-message=(list [@t json])
      :~  [%message s+(scot %p u.try)]
          [%status s+'select-opponent']
      ==
    ::  $in=0: we haven't received a subscribe back yet so
    ::  by convention we assign 0 to the incoming subscription
    ::
    ~&  prey+(prey:pubsub:userlib /toetile bol)
    ~&  ost+ost.bol
    :_  this(subs.sat (snoc subs.sat [u.try [in=0 out=ost.bol]]))
    :~  (effect mor+~[det+edit new-prompt])
        [ost.bol %peer /join-game [u.try dap.bol] /invite]
        (send-tile-diff front-message)
        :: [front.sat %diff %json (pairs:enjs:format front-message)]
    ==
  ::
  ::  $wait-confirm: step 2
  ::    after reaciving a request to play, we block until
  ::    the console receives a comfirmation [Y/N] answer
  ::
  ++  wait-confirm
    ^-  (quip move _this)
    =/  try  (rust (cass (tufa buf)) (mask "yn"))
    ?~  try
      [~ this]
    ?:  =(u.try 'n')
      ::  don't play with this player
      ::
      crash-current-game
    ::  play with $opo: 1st incoming sub in the queue
    ::
    ?~  subs.sat
      ::  current player might have crashed zir game
      ::
      crash-current-game
    =/  guest  i.subs.sat
    ::  by default, player's icons are harcoded
    ::    (me = [X green], ze = [O red])
    ::
    =/  defaults   ~[[me [%x %g]] [ze.guest [%o %r]]]
    =/  icons      (get-icons ->.defaults)
    =/  new-opos   [[ze.guest [in.conns.guest ost.bol]] t.subs.sat]
    =.  toers.sat  (~(gas by toers.sat) defaults)
    ::  cleans up the prompt
    ::
    =^  edit  state.consol.sat  (transmit-sole reset)
    ::  by default, the first turn is mine
    ::    (the one who received the request)
    ::
    :_  %=  this
          who.sat   me
          game.sat  %start
          subs.sat  new-opos
        ==
    :~  ::  after we confirm, we subscribe to our opponent
        ::    TODO: research 2-way subscription model with Hall
        ::
        [ost.bol %peer /join-game [ze.guest dap.bol] /back]
        =/  front-message=(list [@t json])
          :~  [%stone s+(crip -.icons)]
              [%current s+(scot %p me)]
              [%status s+'start']
          ==
        ::  We unlock the confirmation state and start the game
        ::  We own the turn and can put moves on the board
        ::
        (send-tile-diff front-message)
        :: [front.sat %diff %json (pairs:enjs:format front-message)]
        ::  We send $accept to our subscriber with our icon
        ::    ->.default = [%x %g]
        ::
        [in.conns.i.subs.sat %diff %toe-player [%accept ->.defaults]]
        %-  effect
        :~  %mor
            det+edit
            instruct
            (prompt (create-dial [ze.guest icons "<-"]))
    ==  ==
  ::
  ::  $moves-start: step 3
  ::    now the game is on, each player will send diffs
  ::    to each other with the position for zir icon
  ::
  ++  moves-start
    ^-  (quip move _this)
    =/  try  (rust (tufa buf) position)
    ?~  try
      ~&  %nothing
      ~&  (tufa buf)
      ~&  (rust (tufa buf) position)
      [~ this]
    ?.   =(our.bol who.sat)
      :_  this
      ~[(effect wait-your-turn)]
    ?:  (~(has by board.sat) (spot-val u.try))
      :_  this
      ~[(effect spot-taken)]
    =/  new-step  [(~(got by toers.sat) me) (spot-val u.try)]
    =^  out  board.sat  (step new-step)
    =/  icons  (get-icons (~(got by toers.sat) me))
    =^  edit  state.consol.sat  (transmit-sole reset)
    ?~  subs.sat
      [~ this]
    ?~  out
      ::  we switch turns
      ::
      :_  this(who.sat ze.i.subs.sat)
      :~  ::  sends our game move (turno) to our opponent
          ::
          [in.conns.i.subs.sat %diff %toe-turno new-step]
          %-  effect
          :~  %mor
              print-grid
              det+edit
              (prompt (create-dial [ze.i.subs.sat icons "->"]))
      ==  ==
    ::  game ends
    ::
    :_  this(board.sat ~, game.sat %replay)
    :~  ::  sends winner move to our opponent
        ::
        [in.conns.i.subs.sat %diff %toe-winner [(end-message out) new-step]]
        %-  effect
        :~  %mor
            det+edit
            print-grid
            ?:(=(out %tie) falken bel+~)
            new-line
            (prompt "{(end-message out)}{keep-on}")
    ==  ==
  ::
  ::  $continue-replay: step 4
  ::    the game has finished, either with a win or a tie
  ::    now we block to confirm if the players want to continue
  ::
  ++  continue-replay
    ^-  (quip move _this)
    =/  try  (rust (cass (tufa buf)) (mask "yn"))
    ?~  try
      [~ this]
    ?:  =(u.try 'n')
      crash-current-game
    =^  edit  state.consol.sat  (transmit-sole reset)
    =.  board.sat  ~
    =/  my-toer  (~(got by toers.sat) me)
    =/  icons   (get-icons my-toer)
    ?~  subs.sat
      [~ this]
    =/  rematch
      [in.conns.i.subs.sat %diff %toe-player [%rematch my-toer]]
    ::  has our opponent already confirmed the replay?
    ::
    ?:  =(next.sat %.y)
      :_  this(game.sat %start, who.sat ze.i.subs.sat, next.sat %.n)
      :~  rematch
          %-  effect
          :~  %mor
              print-grid
              det+edit
              (prompt (create-dial [ze.i.subs.sat icons "->"]))
      ==  ==
    :_  this(game.sat %replay, next.sat %.y)
    :~  rematch
        %-  effect
        :~  %mor
            det+edit
            (prompt " | ...waiting for {(cite:title ze.i.subs.sat)} {abort} |")
    ==  ==
  ::
  --
::
::  %comunication
::
::    Gall-related arms for urbit-to-urbit communication
::
+|  %comms
::
::  $peer-invite: receives/enqueues a request to start a game
::
::    if a game is ongoing (or more than one request in queue),
::    enqueues the new request or asks for confirmation if no active games.
::
++  peer-invite
  |=  pax=path
  ^-  (quip move _this)
  =/  guest  (cite:title ze)
  ::  $out=0: we haven't subscribed back yet so
  ::  by convention we assign 0 to the out subs
  ::
  =/  invite  [ze [ost.bol 0]]
  =/  front-message=(list [@t json])
    :~  [%message s+(crip guest)]
        [%status s+'confirm']
    ==
  ?~  subs.sat
    ::  first invite goes into the subscribers queue
    ::
    :_  this(subs.sat ~[invite], game.sat %confirm)
    :~  (effect (prompt "{confirm}{guest}? (Y/N) | "))
        (send-tile-diff front-message)
        :: [front.sat %diff %json (pairs:enjs:format front-message)]
    ==
  :_  this(subs.sat (snoc subs.sat invite))
  ~[(effect klr+[[[```%b] " [ {guest} wants to play ]"] ~])]
  ::  FIXME: this is supposed to show log messages in the prompt that
  ::    are later wiped out by the +wake arm but we got a:
  ::    [%receive-sync [%his 5 4] %own 4 4]
  ::
  :: =/  request  ^-(sole-edit set+(tuba " [{guest} wants to play] "))
  :: =^  edit  state.consol.sat  (transmit-sole request)
  :: :_  this(subs.sat (~(put to `subscribers`subs.sat) invite))
  :: :~  (effect det+edit)
  ::     [ost.bol %wait / `@da`(add now.bol ~s3)]
  :: ==
::
::  $peer-back: subscribes back to the ship that requested to play with us
::
::
++  peer-back
  |=  pax=path
  ^-  (quip move _this)
  ?~  subs.sat
    [~ this]
  =/  new-head  [ze.i.subs.sat [ost.bol out.conns.i.subs.sat]]
  :-  ~
  this(subs.sat [new-head t.subs.sat])
::
++  reap
  |=  [wir=wire err=(unit tang)]
  ^-  (quip move _this)
  ?~  err  [~ +>]
  :_  this
  ~[(effect tan+u.err)]
::
::  $diff-toe-player: innvite accepted with we our opponent's icon
::
::    hardcoded %x as our opponent's icon.
::
++  diff-toe-player
  |=  [wir=wire msg=message per=player]
  ^-  (quip move _this)
  ::  %per: player of our opponent
  ::    +get-icons expected the player to be our, so we switch
  ::
  =/  icons  (get-icons (switch `per))
  ?-    msg
      ::  %accept: first match
      ::
      %accept
    ::  toers needs to be modifed before we send the new state
    ::    since create dial can't access a future state
    ::
    =.  toers.sat
      %-  ~(gas by toers.sat)
      :~  [our.bol [(switch-player `per) %g]]
          [ze [stone.per %r]]
      ==
    :_  this(game.sat %start, who.sat ze)
    :~  ::  We unlock the waiting state and start the game
        ::  Our opponent owns the turn
        ::
        :: =/  front-message
        ::   %-  pairs:enjs:format
        ::   :~  [%current (cite:title ze)]
        ::       [%stone +.icons]
        ::   ==
        =/  front-message
          :~  [%stone s+(crip +.icons)]
              [%current s+(scot %p ze)]
              [%status s+'start']
          ==
        (send-tile-diff front-message)
        :: [front.sat %diff %json (pairs:enjs:format front-message)]
        %-  effect
        :~  %mor
            instruct
            (prompt (create-dial [ze icons "->"]))
    ==  ==
  ::
      ::  %rematch: game has endend
      ::
      %rematch
    ::  has our opponent already confirmed the replay?
    ::
    ?.  next.sat
      [~ this(next.sat %.y)]
    =.  board.sat  ~
    ?~  subs.sat
      [~ this]
    :_  this(game.sat %start, who.sat me, next.sat %.n)
    :_  ~
    %-  effect
        :~  %mor
            print-grid
            (prompt (create-dial [ze.i.subs.sat icons "<-"]))
  ==    ==
::
::  We receive the resolution of the game
::
++  diff-toe-winner
  |=  [wir=wire win=toe-winner]
  ^-  (quip move _this)
  =/  stone  stone.per.tur.win
  =/  color  (switch-color color.per.tur.win)
  ::  puts the winner move on the board
  ::
  =^  out  board.sat  (step [[stone color] spo.tur.win])
  :_  this(game.sat %replay)
  ^-  (list move)
  :_  ~
  %-  effect
  :~  %mor
      print-grid
      ?:(=(out %tie) falken bel+~)
      new-line
      (prompt "{out.win}{keep-on}")
  ==
::
::  We receive our opponent's move on the board
::
++  diff-toe-turno
  |=  [wir=wire tur=toe-turno]
  ^-  (quip move _this.$)
  ::  puts the opponent's move on the  board
  ::
  =/  new-player  [stone.per.tur (switch-color color.per.tur)]
  =^  out  board.sat  (step [new-player spo.tur])
  ::  %get-icons expected the player to be ours
  ::    but per.tur is our opponent, so we switch
  ::
  =/  icons   (get-icons (switch `per.tur))
  =/  front-message=(list [@t json])
    :~  [%status s+'play']
        [%stone s+(crip (cuss (trip `@t`stone.per.tur)))]
        [%move a+~[n+(scot %u -.spo.tur) n+(scot %u -.spo.tur)]]
        :: [%move s+(crip "[{(scow %u -.spo.tur)},{(scow %u +.spo.tur)}]")]
    ==
  ~&  front-message
  ::  We unlock the confirmation state and start the game
  ::  We own the turn and can put moves on the board
  ::
  ?~  subs.sat
    [~ this]
  ::  now is our turn
  ::
  :_  this(who.sat me)
  :~  ^-  move  (send-tile-diff front-message)
      :: [front.sat %diff %json (pairs:enjs:format front-message)]
      %-  effect
      :~  %mor
          print-grid
          (prompt (create-dial [ze.i.subs.sat icons "<-"]))
  ==  ==
::
++  crash-current-game
  ^-  (quip move _this)
  ?~  subs.sat
    =^  edit  state.consol.sat  (transmit-sole reset)
    [[(effect det+edit)]~ this]
  =/  current-guest  i.subs.sat
  ?:  ::  if we haven't confirmed current subscription
      ::
      =(0 out.conns.current-guest)
    ::  send cancel poke
    ::
    (send-cancel current-guest)
  ::  if subscribed, %pull subscription
  ::
  (send-unsubscribe current-guest)
::
++  send-unsubscribe
  |=  guest=remote-app
  ^-  (quip move _this)
  ?~  subs.sat
    [~ this]
  =/  peer-move
    [out.conns.guest %pull /join-game [ze.guest dap.bol] ~]
  =^  edit  state.consol.sat  (transmit-sole reset)
  ::  Board is reset before printing it
  ::
  =.  board.sat  ~
  ::  we crashed our only subscription
  ::
  ?~  t.subs.sat
    ::  the board needs to be reset before producing anything
    ::  so the screen displays the empty board
    ::
    (wipe ~[(effect (all-effects edit)) peer-move])
  ::  Other toers are waiting for confirmation to play
  ::
  =/  new-guest  (cite:title ze.i.t.subs.sat)
  :_  %=  this
         game.sat  %confirm
         subs.sat  t.subs.sat
        board.sat  ~
      ==
  :~  peer-move
      %-  effect
      :~  %mor
          det+edit
          (prompt "{confirm}{new-guest} (Y/N)? | ")
  ==  ==
::
::  $pull: handles logic for ending subscriptions
::
::    we only handle /back cases, to stop communication
::    with a ship that requested to play with us
::
++  pull
  ::  TODO:
  ::    is it possible to get a %pull from a ship who didn't %peer?
  ::
  |=  pax=path
  ^-  (quip move _this)
  ::  if we receive a random pull, do nothing
  ::    FIXME: is this even necessary?
  ::
  ?~  subs.sat  [~ this]
  =/  shortened-ship  (cite:title ze)
  =/  out  klr+~[[[```%b] " [{shortened-ship} cancelled your game...]"]]
  ?.  =(ze ze.i.subs.sat)
    ::  we get a cancel from someone waiting in the queue
    ::  the current game needs to keep going, the queue is updated
    ::  silently, and we inform the app of the event
    ::
    :-  ~[(effect out)]
    %=  this
      subs.sat  %+  skip  `subscribers`subs.sat  :: why the cast?
                  |=(e=remote-app =(ze ze.e))
    ==
  =^  edit  state.consol.sat  (transmit-sole reset)
  =.  board.sat  ~
  ?~  t.subs.sat
    (wipe ~[(effect (all-effects edit))])
  ::  we get a cancel from the first in the queue
  ::
  :_  %=  this
         subs.sat  t.subs.sat
         game.sat  %confirm
      ==
  ::  we ask for confirmation to the next in the queue
  ::
  :~  %-  effect
      :~  %mor
          det+edit
          out
          (prompt "{confirm}{(cite:title ze.i.t.subs.sat)} (Y/N)? |  ")
  ==  ==
::
::  $send-cancel: sends a manual cancel to a ship that peered us
::
++  send-cancel
  |=  guest=remote-app
  ^-  (quip move _this)
  ?~  subs.sat
    [~ this]
  =/  cancel-move
    [ost.bol %poke /cancel [ze.guest dap.bol] [%toe-cancel %bye]]
  =^  edit  state.consol.sat  (transmit-sole reset)
  =/  tabla  print-grid
  ?:  =((lent subs.sat) 1)
    (wipe ~[(effect (all-effects edit)) cancel-move])
  ?~  t.subs.sat
    [~ this]
  =/  new-guest  (cite:title ze.i.t.subs.sat)
  :_  %=  this
         subs.sat  t.subs.sat
         game.sat  %confirm
        board.sat  ~
      ==
  :~  cancel-move
      %-  effect
      :~  %mor
          det+edit
          (prompt "{confirm}{new-guest} (Y/N)? | ")
      ==
  ==
::
::  $poke-toe-cancel: manual pull subscription
::
::    poking the app with a toe-cancel mark
::    for a pull on the guest ship
::
++  poke-toe-cancel
  |=  bye=toe-cancel
  ^-  (quip move _this)
  ::  if we receive a random cancel, do nothing
  ::
  ?~  subs.sat
    [~ this]
  ::  the manual pull can only be sent by our current guest
  ::
  ?.  =(ze ze.i.subs.sat)
    ::  if someone we didn't peer pokes us, do nothing
    [~ this]
  ::
  =/  current-guest  (cite:title ze.i.subs.sat)
  =^  edit  state.consol.sat  (transmit-sole reset)
  ?~  t.subs.sat
    ::  if we had only one opponent in the queue, reset
    ::
    (wipe ~[(effect (all-effects edit))])
  =/  new-guest  (cite:title ze.i.t.subs.sat)
  :_  %=  this
        subs.sat  t.subs.sat
        game.sat  %confirm
      ==
  :~  %-  effect
      :~  %mor
          det+edit
          klr+~[[[```%b] " [{current-guest} cancelled your game...] "]]
          (prompt "{confirm}{new-guest} (Y/N)? | ")
      ==
  ==
::
::  $poke-atom: manual reset
::
::    poking the app with any atom will do a manual wipe of the state
::
:: ++  poke-atom
::   |=  a=@
::   ^-  (quip move _this)
::   %-  wipe
::   ~[(effect mor+~[clear welcome new-line print-grid shall-we (prompt choose)])]
:: ::
:: ++  coup
::   |=  [wir=wire err=(unit tang)]
::   ?~  err  [~ +>]
::   :_  this
::   ~[(effect tan+u.err)]
::
::  %frontend
::
::    arms that deal with communication with eyre and the frontend
::
+|  %frontend
::
::  +peer-messages: subscribe to subset of messages and updates
::
::
++  peer-primary
  |=  wir=wire
  ^-  (quip move _this)
  [~ this]
::
++  bound
  |=  [wir=wire success=? binding=binding:eyre]
  ^-  (quip move _this)
  [~ this]
::
::  $peer-toefile:
::
++  peer-toetile
  |=  wir=wire
  ^-  (quip move _this)
  ~&  %peer-toetile
  :_  this(front.sat ost.bol)
  [ost.bol %diff %json *json]~
::
:: ++  front-error
::   |=  mssg=tape
::   ^-  json
::   %-  pairs:enjs:format
::     :~  [%message (tape:enjs:format mssg)]
::         [%status s+'error']
::     ==
::
:: ++  front-data
::   |=  m=(list [p=@t q=json])
::   ^-  json
::   (pairs:enjs:format m]
::
::  $poke-json:
::
++  poke-json
  |=  jon=json
  ^-  (quip move _this)
  ~&  json+jon
  ?.  ?=(%o -.jon)
    ::  ignores non-object json
    [~ this]
  =/  object=(map @t json)  +.jon
  =/  data=json  (~(got by object) 'data')
  =-  ~(action ge -)
  ^-  (list @c)
  ::  $data: cord->tape->(list @c)
  ::
  ::    this is a hack to reuse the parsing of console input
  ::    to handle data validation. hacks need to be refactor
  ::    at some point in the future, but not now
  ::
  ~&  data
  ?+    -.data  !!
    %a  =+  ((ar:dejs ni:dejs) data)
        (tuba "{(scow %u (snag 0 -))}/{(scow %u (snag 1 -))}")
        :: (tuba "1/1")
    %s  (tuba (trip (so:dejs data)))
  ==
::
::  +poke-handle-http-request: serve pages from file system based on URl path
::
::
++  send-tile-diff
  |=  pairs=(list [@t json])
  ^-  move
  =-  (snag 0 -)
  %+  turn  (prey:pubsub:userlib /toetile bol)
  |=  [=bone ^]
  [bone %diff %json (pairs:enjs:format pairs)]
::
++  poke-handle-http-request
  %-  (require-authorization:app ost.bol move this)
  |=  =inbound-request:eyre
  ^-  (quip move _this)
  =/  request-line  (parse-request-line url.request.inbound-request)
  =/  back-path  (flop site.request-line)
  =/  name=@t
    =/  back-path  (flop site.request-line)
    ?~  back-path
      ''
    i.back-path
  ::
  :_  this  ^-  (list move)
  ?~  back-path
    [ost.bol %http-response not-found:app]~
  ?:  =(name 'tile')
    [ost.bol %http-response (js-response:app tile-js)]~
  [ost.bol %http-response not-found:app]~
::
::  %console
::
::    %sole arms to receive console moves and prompt formatting
::
+|  %console
::
++  poke-sole-action
  |=  act=sole-action:sole
  ^-  (quip move _this)
  ::  FIXME: should an alias be used instead?
  ::
  =/  share  state.consol.sat
  ?-    -.act
    ::  $clr: clear screen
    ::
    $clr  [~ this]
    ::  $ret: enter key pressed
    ::
    $ret  ?~  buf.share  [~ this]
          ::  checks for a restart game command
          ::
          =/  restart
            (rust (tufa buf.share) ;~(just zap))
          ?.  =(~ restart)
            crash-current-game
          ::  checks for a "list waiting opponents" command
          ::
          =/  list
            (rust (tufa buf.share) ;~(just (just 'l')))
          ?.  =(~ list)  list-subscribers
          ::  %egg
          ::
          ::    ...?
          ::
          =/  egg
            (rust (tufa buf.share) ;~(just (jest (crip "joshua"))))
          ?.  =(~ egg)  easter-egg
          ::  based on the current state, a different engine arm is called
          ::
          ~(action ge buf.share)
          :: ?-    game.sat
          ::     ::  Game Engine Step 1: selects opponent
          ::     ::
          ::     %select-opponent  ~(select-opponent ge buf.share)
          ::     ::  Game Engine Step 2: waits for confirmation
          ::     ::
          ::     %confirm          ~(wait-confirm ge buf.share)
          ::     ::  Game Engine Step 3: moves start
          ::     ::
          ::     %start            ~(moves-start ge buf.share)
          ::     ::  Game Engine Step 4: game ends, waits for end/continue?
          ::     ::
          ::     %replay           ~(continue-replay ge buf.share)
          :: ==
    ::  $det: key press
    ::    FIXME: when code updates, it errors here:
    ::           lib/sole/hoon:<[103 5].[103 7]>
    ::           [%drum-coup-fail ~zod 1 p=~zod q=%toe]
    ::
    ::  pressed key is stored in the console state
    ::
    $det  =^  inv  state.consol.sat  (~(transceive sole share) +.act)
          [~ this]
  ==
::
::  $peer-sole: sole's subscription arm that connects to the console
::
++  peer-sole
  |=  path
  ^-  (quip move _this)
  =.  consol.sat  [ost.bol *sole-share]
  :_  this
  :~  %-  effect
      mor+~[clear welcome wopr print-grid shall-we (prompt choose)]
  ==
::
++  effect
  |=  fec=sole-effect
  ^-  move
  [conn.consol.sat %diff %sole-effect fec]
::
++  all-effects
  |=  =sole-change
  ^-  sole-effect
  :-  %mor
  :~  det+sole-change
      clear
      welcome
      new-line
      print-grid
      shall-we
      (prompt choose)
  ==
::
++  transmit-sole
  |=  inv=sole-edit
  ^-  [sole-change sole-share]
  (~(transmit sole state.consol.sat) inv)
::
::  $prompt: default game input that modifies the prompt
::
++  prompt
  |=  dial=styx
  ^-  sole-effect
  pro+[& %$ dial]
::
++  create-dial
  ::  +cite:title compresses the ship's name if
  ::    we are dealing with a comet
  ::
  |=  [guest=ship icons=[me=tape ze=tape] arrow=tape]
  ^-  styx
  :~  [[~ ~ ~] " | "]
      [[~ ~ ~] "{(cite:title me)}"]
      [[~ ~ ~] ":["]
      [[```%g] "{me.icons}"]
      [[~ ~ ~] "] {arrow} "]
      [[~ ~ ~] "{(cite:title guest)}"]
      [[~ ~ ~] ":["]
      [[```%r] "{ze.icons}"]
      [[~ ~ ~] "] |  "]
  ==
::
::  $print-row: pretty prints a row of the board displayed on the console
::
++  print-row
  |=  row=coord
  ^-  sole-effect
  =/  col=coord  %1
  :-  %klr
  |-  ^-  styx
  =/  symbol  (~(get by board.sat) [row col])
  =/  stone   (get-icon symbol)
  =/  color   (get-color symbol)
  :-  ?:  =(col %1)
        [[~ ~ ~] "    "]
      [[~ ~ ~] "| "]
  :_  ?:  =(col %3)  ~
    $(col (coord +(col)))
  [[~ ~ `color] "{stone} "]
::
::  $print-grid: pretty prints the board displayed on the console
::
++  print-grid
  ^-  sole-effect
  :-  %mor
  :~  (print-row %1)  row-sep
      (print-row %2)  row-sep
      (print-row %3)
      empty-style
  ==
::
++  end-message
  |=  out=outcome
  ^-  tape
  ?:(=(out %tie) " It's a tie!" " | {<who.sat>} wins!")
::
++  list-subscribers
  ^-  (quip move _this)
  =^  edit  state.consol.sat  (transmit-sole reset)
  ?~  subs.sat
    [~[(effect mor+~[det+edit no-subscribers])] this]
  :_  this
  :~  %-  effect
      :~  %mor
          (print-subscribers subs.sat)
          det+edit
  ==  ==
::
::  %rules
::
::    Pattern matching on console's input
::
+|  %rules
::
++  num-rule  (shim '1' '3')
++  index    (cook |=(a/@ (sub a '0')) num-rule)
++  position
  ::  e.g. [1-3]/[1-3]
  ::
  ;~((glue fas) index index)
::
++  spot-val
  |=  a=[@ @]
  ?>(?=(spot a) a)
::
::  %game
::
::     Arms for game-specific actions
::
+|  %game
::
++  step
  |=  tur=toe-turno
  ^-  [outcome board-state]
  =.  board.sat  (~(put by board.sat) [spo.tur per.tur])
  [(outcome-check per.tur) board.sat]
::
++  outcome-check
  |=  per=player
  ^-  outcome
  ?:  (win-check per)
    %wins
  ?:(tie-check %tie ~)
::
++  win-check
  |=  per=player
  ^-  ?
  %+  lien  winning-rows
  |=  a=(list spot)
  ^-  ?
  %+  levy  a
  |=  b=spot
  =/  c=(unit player)  (~(get by board.sat) b)
  ?~(c | =(stone.per stone.u.c))
::
++  tie-check
  =(~(wyt in board.sat) 9)
::
++  winning-rows
  ^-  (list (list spot))
  :~  ~[[%1 %1] [%2 %1] [%3 %1]]
      ~[[%1 %2] [%2 %2] [%3 %2]]
      ~[[%1 %3] [%2 %3] [%3 %3]]
      ~[[%1 %1] [%1 %2] [%1 %3]]
      ~[[%2 %1] [%2 %2] [%2 %3]]
      ~[[%3 %1] [%3 %2] [%3 %3]]
      ~[[%1 %3] [%2 %2] [%3 %1]]
      ~[[%1 %1] [%2 %2] [%3 %3]]
  ==
::
::  %helpers
::
::     (TODO: move to /===/lib)
::
+|  %helpers
::
++  switch
  |=  toer=(unit player)
  ^-  player
  ?~  toer  *player
  :_  (switch-color color.u.toer)
  ?:(=(stone.u.toer %o) %x %o)
::
++  switch-player
  |=  toer=(unit player)
  ^-  stone
  ?~  toer  ~
  ?:(=(stone.u.toer %o) %x %o)
::
++  switch-color
  |=  color=tint
  ^-  tint
  ?:(=(color %g) %r %g)
::
++  switch-both
  |=  toer=(unit player)
  ^-  player
  ?~  toer  *player
  :-  (switch-player toer)
  (switch-color color.u.toer)
::
++  get-icon
  |=  p=(unit player)
  ^-  tape
  ?~  p  " "
  (cuss (scow %tas stone.u.p))
::
++  get-color
  |=  p=(unit player)
  ^-  tint
  ?~  p  *tint
  color.u.p
::
++  get-icons
  |=  p=player
  ^-  [tape tape]
  ::    $me: the icon of my player
  ::    $ze: the icon of the opponent
  ::
  [me=(get-icon `p) ze=(get-icon `(switch `p))]
::
++  print-subscribers
  |=  queue=subscribers
  =/  count  1
  :-  %tan
  %-  flop
  :-  leaf+".............."
  |-  ^-  (list [%leaf tape])
  ?~  queue
    ~[leaf+".............."]
  :-  leaf+"{<count>}. {(cite:title ze.i.queue)}"
  $(queue t.queue, count +(count))
::
:: ++  guest-bone
::   |=  [ze=ship =path]
::   ^-  bone
::   ::  $arvo-subscribers:
::   ::    list of who has sent us a %peer with a join wire
::   ::
::   =/  arvo-subs  (prey:pubsub:userlib path bol)
::   =+  (skim arvo-subs |=(a=[* ze=ship *] =(ze.a ze)))
::   ?~  -  !!
::   -.-
::
++  easter-egg
  ^-  (quip move _this)
  =^  edit  state.consol.sat  (transmit-sole reset)
  [~[(effect mor+~[joshua det+edit])] this]
::
--
