::
::::  /hoon/toe/app
  ::
/?    310
/-    toe                                               ::  toe structures
/+    sole                                              ::  console lib
[. toe sole]                                            ::  exposes namespace
::  stack trace on
::
!:
::
=>  |%
    +|  %models
    ::
    +$  state      $:  tabla=table                      ::  board on screen
                       consol=console                   ::  sole-share
                       bo=board                         ::  game internal board
                       toers=(map ship player)          ::  who's who
                       me=ship                          ::  me (aka I)
                       game=opts                        ::  game state
                       who=ship                         ::  who's turn (mutex)
                       next=?                           ::  keep playing?
                       opos=subs                        ::  subscription queue   TODO: explore if gall has this
                    ==
    +$  move       (pair bone card)
    +$  card       $%  [%diff diff-data]
                       [%peer wire dock path]
                       [%pull wire dock ~]
                   ==
    +$  diff-data  $%  [%toe-turno toe-turno]
                       [%toe-player message player]
                       [%toe-winner toe-winner]
                       [%sole-effect sole-effect:sole]
                   ==
    +$  console    $:  bon=bone                         ::  socket (kinda?)
                       sha=sole-share:sole              ::  console's state
                   ==
    +$  spot       [num num]                            ::  has to be redefined  FIXME: ?!? wtf! it's already in sur...
    ::
    +|  %constants
    ::
    ++  welcome   txt+"WOPR's TIC-TAC-TOE "
    ++  menu-1    " | opponent? "
    ++  waiting   " | waiting for "
    ++  abor      "(!=quit)"
    ++  keep-on   " continue? (Y/N) | "
    ++  confirm   " | play with "
    ++  continue  txt+" | ready for more? (Y/N) | "
    ++  row-sep   leaf+"    ---------"
    ++  claro     clr+~                                 ::  clear screen
    ++  reset     set+~                                 ::  reset prompt
    ++  tong      bel+~                                 ::  call to arms
    --
::
::  %app
::
::    Our app is defined as a "door" (multi-armed core with a sample).
::    Arms are grouped in chapters (+|) based on common functionality
::
|_  [bol=bowl:gall state]
::
::  %state
::
::    Arms to innitialized (and restart) our app's state
::
+|  %state
::
++  this  ::  Common idiom to refer to our %app as a whole
          ::
          .
::
++  prep
  |=  *
  ^-  (quip move _+>)
  (wipe ~)
::
++  wipe
  |=  m=(list move)
  ^-  (quip move _+>)
  :-  m
  %=  +>
      opos   ~
      toers  ~
      bo     ~
      game   %opponent
      next   %.n
      me     our.bol
      tabla  [%tan ~]
  ==
::
::  %core
::
::    Game engine logic
::
+|  %core
::
++  ge
  ::
  |_  buf=sole-buffer:sole
  ::
  ++  ge-opponent                                       ::  G1: select opponent
    ^-  (quip move _this)
    =/  try  (rust (tufa buf) ;~(pfix sig fed:ag))
    ?~  try
      [~ this]
    =^  edit  sha.consol  (transmit-sole reset)
    =/  up-prompt  (prompt (weld waiting "{(scow %p u.try)} {abor} | "))
    :_  this
    :~  (send-invite u.try)
        (effect mor+~[det+edit up-prompt])
    ==
  ::
  ++  ge-confirm                                        ::  G2: wait for confirm
    ^-  (quip move _this)
    =/  try  (rust (tufa buf) (mask "YN"))
    ?~  try
      [~ this]
    ?:  =(u.try 'N')
      check-subscriptions
    =/  opo  (need ~(top to opos))                      ::  1st incoming sub
    =.  toers  %-  ~(gas by toers)
               ~[[me %x] [ze.opo %o]]                   ::  me = X, ze = O
    =/  icons  (get-icons %x)
    =^  edit  sha.consol  (transmit-sole reset)         ::  clean up prompt
    :_  this(game %start, who me)                       ::  first turn => me
    :~  subscribe-back
        (send-message [%accept %o])
        %-  effect
        :~  %mor
            det+edit
            (prompt " | {<me>}:[{-:icons}] <- {<ze.opo>}:[{+:icons}] | ")
    ==  ==
  ::
  ++  ge-start
    ::  G3: moves start
    ::
    ^-  (quip move _this)
    =/  try  (rust (tufa buf) position)
    ?~  try
      [~ this]
    ?.   =(our.bol who)
      :_  this
      ~[(effect txt+" wait for your turn ")]
    ?:  (~(has by bo) (spot-val (need try)))
      :_  this
      ~[(effect txt+" Spot taken ")]
    =/  new-step  [(~(got by toers) me) (spot-val u.try)]
    =^  out  bo  (step new-step)
    =/  icon  (get-icons (~(got by toers) me))
    =^  out  bo  (step new-step)
    =^  edit  sha.consol  (transmit-sole reset)
    =.  tabla  print-board
    ?~  out
      =/  opo  (need ~(top to opos))
      ::  we switch turns
      ::
      :_  this(who ze.opo)
      :~  (send-turno new-step)
          %-  effect
          :~  %mor
              tabla
              det+edit
              (prompt " | {<me>}:[{-:icon}] -> {<ze.opo>}:[{+:icon}] | ")
      ==  ==
    ::  game ends
    ::
    :_  this(bo ~, game %replay, tabla [%tan ~])
    :~  (send-winner [(end-message out) new-step])
        %-  effect
        :~  %mor
            det+edit
            tabla
            (prompt (weld (end-message out) keep-on))
    ==  ==
  ::
  ++  ge-replay
    ::  G4: wait for replay
    ::
    ^-  (quip move _this)
    =/  try  (rust (tufa buf) (mask "YN"))
    ?~  try
      [~ this]
    ?:  =(u.try 'N')
      check-subscriptions
    =^  edit  sha.consol  (transmit-sole reset)
    =.  bo  ~
    =.  tabla  print-board
    =/  icon  (get-icons (~(got by toers) me))
    =/  opo  (need ~(top to opos))
    =/  rematch  (send-message [%rematch (~(got by toers) me)])
    ::  has ze already confirmed?
    ::
    ?:  =(next %.y)
      :_  this(game %start, who ze.opo, next %.n)
      :~  rematch
          %-  effect
          :~  %mor
              tabla
              det+edit
              (prompt " | {<me>}:[{-:icon}] -> {<ze.opo>}:[{+:icon}] | ")
      ==  ==
    :_  this(game %replay, next %.y)
    :~  rematch
        %-  effect
        :~  %mor
            det+edit
            (prompt " | ...waiting for {<ze.opo>}'s {abor} |")
    ==  ==
  --
::
::  %comunication
::
::    Gall-related arms for urbit-to-urbit communication
::
+|  %comms
::
++  peer-invite
  ::  %peer-invite: receives/enqueues a request to start a game
  ::
  ::    if a game is ongoing enqueues new request or asks
  ::    for confirmation if no active games.
  ::
  |=  pax=path
  ^-  (quip move _+>)
  =.  opos  (~(put to opos) [| ost.bol /invite src.bol])
  ?~  ~(nap to opos)
    :_  +>(game %confirm)
    ~[(effect (prompt (weld confirm "{<src.bol>}? (Y/N) | ")))]
  :_  +>
  ~[(effect txt+" [{<src.bol>} wants to play] ")]
 ::
++  send-invite                                         ::  request to play
  |=  ze=ship
  ^-  move
  [ost.bol %peer /invite [ze dap.bol] /invite]
::
++  peer-back                                           ::  received from
  |=  pax=path                                          ::  ++  subscribe-back
  ^-  (quip move _+>)
  [~ +>(opos (~(put to opos) [& ost.bol /back src.bol]))]
::
++  subscribe-back
  ^-  move
  =/  guest  (need ~(top to opos))
  =/  up-opo  [& bo.guest /invite ze.guest]             ::  subs confirmed
  =.  opos   (~(put to ~(nap to opos)) up-opo)
  :*  bo.guest
      %peer                                                                     :: TODO: research 2-way
      /back                                                                     :: subs model
      [ze.guest dap.bol]                                                        :: with Hall?
      /back
  ==
::
++  diff-toe-player
  ::  invite accepted
  ::
  |=  [wir=wire msg=message per=player]
  ^-  (quip move _+>)
  =/  icon  (get-icons per)
  ?-    msg
      ::  first match
      ::
      %accept
    :_  +>.$(game %start, who src.bol)
    ~[(effect (prompt " | {<me>}:[{-:icon}] -> {<src.bol>}:[{+:icon}] "))]
  ::
      ::  game has endend and we ask to continue playing
      ::
      %rematch
    ::  already said yes?
    ::
    ?.  next
      [~ +>.$(next %.y)]
    =.  bo  ~
    =.  tabla  print-board
    =/  guest  (need ~(top to opos))
    :_  +>.$(game %start, who me, next %.n)
    :_  ~
    %-  effect
        :~  %mor
            tabla
            (prompt " | {<me>}:[{+:icon}] <- {<ze.guest>}:[{-:icon}] ")
  ==    ==
::
++  send-message
  |=  [msg=message per=player]
  ^-  move
  =/  guest  (need ~(top to opos))
  [bo.guest %diff %toe-player msg per]
::
++  diff-toe-winner
  |=  [wir=wire win=toe-winner]
  ^-  (quip move _+>)
  =^  out  bo  (step tur.win)                           ::  show winner move
  =.  tabla  print-board
  :_  +>.$(game %replay)
  ~[(effect mor+~[tabla (prompt (weld out.win keep-on))])]
::
++  send-winner                                         ::  spam with winner
  |=  win=toe-winner
  ^-  move
  =/  guest  (need ~(top to opos))
  [bo.guest %diff %toe-winner win]
::
++  send-turno                                          ::  spam with turno
  |=  tur=toe-turno
  ^-  move
  =/  guest  (need ~(top to opos))
  [bo.guest %diff %toe-turno tur]
::
++  diff-toe-turno
  |=  [wir=wire tur=toe-turno]
  ^-  (quip move _+>.$)
  =^  out  bo  (step tur)                               ::  move on board
  =.  toers  %-  ~(gas by toers)
             :~  [src.bol per.tur]
                 [our.bol (switch `per.tur)]            ::  me = X, ze = O
             ==
  =.  tabla  print-board
  =/  icon   (get-icons per.tur)
  =/  guest  (need ~(top to opos))
  :_  +>.$(who me)                                      ::  now is our turn
  :_  ~
  %-  effect
  :~  %mor
      tabla
      (prompt " | {<me>}:[{+:icon}] <- {<ze.guest>}:[{-:icon}] | ")
  ==
::
++  unsubscribe
  ^-  move
  =/  guest  (need ~(top to opos))
  [bo.guest %pull wir.guest [ze.guest dap.bol] ~]
::
++  pull-invite
  |=  wir=wire
  [~ +>]
::
++  pull-back
  |=  wir=wire
  [~ +>]
::
++  reap
  |=  [wir=wire err=(unit tang)]
  ?~  err
    [~ +>]
  :_  +>.$
  ~[(effect tan+u.err)]
::
++  poke-atom                                           ::  manual reset
  |=  a=@
  ^-  (quip move _+>)
  (wipe ~[(effect mor+~[claro welcome tabla (prompt menu-1)])])
::
++  coup
  |=  [wir=wire err=(unit tang)]
  ?~  err
    [~ +>]
  :_  +>.$
  ~[(effect tan+u.err)]
::
::  %console
::
::    %sole arms to received console moves and prompt formatting
::
+|  %console
::
++  poke-sole-action
  |=  act=sole-action:sole
  ^-  (quip move _+>)
  ::  FIXME: alias?
  ::
  =/  share  sha.consol
  ?-    -.act
    ::  clear screen
    ::
    $clr  [~ this]
    ::  enter
    ::
    $ret  ?~  buf.share  [~ this]
          ::  restart game command
          =/  try  (rust (tufa buf.share) ;~(just zap))
          ?.  =(~ try)  check-subscriptions
          ?-    game
             ::  G1: select opponent
             ::
             %opponent  ~(ge-opponent ge buf.share)
             ::  G2: wait for confirmation
             ::
             %confirm   ~(ge-confirm ge buf.share)
             ::  G3: moves start
             ::
             %start     ~(ge-start ge buf.share)
             ::  G4: end/continue?
             ::
             %replay    ~(ge-replay ge buf.share)
          ==
    ::  key press
    ::
    $det  =^  inv  sha.consol  (~(transceive sole share) +.act)
          [~ this]
  ==
::
++  peer-sole                                           ::  sole subscribes
  |=  path
  ^-  (quip move _+>)
  =.  tabla   print-board
  =.  consol  [ost.bol *sole-share:sole]
  :_  +>.$
  ~[(effect mor+~[claro welcome tabla (prompt menu-1)])]
::
++  effect
  |=  fec=sole-effect:sole
  ^-  move
  [bon.consol %diff %sole-effect fec]
::
++  transmit-sole
  |=  inv=sole-edit
  ^-  [sole-change sole-share]
  (~(transmit sole sha.consol) inv)
::
++  prompt                                              ::  game input prompt
  |=  dial=tape
  ^-  sole-effect:sole
  pro+[& %$ dial]
::
++  print-row                                           ::  pretty prints row
  |=  ro=@
  ^-  [%leaf tape]
  =/  co  1
  :-  %leaf
  %-  zing
  |-
  =/  per  (get-icon (~(get by bo) [ro co]))
  ?:  ?&(=(%4 co))
    ~
  :-  ?:  ?&(=(co %1))
        (weld (weld "    " per) " ")
      ?:  ?&(=(co %2))
        (weld (weld "| " per) " ")
      ?:  ?&(=(co %3))
        (weld (weld "| " per) " ")
      ~
  $(co (add co 1))
::
++  print-board                                         ::  pretty prints board
  =/  ro  1
  |-  ^-  table
  :-  %tan
  %-  flop
  |-
  ?:  =(ro 4)
    ~[leaf+""]
  ?:  ?&(=(ro 3))
    [(print-row ro) $(ro (add ro 1))]
  [(print-row ro) row-sep $(ro (add ro 1))]
::
++  end-message
  |=  out=outcome
  ^-  tape
  ?:(=(out %tie) " It's a tie!" " | {<who>} wins!")
::
++  check-subscriptions
  ^-  (quip move _this)
  ?:  |(?=(~ opos) ?=(~ ~(nap to opos)))                ::  one or no subs
    restart-game
  =/  opo  (need ~(top to ~(nap to opos)))              ::  always unqueue head
  =^  edit   sha.consol  (transmit-sole reset)
  :-  :~  unsubscribe
          %-  effect
          :~  %mor
              det+edit
              (prompt (weld confirm "{<ze.opo>} (Y/N)? | "))
      ==  ==
  %=  this
      bo     ~
      game   %confirm
      tabla  [%tan ~]
      opos   ::  dequeue
             ::
             ~(nap to opos)
  ==
::
++  restart-game
  ^-  (quip move _this)
  =.  bo  ~
  =.  tabla  print-board
  =^  edit  sha.consol  (transmit-sole reset)
  =/  fect  (effect mor+~[det+edit claro welcome tabla (prompt menu-1)])
  %-  wipe
  :*  fect
      ?~  opos  ~
      [unsubscribe ~]
  ==
::
::  %rules
::
::    Pattern matching on console's input
::
+|  %rules
::
++  num-rule  (shim '1' '3')
++  indice    (cook |=(a/@ (sub a '0')) num-rule)
++  position  ;~((glue fas) indice indice)              ::  e.g. [1-3]/[1-3]
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
  ^-  [outcome board]
  =.  bo  (~(put by bo) [spo.tur per.tur])
  [(outcome-check per.tur) bo]
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
  =/  c=(unit player)  (~(get by bo) b)
  ?~(c | =(per u.c))
::
++  tie-check
  =(~(wyt in bo) 9)
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
  ?~  toer  ~
  ?:(=(u.toer %o) %x %o)
::
++  get-icon
  |=  per=(unit player)
  ^-  tape
  ?~  per  " "
  (cuss (scow %tas u.per))
::
++  get-icons
  |=  per=player
  [(get-icon `per) (get-icon `(switch `per))]
::
++  toer-to-symbol
  |=  co=cord
  ^-  player
  ?:  =(co 'X')
    %x
  ?:  =(co 'O')
    %o
  ~
::
--
