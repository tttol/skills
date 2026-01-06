# Interface Segregation Principle (ISP)

## Principle Definition

**"No client should be forced to depend on methods it does not use"**

Classes should not be forced to implement interfaces they don't use. Instead of one large interface, many small, specific interfaces are preferred based on groups of methods that serve different clients.

## Why It Matters

- **Reduced Coupling**: Clients depend only on methods they actually use
- **Better Maintainability**: Changes to unused methods don't affect clients
- **Clearer Dependencies**: Interface segregation makes dependencies explicit and minimal
- **Easier Testing**: Smaller interfaces are easier to mock and test
- **Flexibility**: Easier to implement and combine multiple small interfaces

## Violation Example

```typescript
interface Worker {
work(): void;
eat(): void;
sleep(): void;
attendMeeting(): void;
writeCode(): void;
}

class HumanWorker implements Worker {
work(): void {
console.log("Working...");
}

eat(): void {
console.log("Eating lunch...");
}

sleep(): void {
console.log("Sleeping...");
}

attendMeeting(): void {
console.log("Attending meeting...");
}

writeCode(): void {
console.log("Writing code...");
}
}

class RobotWorker implements Worker {
work(): void {
console.log("Processing tasks...");
}

eat(): void {
// Robots don't eat - forced to implement unused method
throw new Error("Robots don't eat");
}

sleep(): void {
// Robots don't sleep - forced to implement unused method
throw new Error("Robots don't sleep");
}

attendMeeting(): void {
throw new Error("Robots don't attend meetings");
}

writeCode(): void {
console.log("Generating code...");
}
}
```

**Problems**:
- RobotWorker is forced to implement methods it doesn't need
- Throws exceptions for unused methods, indicating poor design
- Violates ISP by having a "fat interface"

## Improved Example

```typescript
interface Workable {
work(): void;
}

interface Eatable {
eat(): void;
}

interface Sleepable {
sleep(): void;
}

interface MeetingAttendee {
attendMeeting(): void;
}

interface Codable {
writeCode(): void;
}

class HumanWorker implements Workable, Eatable, Sleepable, MeetingAttendee, Codable {
work(): void {
console.log("Working...");
}

eat(): void {
console.log("Eating lunch...");
}

sleep(): void {
console.log("Sleeping...");
}

attendMeeting(): void {
console.log("Attending meeting...");
}

writeCode(): void {
console.log("Writing code...");
}
}

class RobotWorker implements Workable, Codable {
work(): void {
console.log("Processing tasks...");
}

writeCode(): void {
console.log("Generating code...");
}
}

// Usage
function manageWorker(worker: Workable): void {
worker.work();
}

function organizeLunch(eater: Eatable): void {
eater.eat();
}

const human = new HumanWorker();
const robot = new RobotWorker();

manageWorker(human);
manageWorker(robot);
organizeLunch(human); // Only works with Eatable
```

**Improvements**:
- Interfaces are segregated by capability
- Classes implement only the interfaces they need
- No forced implementation of unused methods
- Clients depend only on the methods they use

## Real-World Example: Printer Interfaces

### Violation

```java
interface MultiFunctionDevice {
void print(Document doc);
void scan(Document doc);
void fax(Document doc);
void photocopy(Document doc);
}

class SimplePrinter implements MultiFunctionDevice {
public void print(Document doc) {
// Print implementation
}

public void scan(Document doc) {
throw new UnsupportedOperationException("Scan not supported");
}

public void fax(Document doc) {
throw new UnsupportedOperationException("Fax not supported");
}

public void photocopy(Document doc) {
throw new UnsupportedOperationException("Photocopy not supported");
}
}
```

### Improved

```java
interface Printer {
void print(Document doc);
}

interface Scanner {
void scan(Document doc);
}

interface Fax {
void fax(Document doc);
}

interface Photocopier {
void photocopy(Document doc);
}

class SimplePrinter implements Printer {
public void print(Document doc) {
// Print implementation
}
}

class MultiFunctionPrinter implements Printer, Scanner, Fax, Photocopier {
public void print(Document doc) {
// Print implementation
}

public void scan(Document doc) {
// Scan implementation
}

public void fax(Document doc) {
// Fax implementation
}

public void photocopy(Document doc) {
// Photocopy implementation
}
}

class ScannerPrinter implements Printer, Scanner {
public void print(Document doc) {
// Print implementation
}

public void scan(Document doc) {
// Scan implementation
}
}
```

## Interface Pollution Anti-Pattern

### What is Interface Pollution?

Adding methods to interfaces that only some implementations need.

```typescript
// Polluted interface
interface DataRepository {
save(data: any): void;
findById(id: string): any;
findAll(): any[];
export(): string; // Not all repositories need export
import(data: string): void; // Not all repositories need import
cache(): void; // Not all repositories need caching
}
```

### Solution

```typescript
interface DataRepository {
save(data: any): void;
findById(id: string): any;
findAll(): any[];
}

interface Exportable {
export(): string;
}

interface Importable {
import(data: string): void;
}

interface Cacheable {
cache(): void;
}

class UserRepository implements DataRepository, Exportable {
save(data: any): void {}
findById(id: string): any {}
findAll(): any[] { return []; }
export(): string { return ""; }
}

class SessionRepository implements DataRepository, Cacheable {
save(data: any): void {}
findById(id: string): any {}
findAll(): any[] { return []; }
cache(): void {}
}
```

## Practical Checkpoints

1. **Empty Method Implementations**
   - Do any implementations have empty methods?
   - Are there methods throwing "not implemented" exceptions?

2. **Interface Size**
   - Does the interface have more than 5-7 methods?
   - Can the interface be split into smaller, cohesive groups?

3. **Client Usage Patterns**
   - Do different clients use different subsets of methods?
   - Can you group methods by client needs?

4. **Implementation Burden**
   - Are implementations forced to provide dummy methods?
   - Do implementations need to implement methods they don't care about?

## ISP and Other SOLID Principles

### ISP + SRP

Both promote high cohesion. SRP applies to classes, ISP to interfaces.

### ISP + LSP

Violating ISP often leads to LSP violations when subclasses throw exceptions for unused methods.

### ISP + DIP

Small, focused interfaces make it easier to create abstractions that high-level modules can depend on.

## Frequently Asked Questions

**Q: How small should interfaces be?**
A: Small enough that clients use all methods, but not so small that you have dozens of single-method interfaces.

**Q: Should every interface have only one method?**
A: No. Group related methods that are always used together. The key is cohesion, not size.

**Q: What about backward compatibility?**
A: When adding methods to existing interfaces, consider creating new interfaces and using adapter patterns.

**Q: Does ISP apply to abstract classes?**
A: Yes, the same principle applies. Don't force subclasses to implement methods they don't need.

**Q: How does this relate to role interfaces?**
A: Role interfaces are a direct application of ISP - define interfaces based on how clients use them, not how providers implement them.
