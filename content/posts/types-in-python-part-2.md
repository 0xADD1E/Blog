+++
title = "Types in Python: Part 2"
date = 2020-05-06
+++
# Learning The ABCs
## What Are These "ABC"s

The Python standard library comes with a module full of descriptions of data structures - collections.abc. ABC here stands for "Abstract Base Class". These classes define certain behaviours, similar to Rust's trait system, or Swift's protocol system (or roughly like interfaces in other languages). This allows you to make code that's easily extensible, and usable in as many situations as possible. There are more than I'd like to list here, but the table at the top of the documentation is a very helpful reference guide.

## Be Generous In What You Accept, Be Strict In What You Produce

Think back to the example where we introduced generics:

```python3
from typing import List


class BlogPost:
    author: str
    contents: str

    def __init__(self, author: str, contents: str):
        self.author = author
        self.contents = contents


my_blog_posts = [BlogPost('Addie', 'This is my blog post'),
                 BlogPost('Addie', 'This is another post')]


def count_characters(posts: List[BlogPost]) -> int:
    return sum(len(x.contents) for x in posts)


characters_in_post: int = count_characters(my_blog_posts)
print(characters_in_post)
```

What if we wanted to count the number of characters on a different type of container – something that we would in most situations think of as exactly like a list, but isn't (technically), like a deque (from collections).

```python3
from collections import deque
from typing import List


class BlogPost:
    author: str
    contents: str

    def __init__(self, author: str, contents: str):
        self.author = author
        self.contents = contents


my_blog_posts = deque([BlogPost('Addie', 'This is my blog post'),
                       BlogPost('Addie', 'This is another post')])


def count_characters(posts: List[BlogPost]) -> int:
    return sum(len(x.contents) for x in posts)


characters_in_post: int = count_characters(my_blog_posts)
print(characters_in_post)
```

```
$ python3 14_mismatched_types.py
40
$ mypy 14_mismatched_types.py
14_mismatched_types.py:22: error: Argument 1 to "count_characters" has incompatible type "deque[BlogPost]"; expected "List[BlogPost]"
Found 1 error in 1 file (checked 1 source file)
```

Our code works just fine, but the type checker isn't so sure. In this case, we need to tell it we don't care about something being a `List` specifically, just something that fits our use – it needs to have a finite length, and produce `BlogPost`s when we iterate over it.

For this, something like `Sequence` is perfect. Looking in the table at the top of the [collections.abc documentation](https://docs.python.org/3/library/collections.abc.html#collections-abstract-base-classes) tells us that a `Sequence` only has to implement `__len__`, and `__getitem__`.

```python3
from collections import deque
from typing import List, Sequence


class BlogPost:
    author: str
    contents: str

    def __init__(self, author: str, contents: str):
        self.author = author
        self.contents = contents


my_blog_posts = deque([BlogPost('Addie', 'This is my blog post'),
                       BlogPost('Addie', 'This is another post')])


def count_characters(posts: Sequence[BlogPost]) -> int:
    return sum(len(x.contents) for x in posts)


characters_in_post: int = count_characters(my_blog_posts)
print(characters_in_post)
```

```
$ python3 15_sequence.py
40
$ mypy 15_sequence.py
Success: no issues found in 1 source file
```

Now the type checker knows exactly what we're after, and can help us make sure that aligns with reality.
