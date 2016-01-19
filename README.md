# DQL DSLink

This is a DSLink-based mockup of what DQL (Distributed Query Language) should be like.

DQL acts upon the connected broker and it's network.

## Query Examples

#### List all nodes

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
list /downstream/MyLink/* | filter $type | subscribe $name value
```
