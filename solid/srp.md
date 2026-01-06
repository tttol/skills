# Single Responsibility Principle (SRP)

## Principle Definition

**"A class should have only one reason to change"**

A class or module should have only one responsibility. In other words, a class should be responsible to only one actor.

## Why It Matters

- **Improved Maintainability**: Changes are localized and impact is limited
- **Easier Testing**: Classes with single responsibility are easier to test
- **Better Reusability**: Separated responsibilities make classes more reusable in different contexts
- **Better Readability**: Clear purpose makes code easier to understand

## Violation Example

```python
class User:
def __init__(self, name, email):
self.name = name
self.email = email

def save_to_database(self):
# Database logic
pass

def send_email(self, message):
# Email sending logic
pass

def generate_report(self):
# Report generation logic
pass
```

**Problems**:
- Has three different responsibilities: database operations, email sending, and report generation
- Any change to database, email, or reporting requires modifying this class
- Violates single responsibility principle

## Improved Example

```python
class User:
def __init__(self, name, email):
self.name = name
self.email = email

class UserRepository:
def save(self, user):
# Database logic
pass

class EmailService:
def send(self, recipient, message):
# Email sending logic
pass

class UserReportGenerator:
def generate(self, user):
# Report generation logic
pass
```

**Improvements**:
- Each class has a single responsibility
- Each class has only one reason to change
- Easier to test
- Each functionality can be reused independently

## Practical Checkpoints

### When Designing Classes

1. Does the class name end with "Manager", "Handler", or "Util"?
   - These are signs of unclear responsibility

2. Are there too many methods?
   - Be cautious if there are more than 10 methods

3. Can you describe the class responsibility with "and"?
   - "Manages user information **and** sends emails" → Multiple responsibilities

### When Designing Methods

1. Does the method name contain multiple verbs?
   - `saveAndSendEmail()` → Two responsibilities

2. Is the method too long?
   - Be cautious if over 20 lines

3. Are multiple abstraction levels mixed?
   - High-level logic mixed with low-level details

## Frequently Asked Questions

**Q: How granular should the separation be?**
A: Separate when reasons to change differ. Over-separation can increase complexity, so balance is important.

**Q: Do data classes have no responsibility?**
A: Holding data is a responsibility. However, operations on that data should be delegated to other classes.

**Q: Should all classes follow this principle?**
A: Ideally yes, but simple data structures like DTOs or Value Objects can be exceptions.
