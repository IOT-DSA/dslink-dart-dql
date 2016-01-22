# DQL DSLink

This is a DSLink-based mockup of what DQL (Distributed Query Language) should be like.

DQL acts upon the connected broker and it's network.

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
list * | subscribe $name
```

#### Subscribe to all values in a DSLink, and create a table of the name and the value

```
list /downstream/System/* | filter $type | subscribe $name value
```

#### Subscribe to all values in a DSLink, where @unit is not equal to "%"

```
list /downstream/System/* | filter $type @unit!="%" | subscribe
```

#### Subscribe to all numbers in a DSLink, and add a column that multiplies the value by 2

```
list * | filter $type="number" | subscribe | expression double="val * 2"
```

#### Subscribe to the 'of' (Open Files) child of each database in etsdb

```
list /downstream/etsdb/? | subscribe of
```

#### Build a table of all values in the network and what types they are

```
list * | filter $type | subscribe $type
```
