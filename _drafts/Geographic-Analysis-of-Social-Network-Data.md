
## Geographic Analysis of Social Network Data

### Content

* Methods for the identification of sub-graph regions that represent communities and mapping their spatial extent.
* Community detection: identify areas of the network that have high concentrations of edges that connect groups of vertices and that have low concentrations of edges between these groups.
* Finding: some community detection methods are more suitable for geographical applications than others because of the inviolable nature of topological network properties.
* Metadata consists of:
    * The username of the sender.
    * The content of the tweet.
    * The time the tweet was sent.
    * A geographical location the tweet was sent from.
    * PS: @ content in tweets are identified as the relation between two people.

### Case study

* The identification of communities based on user to user interaction and mapping the probability surface associated with membership to that community.
* Tools: igraph package in R.
* Display aspects: **Fruchterman-Reingold layout** network and network displayed over
geographic space.
* Community detection uses **Walktrap or Random Walk algorithm** to illustrate how networks can be partitioned into sub-graph areas. The Walktrap assumes that if a strong community exists within a network, then a random walker exploring the network would spend a longer time ‘trapped’ inside any given sub-graph area. Modularity provides a measure of the quality of any graph partition.
* Mapping membership to particular communities: **Kernel density estimation** can be an exploratory tool for identifying hot-spots of activity related to a specific social network cluster.