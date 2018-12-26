::
::::  /sur/toe/hoon
  ::
|%
+=  table       [%tan (list [%leaf tape])]
+=  outcome     ?(%wins %tie ~)
+=  player      ?(%x %o ~)
+=  num         ?(%1 %2 %3)
+=  spot        [num num]
+=  board       (map spot player)
+=  opts        ?(%opponent %confirm %start %replay)
+=  sub         [? bo=bone wir=wire ze=ship]
+=  subs        (qeu sub)
+=  message     ?(%accept %rematch)
+=  toe-player  [msg=message per=player]              :: mark types
+=  toe-winner  [out=tape tur=toe-turno]              :: same name as the mark
+=  toe-turno   [per=player spo=spot]                 :: file?
--
