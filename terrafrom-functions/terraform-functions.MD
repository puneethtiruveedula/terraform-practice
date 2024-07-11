# Terraform Functions

## slice
`slice` extracts some consecutive elements from within a `list`.

```
slice(list, startindex, endindex)
```

`startindex` is inclusive, while `endindex` is exclusive. This function returns an error if either index is outside the bounds of valid indices for the given list.

```
> slice(["a", "b", "c", "d"], 1, 3)
[
  "b",
  "c",
]
```

## element
`element` retrieves a single element from a list.

```
element(list, index)
```

The index is zero-based. This function produces an error if used with an empty list. The index must be a non-negative integer.

Use the built-in index syntax `list[index]` in most cases. Use this function only for the special additional "wrap-around" behavior described below.

#### Examples

```
> element(["a", "b", "c"], 1)
b
```
If the given index is greater than the length of the list then the index is "wrapped around" by taking the index modulo the length of the list:
```
> element(["a", "b", "c"], 3)
a
```
To get the last element from the list use `length` to find the size of the list (minus 1 as the list is zero-based) and then pick the last element:
```
> element(["a", "b", "c"], length(["a", "b", "c"])-1)
c
```