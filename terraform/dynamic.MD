# Terraform Dynamic Blocks

Terraform Dynamic Blocks allow you to define reusable components in your infrastructure with a single set of parameters. This improves the flexibility and code reuse as well as provides a way to manage all of your configurations in one place.

If we have multiple blocks to be created, instead of duplicated code we can use dynamic blocks. For example ingress rule in security groups, NACL rules, etc.

### Key-Benefits using Dynamic Block
* Reusable
* clarity
* speed

### Dynamic Block Components
As a terraform developer we can define dynamic block inside of resource, data, provider etc.…

dynamic block consists of following components,

* label
* for_each
* iterator
* content

### Syntax

```
dynamic "ingress"{ # this ingress block will be created multiple times
    for_each = some variable like list/map to iterate
    content{
        # content will get values from list/map
    }
}
```

### Nested Blocks

```
resource "aws_security_group" "mysg" {
  name        = "webserver"
  description = "Inbound Rules for WebServer"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

code create security group with 2 inbound rules. The ingress parameter is repeatable multiple times.

### Dynamic Nested Block

```
locals {
  ports = [80, 22, 443]
}
resource "aws_security_group" "mysg" {
  name        = "webserver"
  description = "Inbound Rules for WebServer"

  dynamic "ingress" {
    for_each = local.ports
    content {
      description = "description ${ingress.key}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```

lets check another example with attributes lists and map,

### Dynamic Block with attribute list and map

```
locals {
  rules = [{
    description = "HTTP",
    port = 80,
    cidr_blocks = ["0.0.0.0/0"],
  },{
    description = "SSH",
    port = 22,
    cidr_blocks = ["10.0.0.0/16"],
  },{
    description = "HTTPS",
    port = 443,
    cidr_blocks = ["0.0.0.0/0"],
  }]
}
resource "aws_security_group" "mysg" {
  name        = "webserver"
  description = "Inbound Rules for WebServer"

  dynamic "ingress" {
    for_each = local.rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```

```
locals {
  map = {
    "HTTP" = {
      port = 80,
      cidr_blocks = ["0.0.0.0/0"],
    }
    "SSH" = {
      port = 22,
      cidr_blocks = ["10.0.0.0/16"],
    }
    "HTTPS" = {
      port = 443,
      cidr_blocks = ["0.0.0.0/0"],
    }
  }
}
resource "aws_security_group" "mysg" {
  name        = "webserver"
  description = "Inbound Rules for WebServer"

  dynamic "ingress" {
    for_each = local.map
    content {
      description = ingress.key
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```

we can also use `iterator` with `dynamic block` but it is optional. In case of `nested dynamic block` , it is important to use `iterator`.

```
locals {
  map = {
    "HTTP" = {
      port = 80,
      cidr_blocks = ["0.0.0.0/0"],
    }
    "SSH" = {
      port = 22,
      cidr_blocks = ["10.0.0.0/16"],
    }
    "HTTPS" = {
      port = 443,
      cidr_blocks = ["0.0.0.0/0"],
    }
  }
}
resource "aws_security_group" "mysg" {
  name        = "webserver"
  description = "Inbound Rules for WebServer"

  dynamic "ingress" {
    for_each = local.map
    iterator = each
    content {
      description = each.key
      from_port   = each.value.port
      to_port     = each.value.port
      protocol    = "tcp"
      cidr_blocks = each.value.cidr_blocks
    }
  }
}
```