--- 
title: Example Notice
active: true
type: maintenance
created_at: 2012-02-20 10:00
eta: 2012-02-22 10:00
expire: 2012-03-20 10:00
kind: article
affects: [overlays, forums, bugzilla]
force_state: maintenance
---

Here you can add text in the markdown format.

Parameters above:
title: self-explanatory
active: set this to false to completely hide the notice
type: (maintenance|information|outage) sets the icon
created_at: self-explanatory
eta: estimated time the service is restored (optional)
expire: when to hide the notice. defaults to one week (optional)
kind: set to 'article' (mandatory!)
affects: array of services this notice affects (TODO list, optional)
force_state: (maintenance|up|down) force the state of all services this notice applies to to this state (optional)

