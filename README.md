# AvroIDLComposition
An example of using composition with AvroIDLs to compose Avro schemas

## Requirements
Install avro-tools with brew.
`brew install avro-tools`

You will also need Java installed.

## Generate Schemas

Navigate to the base of this git project. Then simply execute `./build.sh`. You should see the following output:

```
➜  AvroIDLComposition git:(main) ✗ ./build.sh
Compiling events in events
Outputting to output
Processing events/ItemClick.avdl ...
Created output/ItemClick.avsc, extracted from the generated files
Processing events/PageView.avdl ...
Created output/PageView.avsc, extracted from the generated files
Done
AvroIDLComposition git:(main) ✗
```

When you compile the AvroIDLs, the events are emitted to `output/` while the entities that make up the events are emitted into `output/generated`. You can then copy & distribute the events `output` to the associated application, register it in the schema registry, etc.

## How it works

The `entities` folder contains the base definitions of business objects for generating events. In this case, there are four:
- Item
- Merchant
- Page
- User

Each of these entities contains properties unique to its domain. 

The `events` folder contains two events, each of which are composed using a selection of `entities`. 
The `ItemClick` event is composed using `User`, `Item`, and some fields completely local to that specific event definition.
The `PageView` event is composed using `User`, `Page`, and `Merchant`, as well as its own unique local values.

This mode of event creation relies on a common repository of core entities and composition. The .avdl schema references are resolved at compile time (and not at run time). The generated .avsc files have a strict definition of the data that the event is supposed to contain _at the time the event is created_. This leads to some very powerful properties, especially when relying upon a single common-schema repo where each team manages their slice of the domain. Let's look at a common build use case:

Team A:
- Has their own private event repo `github/org/team-a`
- Has a org-wide common entity repo `github/org/common-entity`
- They want to build their events using the common compositions, to make sure that they're in line with the entity/businessObject definitions across their organization.

Team A build flow:
1) Pull down `github/org/common-entity`
2) Pull down `github/org/team-a`
3) Run their `team-a` event buildscripts, referencing the current up-to-date versions from `common-entity`
4) Assuming no errors, copy those generated events into their `resources` within their source code.
5) Generate their class files using a AVRO->(Language of Choice) code generator. (eg, Avro Maven code generator to make Java code)
6) Run their unit and integration tests against the newly generated schemas
7) Check for errors

If there are any errors against the schemas, they're caught entirely at compile and test time. Evolution to the underlying entity domain models (say `User`, or `Item`) will be reflected in your code and tests. If your code does not account for the changes, then the errors will prevent you from shipping the code.

## How to succeed with composition

A composition strategy requires cooperation between teams, but once established is very easy to adjust. The common entities remove the replication of similar-yet-different definitions across the company. You remain free to forgo using them, but they provide you with a _minimal canonical definition_ of the entity.

A common extension of the composition pattern is to use _extensions_, for example, extending `Item` by creating another entity named `ItemDetails`. This extension can contain _optional_ information about specifications, sizes, dimensions, weight, materials, etc of the item in question, without bloating the base `Item` entity.

You can leverage normal code-change practices when evolving or changing any of the `entities` components. Create a code review, flag the relevant people, and only approve merger once all have signed off. If the change follows your schema evolution rules, then you may not need to do anything at all. Alternatively, automatically send slack notifications to the teams using the entity in the definition of their events. 


If you have any questions, suggestions or changes, please open a ticket and flag me. 



 




