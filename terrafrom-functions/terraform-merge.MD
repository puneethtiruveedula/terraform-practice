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


```

