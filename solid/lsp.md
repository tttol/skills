# Liskov Substitution Principle (LSP)

## Principle Definition

**"Objects of a superclass should be replaceable with objects of a subclass without breaking the application"**

If S is a subtype of T, then objects of type T may be replaced with objects of type S without altering any of the desirable properties of the program.

## Why It Matters

- **Reliable Inheritance**: Ensures inheritance hierarchies are correctly designed
- **Predictable Behavior**: Subclasses behave as clients expect based on the parent contract
- **Code Reusability**: Safe polymorphism enables flexible, reusable code
- **Reduced Bugs**: Prevents unexpected behavior when using derived classes

## Violation Example

```typescript
class Rectangle {
protected width: number;
protected height: number;

constructor(width: number, height: number) {
this.width = width;
this.height = height;
}

setWidth(width: number): void {
this.width = width;
}

setHeight(height: number): void {
this.height = height;
}

getArea(): number {
return this.width * this.height;
}
}

class Square extends Rectangle {
setWidth(width: number): void {
this.width = width;
this.height = width;
}

setHeight(height: number): void {
this.width = height;
this.height = height;
}
}

// Usage that breaks LSP
function expandRectangle(rectangle: Rectangle): void {
rectangle.setWidth(5);
rectangle.setHeight(4);
console.log(`Expected area: 20, Got: ${rectangle.getArea()}`);
}

const rect = new Rectangle(2, 3);
expandRectangle(rect); // Expected area: 20, Got: 20 ✓

const square = new Square(2, 2);
expandRectangle(square); // Expected area: 20, Got: 16 ✗
```

**Problems**:
- Square changes the behavior of Rectangle's setters
- Client code expecting Rectangle behavior gets unexpected results with Square
- Violates the substitution principle

## Improved Example

```typescript
interface Shape {
getArea(): number;
}

class Rectangle implements Shape {
constructor(
private width: number,
private height: number
) {}

setWidth(width: number): void {
this.width = width;
}

setHeight(height: number): void {
this.height = height;
}

getArea(): number {
return this.width * this.height;
}
}

class Square implements Shape {
constructor(private side: number) {}

setSide(side: number): void {
this.side = side;
}

getArea(): number {
return this.side * this.side;
}
}

// Usage
function printArea(shape: Shape): void {
console.log(`Area: ${shape.getArea()}`);
}

const rect = new Rectangle(5, 4);
printArea(rect); // Area: 20

const square = new Square(4);
printArea(square); // Area: 16
```

**Improvements**:
- Rectangle and Square are separate classes implementing the same interface
- No inheritance relationship that violates LSP
- Each class has appropriate behavior for its type
- Client code works with the Shape abstraction

## Common LSP Violations

### 1. Strengthening Preconditions

```typescript
// Violation
class Bird {
fly(altitude: number): void {
// Can fly at any altitude
}
}

class Penguin extends Bird {
fly(altitude: number): void {
if (altitude > 0) {
throw new Error("Penguins cannot fly!");
}
}
}
```

**Fix**: Don't use inheritance when "is-a" relationship doesn't hold

```typescript
interface Bird {
move(): void;
}

class FlyingBird implements Bird {
move(): void {
this.fly();
}

private fly(): void {
console.log("Flying...");
}
}

class Penguin implements Bird {
move(): void {
this.swim();
}

private swim(): void {
console.log("Swimming...");
}
}
```

### 2. Weakening Postconditions

```typescript
// Violation
class Account {
withdraw(amount: number): number {
// Always returns the withdrawn amount
return amount;
}
}

class PremiumAccount extends Account {
withdraw(amount: number): number {
// Sometimes returns less due to fees
return amount - this.calculateFees(amount);
}

private calculateFees(amount: number): number {
return amount * 0.02;
}
}
```

**Fix**: Make the contract explicit and honor it in subclasses

```typescript
abstract class Account {
abstract withdraw(amount: number): { withdrawn: number; fees: number };
}

class BasicAccount extends Account {
withdraw(amount: number): { withdrawn: number; fees: number } {
return { withdrawn: amount, fees: 0 };
}
}

class PremiumAccount extends Account {
withdraw(amount: number): { withdrawn: number; fees: number } {
const fees = amount * 0.02;
return { withdrawn: amount - fees, fees };
}
}
```

### 3. Throwing New Exceptions

```typescript
// Violation
class FileReader {
read(path: string): string {
// Never throws exceptions
return "content";
}
}

class SecureFileReader extends FileReader {
read(path: string): string {
if (!this.hasPermission(path)) {
throw new Error("Permission denied");
}
return super.read(path);
}

private hasPermission(path: string): boolean {
return false;
}
}
```

**Fix**: Handle new cases within the existing contract

```typescript
class FileReader {
read(path: string): string | null {
return "content";
}
}

class SecureFileReader extends FileReader {
read(path: string): string | null {
if (!this.hasPermission(path)) {
return null;
}
return super.read(path);
}

private hasPermission(path: string): boolean {
return true;
}
}
```

## Practical Checkpoints

1. **Contract Verification**
   - Does the subclass honor all parent class contracts?
   - Are preconditions not strengthened?
   - Are postconditions not weakened?

2. **Exception Handling**
   - Does the subclass throw new unchecked exceptions?
   - Are all parent exceptions still valid?

3. **Behavioral Consistency**
   - Does the subclass behave as clients expect?
   - Can you substitute subclass without changing program correctness?

4. **"Is-A" Relationship Test**
   - Is the inheritance relationship truly "is-a"?
   - Can you say "Square is-a Rectangle" in all contexts?

## Design by Contract Rules

For LSP compliance, subclasses must follow these rules:

1. **Preconditions cannot be strengthened**
   - If parent accepts any positive number, child cannot require numbers > 10

2. **Postconditions cannot be weakened**
   - If parent guarantees non-null return, child must also guarantee it

3. **Invariants must be preserved**
   - If parent maintains certain state constraints, child must maintain them

4. **History constraint**
   - Subclass shouldn't allow state changes that the base class doesn't allow

## Frequently Asked Questions

**Q: Does LSP mean we should avoid inheritance?**
A: No, but use inheritance only for true "is-a" relationships. Prefer composition when in doubt.

**Q: How does LSP relate to unit testing?**
A: If you can't use the same tests for base and derived classes, you might be violating LSP.

**Q: What about abstract classes?**
A: Abstract classes define contracts that concrete implementations must honor, making LSP crucial.

**Q: Can I override methods in subclasses?**
A: Yes, but overridden methods must maintain the behavioral contract of the parent method.
