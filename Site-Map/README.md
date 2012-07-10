**site-map.xml**

* Creates a nested unordered list with links to Page assets and titles of parent Folders. It nests subfolders with `<ul>` nodes completely inside of `<li>` nodes.
* Takes into account a check for Title, Display Name, and System Name. You won't have to worry about whether or not certain Metadata Fields are filled out. It will fall back to the System Name of the asset if no Title or Display Name is found.