# DQL

DQL is a distributed query language for DSA.
DQL can act both as a DSLink and an embedded library into a DSLink.

DQL acts upon the connected broker by default.

## Multi-Broker Queries

DQL shields the `list` query command from listing nodes on other brokers.
This prevents massive queries that can cause a slowdown. This only applies to the `list` command.

To enable multi-broker list queries, add the following command at the front of your query:

```
option traverseBrokers=true |
```

## QOS Subscriptions

DQL uses QOS `0` by default for value subscriptions. You can configure what QOS a query will use by adding the following command
in any position in front of the subscribe command where `1` is any of `0 1 2 3`:

```
option qos=1 |
```

## Syntax

![Syntax Tree](https://raw.githubusercontent.com/IOT-DSA/dslink-dart-dql/master/tool/diagram.png)

## Query Examples

#### List all nodes in the network

```
list *
```

#### List all values

```
list * | filter $type
```

#### Subscribe to all values

```
list * | filter $type | subscribe
```

#### Subscribe to all strings

```
list * | filter $type="string" | subscribe
```

#### Subscribe to all numbers

```
list * | filter $type="number" | subscribe
```

#### Subscribe to all values that have the @mytag attribute

```
list * | filter @mytag | subscribe
```

#### Create a table all nodes to their names

```
list * | subscribe :name
```

#### Subscribe to all values in a DSLink, and create a table of the name and the value

```
list /downstream/System/* | filter $type | subscribe :name value
```

#### Subscribe to all values in a DSLink, where @unit is not equal to "%"

```
list /downstream/System/* | filter $type @unit!="%" | subscribe
```

#### Subscribe to all numbers in the network, and add a column that multiplies the value by 2

```
list * | filter $type="number" | subscribe | expression double="row.value * 2"
```

#### Subscribe to the 'of' (Open Files) child of each database in etsdb

```
list /downstream/etsdb/? | subscribe of
```

#### Build a table of all values in the network and what types they are

```
list * | filter $type | subscribe $type
```

#### Concatenate a string with each value in the network

```
list * | filter $type | subscribe | expression msg="'Value: ' + row.value"
```

#### Calculate the minimum of 50 and the number values in the network

```
list * | filter $type="number" | subscribe | expression min="Math.min(50, row.value)"
```

#### Subscribe to children on a single path

```
path /downstream/System | subscribe Memory_Usage
```

### Publish multiple points to MongoDB

```
list /downstream/System | filter :metric | subscribe | invoke /downstream/MongoDB/local/SystemValues/publish(Path=%path, Value=%value)
```

### List all brokers

```
list brokers
```

### List nodes with multiple expressions

```
list /downstream, /upstream, /sys
```

### List nodes under each broker

```
list brokers | sublist /downstream/?
```
