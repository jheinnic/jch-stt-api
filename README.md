# STTApi
TypeScript Client API for Star Trek Timelines

This work is inspired by previous work from https://github.com/IAmPicard/STTAPI.

The long term goal is to expose the STT API through a GraphQL layer and run the reporting queries being developed in Cypher against that.  For the moment, GraphQL has not yet entered the picture.  Right now the emphasis is just on making the client API calls and then using a CSV intermediate file to load Neo4J and produce reports by direct Cypher queries againt Neo4J from there.

As a new piece of functionality, this libary uses a pure streaming approach to extracting data.  Before issuing an API call, a client user requests one or more Observables by content type.  Each requests sets up a small amount of parse pipelining targetting a specific region of the returned payload.  When execute is triggered, the STT API is called one time, and however many responses were requested are carved out of the payload as it passes through each parser, and any matching artifacts are emitted on their appropriate Observables.  

The message objects are successfully cast to strongly typed TypeScript types by virtue of a portion of the GraphQL preparation work.  The approach involved utilizing three tools: https://github.com/SOM-Research/jsonDiscoverer.git, https://github.com/hallvard/graphql-emf, and apollo-codegen (npm).  The jsonDiscoverer tool was first applied to sample JSON message bodies extracted while experimentally invoking the STT API "by hand" with curl.  This analysis tool yields an inferred EMF structural model of request and resposne message DTOs.  The second tool, graphql-emf, performs a conversion from ECore to GraphQL IDL.  And the final tool, apollo-codegen, converts the IDL into equivalent TypeScript interfaces.

model/sample.json is an example of the JSON response message passed to jsonDiscoverer
model/sttTwo.ecore is an example of the EMF model extract
model/character.idl is an example of the graphql-emf result
lib/model/index.ts is an example of the apollo-codegen conversion

The conversion is faithful enough to preserving names and types that I have been able to use the derived interfaces to typecast the responses produced by JSONParse without utilizing any GraphQL server code in the application as of yet.

After "yarn install" to run the compilation step, you should be able to run 'node dist/main.js' to run the extraction client.  This yields a crew_instance_stats.csv file and a players.csv.

Transfer the extract files to your neo4j imports directory and then pipe the contents of "import.cypher" and "v2_run_gauntlet.cypher" into a cypher-shell.  The first script parses the CSV files from the neo4j imports directory and loads them into the graph DB.  The second script runs a Gauntlet analysis and produced a report with all combinations that have a score in at least one skill area that no other retained team candidate scored better (although ties are permitted).

**DISCLAIMER** This tool is provided "as is", without warranty of any kind. Use at your own risk!
It should be understood that *Star Trek Timelines* content and materials are trademarks and copyrights of [Disruptor Beam, Inc.](https://www.disruptorbeam.com/tos/) or its licensors. All rights reserved. This tool is neither endorsed by nor affiliated with Disruptor Beam, Inc..
