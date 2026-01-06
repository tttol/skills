# Open/Closed Principle (OCP)

## Principle Definition

**"Software entities (classes, modules, functions, etc.) should be open for extension, but closed for modification"**

- **Open for extension**: New functionality can be added
- **Closed for modification**: Existing code doesn't need to be changed

## Why It Matters

- **Improved Stability**: Not changing existing code reduces risk of breaking working features
- **Better Maintainability**: Adding new features has minimal impact on existing code
- **Efficient Testing**: Only need to rerun existing tests
- **Parallel Development**: Multiple developers can add features without affecting existing code

## Violation Example

```typescript
class PaymentProcessor {
processPayment(amount: number, method: string): void {
if (method === 'credit_card') {
// Credit card processing logic
console.log(`Processing ${amount} via credit card`);
} else if (method === 'paypal') {
// PayPal processing logic
console.log(`Processing ${amount} via PayPal`);
} else if (method === 'bank_transfer') {
// Bank transfer processing logic
console.log(`Processing ${amount} via bank transfer`);
}
}
}
```

**Problems**:
- Must modify `PaymentProcessor` class every time a new payment method is added
- if-else branches keep growing, making code complex
- Risk of affecting existing payment method processing

## Improved Example

```typescript
interface PaymentMethod {
process(amount: number): void;
}

class CreditCardPayment implements PaymentMethod {
process(amount: number): void {
console.log(`Processing ${amount} via credit card`);
}
}

class PayPalPayment implements PaymentMethod {
process(amount: number): void {
console.log(`Processing ${amount} via PayPal`);
}
}

class BankTransferPayment implements PaymentMethod {
process(amount: number): void {
console.log(`Processing ${amount} via bank transfer`);
}
}

class PaymentProcessor {
processPayment(amount: number, method: PaymentMethod): void {
method.process(amount);
}
}

// Usage
const processor = new PaymentProcessor();
processor.processPayment(100, new CreditCardPayment());
processor.processPayment(200, new PayPalPayment());
```

**Improvements**:
- Adding new payment methods only requires implementing `PaymentMethod` interface
- No need to modify `PaymentProcessor` class
- Each payment method is independent and doesn't affect others

## Further Improvement: Strategy Pattern

```typescript
class PaymentContext {
private strategy: PaymentMethod;

constructor(strategy: PaymentMethod) {
this.strategy = strategy;
}

setStrategy(strategy: PaymentMethod): void {
this.strategy = strategy;
}

executePayment(amount: number): void {
this.strategy.process(amount);
}
}

// Usage
const context = new PaymentContext(new CreditCardPayment());
context.executePayment(100);

context.setStrategy(new PayPalPayment());
context.executePayment(200);
```

## Practical Implementation Patterns

### 1. Extension via Inheritance

```typescript
abstract class Report {
abstract generate(): string;

print(): void {
console.log(this.generate());
}
}

class PDFReport extends Report {
generate(): string {
return "PDF Report Content";
}
}

class ExcelReport extends Report {
generate(): string {
return "Excel Report Content";
}
}
```

### 2. Extension via Composition

```typescript
interface Filter {
apply(data: string[]): string[];
}

class DataProcessor {
private filters: Filter[] = [];

addFilter(filter: Filter): void {
this.filters.push(filter);
}

process(data: string[]): string[] {
return this.filters.reduce((result, filter) => filter.apply(result), data);
}
}
```

## Practical Checkpoints

1. **Excessive switch/if-else statements**
   - When there are many type code branches, consider polymorphism

2. **Frequently changed areas**
   - Areas requiring frequent modifications should be abstracted

3. **Need for plugin mechanism**
   - When external functionality addition is needed, define interfaces

4. **Code duplication**
   - When similar code appears multiple times, consider common abstraction

## Frequently Asked Questions

**Q: Should all if statements be replaced with polymorphism?**
A: No. If the change frequency is low and branches are few, if statements are sufficient. Over-abstraction increases complexity.

**Q: Is it realistic to never modify existing code?**
A: Complete avoidance is difficult. The key is to minimize impact and clearly define extension points.

**Q: When should abstraction be introduced?**
A: The "Rule of Three" is useful. When the same pattern appears three times, consider abstraction. Avoid premature abstraction.

**Q: What about performance impact?**
A: Polymorphism has slight overhead, but usually negligible. Long-term benefits of maintainability typically outweigh this.
