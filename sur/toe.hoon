::
::::  /sur/toe/hoon
::
|%
:: +=  grid         [%tan (list [%leaf tape])]
+=  grid         (list [%klr styx])
+=  outcome      ?(%wins %tie ~)
+=  nought       %x
+=  cross        %o
+=  player       [stone=?(cross nought ~) color=tint]
+=  num          ?(%1 %2 %3)
+=  spot         [num num]
+=  board        (map spot player)
+=  game         ?(%opponent %confirm %start %replay)
+=  remote-app   ::  $in: for incoming subscriptions
                 ::    used when a ship sends a %peer
                 ::  $out: for outgoing subscriptions
                 ::    used when we %peer a ship
                 ::
                [ze=ship subs=[in=bone out=bone]]
+=  subscribers  ::  Gall has prey:pubsub:userlib to get the list
                 ::  of subscribers.
                 ::  It uses a
                 ::    $bitt: (map bone (pair ship path))
                 ::  to track  incoming subs
                 ::  TODO: don't reinvent the wheel and just use
                 ::        the queue to track the order or subs.
                 ::
                (qeu remote-app)
+=  message      ?(%accept %rematch)
::
::  Marks sent in each move, as defined in %/mar/toe/
::
+=  toe-player   [msg=message per=player]
+=  toe-winner   [out=tape tur=toe-turno]
+=  toe-turno    [per=player spo=spot]
+=  toe-cancel   %bye
--
