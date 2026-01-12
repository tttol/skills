# Strategy Pattern

## Pattern Type
**Behavioral Pattern**

## Intent

Define a family of algorithms, encapsulate each one, and make them interchangeable. Strategy lets the algorithm vary independently from clients that use it.

## Problem

You need different variants of an algorithm, and you want to switch between them at runtime without cluttering your code with conditionals.

### Common Scenarios:
- Different sorting algorithms (quick sort, merge sort, bubble sort)
- Different payment methods (credit card, PayPal, cryptocurrency)
- Different validation strategies
- Different compression algorithms
- Different route calculation methods

## Solution Structure

```
Context
  - strategy: Strategy
  + setStrategy(Strategy)
  + executeStrategy()

<<interface>> Strategy
  + execute()

ConcreteStrategyA
  + execute()

ConcreteStrategyB
  + execute()

ConcreteStrategyC
  + execute()
```

## Implementation in Java

### Basic Example: Payment System

```java
// Strategy interface
public interface PaymentStrategy {
void pay(int amount);
}

// Concrete Strategy: Credit Card Payment
public class CreditCardPayment implements PaymentStrategy {
private String cardNumber;
private String cvv;
private String expiryDate;

public CreditCardPayment(String cardNumber, String cvv, String expiryDate) {
this.cardNumber = cardNumber;
this.cvv = cvv;
this.expiryDate = expiryDate;
}

@Override
public void pay(int amount) {
System.out.println("Paid $" + amount + " using Credit Card: " +
maskCardNumber(cardNumber));
}

private String maskCardNumber(String cardNumber) {
return "**** **** **** " + cardNumber.substring(cardNumber.length() - 4);
}
}

// Concrete Strategy: PayPal Payment
public class PayPalPayment implements PaymentStrategy {
private String email;
private String password;

public PayPalPayment(String email, String password) {
this.email = email;
this.password = password;
}

@Override
public void pay(int amount) {
System.out.println("Paid $" + amount + " using PayPal account: " + email);
}
}

// Concrete Strategy: Cryptocurrency Payment
public class CryptoPayment implements PaymentStrategy {
private String walletAddress;

public CryptoPayment(String walletAddress) {
this.walletAddress = walletAddress;
}

@Override
public void pay(int amount) {
System.out.println("Paid $" + amount + " using Crypto wallet: " +
walletAddress.substring(0, 10) + "...");
}
}

// Context
public class ShoppingCart {
private List<Item> items;
private PaymentStrategy paymentStrategy;

public ShoppingCart() {
this.items = new ArrayList<>();
}

public void addItem(Item item) {
items.add(item);
}

public void setPaymentStrategy(PaymentStrategy paymentStrategy) {
this.paymentStrategy = paymentStrategy;
}

public int calculateTotal() {
return items.stream()
.mapToInt(Item::getPrice)
.sum();
}

public void checkout() {
if (paymentStrategy == null) {
throw new IllegalStateException("Payment strategy not set");
}

int total = calculateTotal();
paymentStrategy.pay(total);
System.out.println("Checkout completed successfully!");
}
}

// Item class
public class Item {
private String name;
private int price;

public Item(String name, int price) {
this.name = name;
this.price = price;
}

public String getName() {
return name;
}

public int getPrice() {
return price;
}
}

// Client code
public class Main {
public static void main(String[] args) {
ShoppingCart cart = new ShoppingCart();
cart.addItem(new Item("Laptop", 1200));
cart.addItem(new Item("Mouse", 25));
cart.addItem(new Item("Keyboard", 75));

// Pay with Credit Card
cart.setPaymentStrategy(
new CreditCardPayment("1234567890123456", "123", "12/25")
);
cart.checkout();

System.out.println();

// Create new cart
ShoppingCart cart2 = new ShoppingCart();
cart2.addItem(new Item("Book", 30));

// Pay with PayPal
cart2.setPaymentStrategy(
new PayPalPayment("user@example.com", "password123")
);
cart2.checkout();

System.out.println();

// Create another cart
ShoppingCart cart3 = new ShoppingCart();
cart3.addItem(new Item("Coffee", 5));

// Pay with Cryptocurrency
cart3.setPaymentStrategy(
new CryptoPayment("0x1234567890abcdef1234567890abcdef12345678")
);
cart3.checkout();
}
}
```

### Output:
```
Paid $1300 using Credit Card: **** **** **** 3456
Checkout completed successfully!

Paid $30 using PayPal account: user@example.com
Checkout completed successfully!

Paid $5 using Crypto wallet: 0x12345678...
Checkout completed successfully!
```

## Advanced Example: Sorting Algorithms

```java
// Strategy interface
public interface SortStrategy {
void sort(int[] array);
String getName();
}

// Concrete Strategy: Bubble Sort
public class BubbleSort implements SortStrategy {
@Override
public void sort(int[] array) {
int n = array.length;
for (int i = 0; i < n - 1; i++) {
for (int j = 0; j < n - i - 1; j++) {
if (array[j] > array[j + 1]) {
int temp = array[j];
array[j] = array[j + 1];
array[j + 1] = temp;
}
}
}
}

@Override
public String getName() {
return "Bubble Sort";
}
}

// Concrete Strategy: Quick Sort
public class QuickSort implements SortStrategy {
@Override
public void sort(int[] array) {
quickSort(array, 0, array.length - 1);
}

private void quickSort(int[] array, int low, int high) {
if (low < high) {
int pi = partition(array, low, high);
quickSort(array, low, pi - 1);
quickSort(array, pi + 1, high);
}
}

private int partition(int[] array, int low, int high) {
int pivot = array[high];
int i = low - 1;

for (int j = low; j < high; j++) {
if (array[j] < pivot) {
i++;
int temp = array[i];
array[i] = array[j];
array[j] = temp;
}
}

int temp = array[i + 1];
array[i + 1] = array[high];
array[high] = temp;

return i + 1;
}

@Override
public String getName() {
return "Quick Sort";
}
}

// Concrete Strategy: Merge Sort
public class MergeSort implements SortStrategy {
@Override
public void sort(int[] array) {
mergeSort(array, 0, array.length - 1);
}

private void mergeSort(int[] array, int left, int right) {
if (left < right) {
int mid = (left + right) / 2;
mergeSort(array, left, mid);
mergeSort(array, mid + 1, right);
merge(array, left, mid, right);
}
}

private void merge(int[] array, int left, int mid, int right) {
int n1 = mid - left + 1;
int n2 = right - mid;

int[] leftArray = new int[n1];
int[] rightArray = new int[n2];

System.arraycopy(array, left, leftArray, 0, n1);
System.arraycopy(array, mid + 1, rightArray, 0, n2);

int i = 0, j = 0, k = left;

while (i < n1 && j < n2) {
if (leftArray[i] <= rightArray[j]) {
array[k++] = leftArray[i++];
} else {
array[k++] = rightArray[j++];
}
}

while (i < n1) array[k++] = leftArray[i++];
while (j < n2) array[k++] = rightArray[j++];
}

@Override
public String getName() {
return "Merge Sort";
}
}

// Context
public class Sorter {
private SortStrategy strategy;

public void setStrategy(SortStrategy strategy) {
this.strategy = strategy;
}

public void sort(int[] array) {
if (strategy == null) {
throw new IllegalStateException("Sort strategy not set");
}

long startTime = System.nanoTime();
strategy.sort(array);
long endTime = System.nanoTime();

System.out.println(strategy.getName() + " completed in " +
(endTime - startTime) / 1_000_000.0 + " ms");
}
}

// Client code
public class SortingDemo {
public static void main(String[] args) {
int[] data1 = {64, 34, 25, 12, 22, 11, 90};
int[] data2 = data1.clone();
int[] data3 = data1.clone();

Sorter sorter = new Sorter();

System.out.println("Original array: " + Arrays.toString(data1));
System.out.println();

sorter.setStrategy(new BubbleSort());
sorter.sort(data1);
System.out.println("Result: " + Arrays.toString(data1));
System.out.println();

sorter.setStrategy(new QuickSort());
sorter.sort(data2);
System.out.println("Result: " + Arrays.toString(data2));
System.out.println();

sorter.setStrategy(new MergeSort());
sorter.sort(data3);
System.out.println("Result: " + Arrays.toString(data3));
}
}
```

## Key Components

1. **Strategy Interface** - Defines the common interface for all algorithms
2. **Concrete Strategies** - Implement different variations of the algorithm
3. **Context** - Maintains a reference to a Strategy object and delegates algorithm execution

## Advantages

✅ **Open/Closed Principle** - Add new strategies without modifying existing code
✅ **Single Responsibility Principle** - Each strategy is isolated in its own class
✅ **Runtime Flexibility** - Switch algorithms at runtime
✅ **Eliminates Conditionals** - Removes complex if/switch statements
✅ **Testability** - Each strategy can be tested independently

## Disadvantages

❌ **Increased Number of Classes** - Each strategy requires a new class
❌ **Client Awareness** - Clients must understand different strategies
❌ **Communication Overhead** - Context and strategies must share data

## When to Use

Use Strategy Pattern when:
- You have multiple related classes that differ only in behavior
- You need different variants of an algorithm
- An algorithm uses data that clients shouldn't know about
- A class defines many behaviors using multiple conditional statements

## When NOT to Use

Avoid Strategy Pattern when:
- You only have one or two variations
- The algorithms rarely change
- The complexity of multiple classes outweighs the benefit

## Comparison with Similar Patterns

### Strategy vs State
- **Strategy**: Client chooses which strategy to use
- **State**: Context changes its state automatically based on internal logic

### Strategy vs Template Method
- **Strategy**: Uses composition (has-a relationship)
- **Template Method**: Uses inheritance (is-a relationship)

## Real-World Examples

1. **Java Collections.sort()** - Accepts different Comparator strategies
2. **Java LayoutManager** - Different layout strategies for GUI components
3. **Spring Framework** - Different transaction strategies
4. **Payment Gateways** - Different payment processing strategies
5. **Compression Libraries** - Different compression algorithms

## Related Patterns

- **Factory Method** - Can create strategy objects
- **Flyweight** - Strategies can be implemented as flyweights
- **Decorator** - Changes object's skin vs Strategy changes its guts
- **Template Method** - Alternative approach using inheritance

## Best Practices

1. **Use interfaces** for strategy definitions
2. **Keep strategies stateless** when possible
3. **Consider functional interfaces** in Java 8+ for simple strategies
4. **Use dependency injection** to provide strategies
5. **Document** when and why to use each strategy
6. **Provide default strategy** to avoid null checks

## Modern Java Implementation (Java 8+)

```java
// Using functional interfaces
@FunctionalInterface
public interface DiscountStrategy {
double applyDiscount(double price);
}

public class PriceCalculator {
public double calculate(double price, DiscountStrategy strategy) {
return strategy.applyDiscount(price);
}
}

// Client code with lambda expressions
public class ModernStrategyDemo {
public static void main(String[] args) {
PriceCalculator calculator = new PriceCalculator();

double price = 100.0;

double regularPrice = calculator.calculate(price, p -> p);
double tenPercentOff = calculator.calculate(price, p -> p * 0.9);
double twentyDollarsOff = calculator.calculate(price, p -> p - 20);

System.out.println("Regular: $" + regularPrice);
System.out.println("10% off: $" + tenPercentOff);
System.out.println("$20 off: $" + twentyDollarsOff);
}
}
```
