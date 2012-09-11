**site-map.xml**

* Creates a nested unordered list with links to Page assets and titles of parent Folders. It nests subfolders with `<ul>` nodes completely inside of `<li>` nodes.
* Takes into account a check for Title, Display Name, and System Name. You won't have to worry about whether or not certain Metadata Fields are filled out. It will fall back to the System Name of the asset if no Title or Display Name is found.

**index-block-to-site-protocol.xsl**
* Creates a site map that adheres to the [Sitemaps.org Porotocol](http://www.sitemaps.org/), which is the preferred site map protocol for most popular search engines.
* Requirements: 
** An Index Block indexing all pages that need to be included in the site map. The index block must also include **System Metadata** if you wish to add the `<lastmod>` element to the site map.
** A Template containing only `<system-region name="DEFAULT" />`, with no root node surrounding the region.