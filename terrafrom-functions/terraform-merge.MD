# Terraform Merge Lists: Effective Use

## Understanding Terraform Merge Lists
A list is an ordered collection of the same data type values. In Terraform, lists are used extensively to manage the configuration and resources. Terrafrom list can be used to define server IPs, resource tags, or other configuration items.

## Why Merge Lists in Terraform?
Terraform Merge Lists simplify complex configurations and provide modular and reusable code structure. Combining the multiple lists into a single list you can reduce the code complexity and make your configuration more readable and maintainable

## Common Use Case for Merging Lists

### Terraform merge lists are useful in various scenarios:

* Combine the multiple modules’ resource tags.

* Aggregate IP addresses from different sources.

* Merge the different configurations into one.

## Methods to Merge Lists in Terraform

### 1. Use the “merge” Function
The `merge function` in Terraform is used to combine multiple maps into a single map. It takes n number of maps as an argument and returns a single map that contains all the elements. if the key is present in multiple inputs, the value from the last map with the key is used.

```
variable "map1" {
  type    = map(string)
  default = {
    key1 = "value1"
    key2 = "value2"
  }
}

variable "map2" {
  type    = map(string)
  default = {
    key2 = "override_value2"
    key3 = "value3"
  }
}

output "merged_map" {
  value = merge(var.map1, var.map2)
}
```

`var.map1` and `var.map2` are merged into a single map, resulting in:

```
{
  key1 = "value1"
  key2 = "override_value2"
  key3 = "value3"
}
```

### 2. Use the “concat” Function
The concat function is designed to merge lists. The concate function takes multiple lists as an argument and returns a list containing all the values in a single list.

```
variable "list1" {
  type    = list(string)
  default = ["apple", "banana"]
}

variable "list2" {
  type    = list(string)
  default = ["cherry", "date"]
}

output "merged_list" {
  value = concat(var.list1, var.list2)
}
```

`var.list1` and `var.list2` are merged into a single list using the concat function, resulting in:

["apple", "banana", "cherry", "date"]

## Terraform Merge Lists: Advanced

### 1. Terraform Merge Lists Maps

We define the map of objects with `{}` The `merge` function combines multiple maps into a single map. This is useful for aggregating the configuration from various sources.

```
locals {
  team1 = {
    alice = "developer"
    bob   = "designer"
    carol = "manager"
  }
  
  team2 = {
    dave     = "developer"
    eve      = "analyst"
    frank    = "tester"
  }
}

output "merged_team" {
  value = merge(local.team1, local.team2)
}
```

In this example, `local.team1` and `local.team2` are merged into a single map using the merge function. The resulting map is:

```
{
  alice = "developer"
  bob   = "designer"
  carol = "manager"
  dave  = "developer"
  eve   = "analyst"
  frank = "tester"
}
```

### 2. Terraform Merge Lists of Objects

Terraform does not have a built-in function for merging a list of objects, but you can use the `concat function`

```locals {
  fruits1 = [
    { name = "apple", color = "red" },
    { name = "banana", color = "yellow" }
  ]

  fruits2 = [
    { name = "grape", color = "purple" },
    { name = "lemon", color = "yellow" }
  ]

  combined_fruits = [for fruit in concat(local.fruits1, local.fruits2) : fruit]
}

output "combined_fruits" {
  value = local.combined_fruits
}
```

In this example, `local.fruits1` and `local.fruits2` are concatenated and then iterated over using a for expression to produce a single merged list:

```
[
    { name = "apple", color = "red" },  
    { name = "banana", color = "yellow" },  
    { name = "grape", color = "purple" },  
    { name = "lemon", color = "yellow" }
]
```

### 3. Terraform Merge Lists Using “flatten”

Another way to merge lists of objects is by using the `flatten function`.

```
locals {
  nested_lists = [
    [
      { name = "tomato", type = "vegetable" },
      { name = "carrot", type = "vegetable" }
    ],
    [
      { name = "strawberry", type = "fruit" },
      { name = "blueberry", type = "fruit" }
    ]
  ]

  flat_list = flatten(local.nested_lists)
}

output "flat_list" {
  value = local.flat_list
}
```

In this example, `local.nested_lists` is flattened into a single list using the flatten function:

```
[
  { name = "tomato", type = "vegetable" },
  { name = "carrot", type = "vegetable" },
  { name = "strawberry", type = "fruit" },
  { name = "blueberry", type = "fruit" }
]
```

### 4. Terraform Merge Tags

One common use case for using the `merge` the function is to “merge lists” of tags applied to cloud resources.

```
locals {
  base_tags = {
    Application = "MyApp"
    Owner       = "DevTeam"
  }

  additional_tags = {
    Environment = "Production"
    Region      = "us-west-2"
  }

  merged_tags = merge(local.base_tags, local.additional_tags)
}

output "merged_tags" {
  value = local.merged_tags
}
```

This example merges `local.base_tags` and `local.additional_tags` into a single map of tags:

```
{
  Application = "MyApp"
  Owner       = "DevTeam"
  Environment = "Production"
  Region      = "us-west-2"
}
```

### 5. Merging Maps with Conflicting Keys

When merging maps with conflicting keys, the value from the last map with that key will be used.

```
variable "map1" {
  type    = map(string)
  default = {
    key = "value1"
  }
}

variable "map2" {
  type    = map(string)
  default = {
    key = "value2"
  }
}

output "merged_map" {
  value = merge(var.map1, var.map2)
}
```

In this example, `var.map1` and `var.map2` both have the same key key. The value from var.map2 (“value2”) overrides the value from `var.map1` (“value1”). The resulting map is:

```
{
  key = "value2"
}
```

### 6. Merging Maps with Nested Structures

You can merge maps with nested structures. The merge is shallow, meaning it does not recursively merge nested maps.

```
variable "map1" {
  type    = map(any)
  default = {
    config = {
      param1 = "value1"
    }
  }
}

variable "map2" {
  type    = map(any)
  default = {
    config = {
      param2 = "value2"
    }
  }
}

output "merged_map" {
  value = merge(var.map1, var.map2)
}
```

Here,  `var.map1` and `var.map2` both have a nested map under the key config. The resulting map will have config from `var.map2` entirely, without merging the nested config maps:

```
{
  config = {
    param2 = "value2"
  }
}
```