::
::::  /sur/toe/hoon
  ::
|%
+=  board     (map spot player)
+=  row       [%leaf tape]
+=  table     [%tan rows=(list row)]
+=  outcome   ?(%wins %tie ~)
+=  player    ?(%x %o ~)
+=  spot      [x=num y=num]
+=  turno     [=player =spot]
+=  num       ?(%1 %2 %3)
+=  opts      ?(%1 %2 %3 %4)
+=  restart   (unit %0)
+=  invite    [player restart]
+=  winner    [out=tape tur=turno]
+=  request   [=bone =ship]
+=  requests  (list request)
--
