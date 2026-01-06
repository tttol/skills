---
name: solid-principles
description: Reviews and improves code based on SOLID principles in object-oriented programming
---

# SOLID Principles

## What are SOLID Principles?

SOLID principles are five design principles for creating maintainable, extensible, and understandable software:

1. **S**ingle Responsibility Principle
   - A class should have only one responsibility
   - There should be only one reason to change

2. **O**pen/Closed Principle
   - Open for extension, closed for modification
   - New functionality should be added without changing existing code

3. **L**iskov Substitution Principle
   - Subclasses should be substitutable for their base classes
   - Inheritance relationships should be properly designed

4. **I**nterface Segregation Principle
   - Clients should not be forced to depend on methods they don't use
   - Many small, specific interfaces are better than one large interface

5. **D**ependency Inversion Principle
   - High-level modules should not depend on low-level modules
   - Both should depend on abstractions

## Detailed Documentation

For in-depth explanations with code examples, refer to:
- [Single Responsibility Principle Details](srp.md)
- [Open/Closed Principle Details](ocp.md)
- [Liskov Substitution Principle Details](lsp.md)
- [Interface Segregation Principle Details](isp.md)
- [Dependency Inversion Principle Details](dip.md)

## Instructions

For the provided code, please:

1. Analyze the code from SOLID principles perspective
2. Identify which principles are violated and explain why
3. Check the following aspects:
   - Does each class/function have a single responsibility?
   - Is the design extensible without modifying existing code?
   - Are inheritance relationships properly designed?
   - Are interfaces appropriately segregated?
   - Are dependencies managed through abstractions?
4. Provide specific improvement suggestions with refactoring examples
5. Explain how the improved code complies with SOLID principles
6. Highlight the benefits of the refactored design

## Examples

### Example 1: Analyzing a User Management Class

**Input:**
```python
class UserManager:
def __init__(self):
self.db = Database()

def create_user(self, name, email):
user = User(name, email)
self.db.save(user)
self.send_welcome_email(email)
return user

def send_welcome_email(self, email):
# Email sending logic
pass
```

**Analysis:**
This code violates the Single Responsibility Principle (SRP). The UserManager class has two responsibilities:
1. Managing user persistence
2. Sending emails

**Suggested Refactoring:**
```python
class UserRepository:
def __init__(self, db):
self.db = db

def save(self, user):
self.db.save(user)

class EmailService:
def send_welcome_email(self, email):
# Email sending logic
pass

class UserService:
def __init__(self, user_repository, email_service):
self.user_repository = user_repository
self.email_service = email_service

def create_user(self, name, email):
user = User(name, email)
self.user_repository.save(user)
self.email_service.send_welcome_email(email)
return user
```

### Example 2: Open/Closed Principle Violation

**Input:**
```typescript
class PaymentProcessor {
process(amount: number, method: string) {
if (method === 'credit_card') {
// Process credit card
} else if (method === 'paypal') {
// Process PayPal
}
}
}
```

**Analysis:**
Violates Open/Closed Principle. Adding new payment methods requires modifying existing code.

**Suggested Refactoring:**
```typescript
interface PaymentMethod {
process(amount: number): void;
}

class CreditCardPayment implements PaymentMethod {
process(amount: number): void {
// Process credit card
}
}

class PayPalPayment implements PaymentMethod {
process(amount: number): void {
// Process PayPal
}
}

class PaymentProcessor {
processPayment(amount: number, method: PaymentMethod): void {
method.process(amount);
}
}
```

### Example 3: Dependency Inversion Principle

**Input:**
```java
class OrderService {
private MySQLDatabase db = new MySQLDatabase();

public void saveOrder(Order order) {
db.save(order);
}
}
```

**Analysis:**
Violates Dependency Inversion Principle. High-level OrderService depends on low-level MySQLDatabase concrete implementation.

**Suggested Refactoring:**
```java
interface Database {
void save(Order order);
}

class MySQLDatabase implements Database {
public void save(Order order) {
// MySQL implementation
}
}

class OrderService {
private Database db;

public OrderService(Database db) {
this.db = db;
}

public void saveOrder(Order order) {
db.save(order);
}
}
```
