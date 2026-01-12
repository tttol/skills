---
name: design-pattern
description: Helps understand and apply the 23 classic GoF design patterns to solve common software design problems
---

# Design Patterns

## What are Design Patterns?

Design patterns are reusable solutions to common problems in software design. This skill covers both classic GoF (Gang of Four) patterns and other widely-used design patterns.

## GoF Design Patterns

The GoF patterns are divided into three categories:

### Creational Patterns (5)

Patterns that deal with object creation mechanisms:

1. **Abstract Factory** - Provides an interface for creating families of related objects
2. **Builder** - Separates object construction from its representation
3. **Factory Method** - Defines an interface for creating objects, letting subclasses decide which class to instantiate
4. **Prototype** - Creates new objects by copying existing ones
5. **Singleton** - Ensures a class has only one instance

### Structural Patterns (7)

Patterns that deal with object composition and relationships:

1. **Adapter** - Converts one interface to another
2. **Bridge** - Separates abstraction from implementation
3. **Composite** - Composes objects into tree structures
4. **Decorator** - Adds responsibilities to objects dynamically
5. **Facade** - Provides a simplified interface to a complex subsystem
6. **Flyweight** - Shares objects to support large numbers efficiently
7. **Proxy** - Provides a surrogate or placeholder for another object

### Behavioral Patterns (11)

Patterns that deal with communication between objects:

1. **Chain of Responsibility** - Passes requests along a chain of handlers
2. **Command** - Encapsulates a request as an object
3. **Interpreter** - Defines a grammar and interpreter for a language
4. **Iterator** - Provides sequential access to elements
5. **Mediator** - Defines simplified communication between classes
6. **Memento** - Captures and restores an object's internal state
7. **Observer** - Defines a one-to-many dependency between objects
8. **State** - Allows an object to alter its behavior when state changes
9. **Strategy** - Defines a family of interchangeable algorithms
10. **Template Method** - Defines the skeleton of an algorithm
11. **Visitor** - Separates algorithms from the objects they operate on

## Quick Reference

| Pattern | Purpose | When to Use |
|---------|---------|-------------|
| Strategy | Define family of algorithms | Multiple ways to do something |
| Decorator | Add responsibilities dynamically | Extend functionality without subclassing |
| Factory Method | Create objects without specifying exact class | Defer instantiation to subclasses |
| Observer | Notify multiple objects of state changes | One-to-many dependencies |
| Singleton | Ensure single instance | Shared resource or configuration |
| Adapter | Make incompatible interfaces work together | Integrate with legacy code |
| Template Method | Define algorithm skeleton | Common algorithm with varying steps |

## Other Design Patterns

Beyond GoF patterns, this skill also covers:

### Enterprise Patterns

Patterns commonly used in enterprise application architecture:

- **Repository Pattern** - Mediates between domain and data mapping layers
- **Unit of Work** - Maintains a list of objects affected by a business transaction
- **Data Mapper** - Maps data between objects and database
- **Service Layer** - Defines application's boundary and encapsulates business logic

### Architectural Patterns

High-level patterns for structuring applications:

- **MVC (Model-View-Controller)** - Separates application into three interconnected components
- **MVVM (Model-View-ViewModel)** - Facilitates separation of UI development from business logic
- **Clean Architecture** - Creates maintainable systems independent of frameworks and UI
- **Hexagonal Architecture (Ports and Adapters)** - Isolates core logic from external concerns

### Concurrency Patterns

Patterns for handling concurrent operations:

- **Producer-Consumer** - Separates data production from consumption
- **Read-Write Lock** - Allows concurrent reads but exclusive writes
- **Thread Pool** - Manages a pool of worker threads

## Detailed Pattern Documentation

For in-depth explanations with code examples, refer to:
- [Strategy Pattern](strategy-pattern.md)
- [Decorator Pattern](decorator-pattern.md)
- [Repository Pattern](repository-pattern.md)

## Key Principles

Design patterns support these fundamental principles:

- **Program to an interface, not an implementation**
- **Favor composition over inheritance**
- **Encapsulate what varies**
- **Strive for loosely coupled designs**
- **Classes should be open for extension but closed for modification**

## Instructions

When analyzing code or design problems:

1. Identify the core problem or requirement in the provided code
2. Determine if a design pattern applies by checking:
   - Is there a recurring design problem?
   - Would a pattern provide clear benefits (flexibility, maintainability)?
   - Is the complexity justified by the problem?
3. Consider patterns from all categories (GoF, Enterprise, Architectural, Concurrency)
4. Explain which pattern(s) could help and why
5. Provide implementation guidance with code examples
6. Discuss trade-offs and alternatives
7. Ensure the pattern doesn't add unnecessary complexity
8. Highlight the benefits and potential drawbacks

### When to Use Patterns

✅ **Use patterns when:**
- You recognize a recurring design problem
- The pattern provides clear benefits (flexibility, maintainability, etc.)
- The team understands the pattern
- The complexity is justified by the problem

❌ **Avoid patterns when:**
- The problem is simple and doesn't need the complexity
- You're "pattern hunting" without a real need
- The pattern makes the code harder to understand
- It's premature optimization

## Examples

### Example 1: Strategy Pattern for Payment Processing

**Problem:**
```java
class PaymentService {
public void processPayment(double amount, String method) {
if (method.equals("credit_card")) {
// Credit card logic
} else if (method.equals("paypal")) {
// PayPal logic
} else if (method.equals("crypto")) {
// Crypto logic
}
}
}
```

**Issue:** Adding new payment methods requires modifying existing code. Multiple if-else statements make code hard to maintain.

**Recommended Pattern:** Strategy Pattern

**Solution:**
```java
interface PaymentStrategy {
void pay(double amount);
}

class CreditCardPayment implements PaymentStrategy {
public void pay(double amount) {
// Credit card logic
}
}

class PayPalPayment implements PaymentStrategy {
public void pay(double amount) {
// PayPal logic
}
}

class PaymentService {
private PaymentStrategy strategy;

public void setStrategy(PaymentStrategy strategy) {
this.strategy = strategy;
}

public void processPayment(double amount) {
strategy.pay(amount);
}
}
```

**Benefits:** Easy to add new payment methods, adheres to Open/Closed Principle, each strategy is independently testable.

### Example 2: Decorator Pattern for Coffee Shop

**Problem:** Need to add various options (milk, sugar, whipped cream) to coffee, and pricing should reflect all additions.

**Recommended Pattern:** Decorator Pattern

**Solution:**
```java
interface Coffee {
double getCost();
String getDescription();
}

class SimpleCoffee implements Coffee {
public double getCost() { return 2.0; }
public String getDescription() { return "Simple coffee"; }
}

abstract class CoffeeDecorator implements Coffee {
protected Coffee coffee;

public CoffeeDecorator(Coffee coffee) {
this.coffee = coffee;
}
}

class MilkDecorator extends CoffeeDecorator {
public MilkDecorator(Coffee coffee) { super(coffee); }

public double getCost() { return coffee.getCost() + 0.5; }
public String getDescription() { return coffee.getDescription() + ", milk"; }
}

class SugarDecorator extends CoffeeDecorator {
public SugarDecorator(Coffee coffee) { super(coffee); }

public double getCost() { return coffee.getCost() + 0.2; }
public String getDescription() { return coffee.getDescription() + ", sugar"; }
}

// Usage
Coffee coffee = new SimpleCoffee();
coffee = new MilkDecorator(coffee);
coffee = new SugarDecorator(coffee);
// Cost: 2.7, Description: "Simple coffee, milk, sugar"
```

**Benefits:** Add functionality dynamically at runtime, avoids explosion of subclasses, follows Single Responsibility Principle.

### Example 3: Observer Pattern for Stock Market

**Problem:** Multiple displays need to update when stock prices change.

**Recommended Pattern:** Observer Pattern

**Solution:**
```typescript
interface Observer {
update(stock: string, price: number): void;
}

class Stock {
private observers: Observer[] = [];
private prices: Map<string, number> = new Map();

attach(observer: Observer): void {
this.observers.push(observer);
}

setPrice(stock: string, price: number): void {
this.prices.set(stock, price);
this.notifyObservers(stock, price);
}

private notifyObservers(stock: string, price: number): void {
this.observers.forEach(observer => observer.update(stock, price));
}
}

class StockDisplay implements Observer {
update(stock: string, price: number): void {
console.log(`Display: ${stock} is now $${price}`);
}
}

class StockAlert implements Observer {
update(stock: string, price: number): void {
if (price > 100) {
console.log(`Alert: ${stock} exceeded $100!`);
}
}
}

// Usage
const stock = new Stock();
stock.attach(new StockDisplay());
stock.attach(new StockAlert());
stock.setPrice("AAPL", 150); // Both observers notified
```

**Benefits:** Loose coupling between subject and observers, supports broadcast communication, easy to add new observers.

## Common Pitfalls

1. **Overuse** - Don't force patterns where they don't fit
2. **Premature abstraction** - Wait until you have a real need
3. **Wrong pattern** - Make sure the pattern matches the problem
4. **Complexity creep** - Patterns should simplify, not complicate
5. **Ignoring context** - Consider your specific requirements and constraints
