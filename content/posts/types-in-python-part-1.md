+++
title = "Types in Python: Part 1"
date = 2020-03-05
+++
# The Basics

## Getting Started

The basics of type annotations in Python 3.6 and up are quite easy. You write some code with annotations like so...

```python
my_blog_post: str = 'This is my blog post'


def count_characters(post: str) -> int:
    return len(post)


characters_in_post: int = count_characters(my_blog_post)
print(characters_in_post)
```

...and then you can check it using a type checker such as MyPy

```
$ python3 00_basic.py
20
$ mypy 00_basic.py
Success: no issues found in 1 source file
```

No issues, nice!

But what happens if we had made a mistake when writing our code? Let's say we forgot to call len, for instance

```python
my_blog_post: str = 'This is my blog post'


def count_characters(post: str) -> int:
    return post


characters_in_post: int = count_characters(my_blog_post)
print(characters_in_post)
```

```
$ python3 01_basic_with_issues.py
This is my blog post
$ mypy 01_basic_with_issues.py
01_basic_with_issues.py:5: error: Incompatible return value type (got "str", expected "int")
Found 1 error in 1 file (checked 1 source file)
```

The code runs, but produces a value we weren't expecting. MyPy however, catches this and warns us about it.

This works great for code only involving primitive types, but what if we want to use something more complex? Classes can also be used as annotations, just like you'd expect.

```python
class BlogPost:
    author: str
    contents: str

    def __init__(self, author: str, contents: str):
        self.author = author
        self.contents = contents


my_blog_post = BlogPost('Addie', 'This is my blog post')


def count_characters(post: BlogPost) -> int:
    return len(post.contents)


characters_in_post: int = count_characters(my_blog_post)
print(characters_in_post)
```

```
$ python3 02_basic_with_class.py
20
$ mypy 02_basic_with_class.py
Success: no issues found in 1 source file
```

What about some of Python's data structures though, like list or dict? You might be tempted to just annotate them with list and dict like so...

```python
class BlogPost:
    author: str
    contents: str

    def __init__(self, author: str, contents: str):
        self.author = author
        self.contents = contents


my_blog_posts = [BlogPost('Addie', 'This is my blog post'),
                 BlogPost('Addie', 'This is another post')]


def count_characters(posts: list) -> int:
    return sum(len(x.contents) for x in posts)


characters_in_post: int = count_characters(my_blog_posts)
print(characters_in_post)
```

```
$ python3 03_basic_with_list.py
40
$ mypy 03_basic_with_list.py
Success: no issues found in 1 source file
```

...and as we can see, it works just fine. However, there's a way that we can provide the type checker with more information about what we're doing here, and allow it to catch more issues in our code – Generics!

## The Standard Library

### Generics

In our previous example, we had a list. However, the type checker wouldn't be able to validate anything about the objects in the list. For example, what if we tried to access a field that doesn't exist?

```python
class BlogPost:
    author: str
    contents: str

    def __init__(self, author: str, contents: str):
        self.author = author
        self.contents = contents


my_blog_posts = [BlogPost('Addie', 'This is my blog post'),
                 BlogPost('Addie', 'This is another post')]


def count_characters(posts: list) -> int:
    return sum(len(x.this_doesnt_exist) for x in posts)


characters_in_post: int = count_characters(my_blog_posts)
print(characters_in_post)
```

```
$ python3 04_why_not_list.py
Traceback (most recent call last):
  File "04_why_not_list.py", line 18, in <module>
    characters_in_post: int = count_characters(my_blog_posts)
  File "04_why_not_list.py", line 15, in count_characters
    return sum(len(x.this_doesnt_exist) for x in posts)
  File "04_why_not_list.py", line 15, in <genexpr>
    return sum(len(x.this_doesnt_exist) for x in posts)
AttributeError: 'BlogPost' object has no attribute 'this_doesnt_exist'
$ mypy 04_why_not_list.py
Success: no issues found in 1 source file
```

Uh oh! MyPy said there's nothing wrong with our code, but it crashed. This is because MyPy falls back into a more compatible mode, to work with code that has less type annotations. So, how can we inform it of what's actually in our list? With the generic List type from the typing module.

```python
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
    return sum(len(x.this_doesnt_exist) for x in posts)


characters_in_post: int = count_characters(my_blog_posts)
print(characters_in_post)
```

```
$ mypy 05_introducing_generics.py
05_introducing_generics.py:18: error: "BlogPost" has no attribute "this_doesnt_exist"
Found 1 error in 1 file (checked 1 source file)
```

That's more like it. If we tell the type checker more about our code, it can tell us ahead of time what won't work without having to actually run our code. Let's go ahead and fix that based on MyPy's feedback.

```python
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

```
$ python3 06_fixing_generics.py
40
$ mypy 06_fixing_generics.py
Success: no issues found in 1 source file
```

But, lists aren't the only thing we can tell it about. The typing module includes similar generic types for virtually any of Python's container types (List, Dict, Set, Tuple, items from collections, and more).
Tuples

Now that we've gotten the container data structure explained nicely to anyone using our code, can we improve the BlogPost data type itself? Tuples are data-only, immutable, and lighter weight than a class (both in runtime cost, and cognitive complexity), and are often a good way of doing this.

```python
from typing import Tuple

my_blog_post = ('Addie', 'This is my blog post')


def count_characters(post: Tuple[str, str]) -> int:
    _author, contents = post
    return len(contents)


characters_in_post: int = count_characters(my_blog_post)
print(characters_in_post)
```

Here we've replaced our class with a simple tuple that we know can't be mutated, and only contains data, no code. The annotation Tuple[str, str] tells us we have two items in our tuple – both of which are strings. Tuples do however have some downsides. The largest one is, it can be difficult to tell what each field represents. The standard library's solution to this is simple – Named Tuples.

### NamedTuples

Named Tuples are a simple bit of information on top of tuples that allows you to name your fields. These named tuples can also integrate very easily with the type system. For example:

```python
from typing import NamedTuple

BlogPost = NamedTuple('BlogPost', [('author', str), ('contents', str)])

my_blog_post = BlogPost('Addie', 'This is my blog post')


def count_characters(post: BlogPost) -> int:
    return len(post.contents)


characters_in_post: int = count_characters(my_blog_post)
print(characters_in_post)
```

Alternatively, we can use a class-style declaration that still gives us all the benefits of being a tuple, while being potentially easier to read (and certainly easier for IDEs to analyse).

```python
from typing import NamedTuple


class BlogPost(NamedTuple):
    author: str
    contents: str


my_blog_post = BlogPost('Addie', 'This is my blog post')


def count_characters(post: BlogPost) -> int:
    return len(post.contents)


characters_in_post: int = count_characters(my_blog_post)
print(characters_in_post)
```

### Useful Annotations

The point of the typing module is to give the type checker as much information as possible, so it can catch as many issues as possible, as early as possible. List[T] is a good example of this, but it's far from the only thing we can do.
Optional

In Python, any object can be None at any point in time. However, we can force consumers of our APIs to deal with this case by annotating something as Optional[T]. In this case, the person calling a method will be forced to account for the possibility of a None value, which should eliminate issues around that. MyPy will even help enforce this by requiring annotated functions to describe this. For example, we start out with some code that doesn't advertise the possibility of a None return:

```python
from typing import NamedTuple


class BlogPost(NamedTuple):
    author: str
    contents: str


my_blog_post = BlogPost('Addie', 'This is my blog post')


def count_characters(post: BlogPost) -> int:
    if not post.author:
        return None
    return len(post.contents)


characters_in_post: int = count_characters(my_blog_post)
print(characters_in_post)
```

```
$ python3 10_undocumented_optional.py
20
$ mypy 10_undocumented_optional.py
10_undocumented_optional.py:14: error: Incompatible return value type (got "None", expected "int")
Found 1 error in 1 file (checked 1 source file)
```

MyPy tells us about this possibility, and makes us fix it by documenting that we don't always return an int.

```python
from typing import NamedTuple, Optional


class BlogPost(NamedTuple):
    author: str
    contents: str


my_blog_post = BlogPost('Addie', 'This is my blog post')


def count_characters(post: BlogPost) -> Optional[int]:
    if not post.author:
        return None
    return len(post.contents)


characters_in_post: Optional[int] = count_characters(my_blog_post)
print(characters_in_post)
```

### Enum

In some cases, a function will only return a small number of possible values. For this case, enums exist. Enums allow you to define a set number of values, and tell users of your API that those are the only possible values coming from your function.

```python
from enum import Enum
from typing import NamedTuple


class BlogPost(NamedTuple):
    author: str
    contents: str


class Colour(Enum):
    RED = 1
    GREEN = 2
    BLUE = 3


my_blog_post = BlogPost('Addie', 'This is my blog post')


def color_for_author(post: BlogPost) -> Colour:
    return Colour(len(post.author) % 3)


author_colour = color_for_author(my_blog_post)
print(author_colour)
```

```
$ python3 12_enums.py
Colour.GREEN
$ mypy 12_enums.py
Success: no issues found in 1 source file
```

### NoReturn

If a function never returns, you can annotate its "return" type as NoReturn. This is potentially useful for servers, or similar. Simple as that

```python
from typing import NoReturn


def some_function() -> NoReturn:
    while(True):
        pass
```

### Any

Sometimes, to work with existing code, it's convenient to be able to have strong typing in most of your code, and opt out in very specific circumstances. For this, the Any type exists. Placing this annotation on a symbol will remove all type checking from it, while allowing code around it to work with it. Use this with great caution, please.
