# Dependency Inversion Principle (DIP)

## Principle Definition

**"High-level modules should not depend on low-level modules. Both should depend on abstractions. Abstractions should not depend on details. Details should depend on abstractions."**

Two key points:
1. High-level modules should not import anything from low-level modules
2. Both should depend on abstractions (interfaces/abstract classes)

## Why It Matters

- **Decoupling**: Reduces tight coupling between modules
- **Flexibility**: Easy to swap implementations without changing high-level code
- **Testability**: Easy to mock dependencies for unit testing
- **Reusability**: High-level logic can be reused with different implementations
- **Maintainability**: Changes to low-level details don't affect high-level policy

## Violation Example

```typescript
class MySQLDatabase {
connect(): void {
console.log("Connecting to MySQL...");
}

query(sql: string): any[] {
console.log(`Executing query: ${sql}`);
return [];
}
}

class UserService {
private database: MySQLDatabase;

constructor() {
this.database = new MySQLDatabase();
}

getUsers(): any[] {
this.database.connect();
return this.database.query("SELECT * FROM users");
}

saveUser(user: any): void {
this.database.connect();
this.database.query(`INSERT INTO users VALUES (...)`);
}
}
```

**Problems**:
- UserService (high-level) directly depends on MySQLDatabase (low-level)
- Cannot easily switch to PostgreSQL or MongoDB
- Difficult to test UserService without actual database
- UserService instantiates its own dependency (tight coupling)

## Improved Example

```typescript
interface Database {
connect(): void;
query(sql: string): any[];
}

class MySQLDatabase implements Database {
connect(): void {
console.log("Connecting to MySQL...");
}

query(sql: string): any[] {
console.log(`Executing MySQL query: ${sql}`);
return [];
}
}

class PostgreSQLDatabase implements Database {
connect(): void {
console.log("Connecting to PostgreSQL...");
}

query(sql: string): any[] {
console.log(`Executing PostgreSQL query: ${sql}`);
return [];
}
}

class UserService {
private database: Database;

constructor(database: Database) {
this.database = database;
}

getUsers(): any[] {
this.database.connect();
return this.database.query("SELECT * FROM users");
}

saveUser(user: any): void {
this.database.connect();
this.database.query(`INSERT INTO users VALUES (...)`);
}
}

// Usage
const mysqlDb = new MySQLDatabase();
const userService1 = new UserService(mysqlDb);

const postgresDb = new PostgreSQLDatabase();
const userService2 = new UserService(postgresDb);

// Testing with mock
class MockDatabase implements Database {
connect(): void {}
query(sql: string): any[] {
return [{ id: 1, name: "Test User" }];
}
}

const mockDb = new MockDatabase();
const testService = new UserService(mockDb);
```

**Improvements**:
- UserService depends on Database abstraction, not concrete implementation
- Easy to swap database implementations
- Dependencies are injected (Dependency Injection)
- Easy to test with mock implementations

## Dependency Injection Patterns

### 1. Constructor Injection (Recommended)

```typescript
class OrderService {
constructor(
private paymentProcessor: PaymentProcessor,
private emailService: EmailService,
private logger: Logger
) {}

processOrder(order: Order): void {
this.logger.log("Processing order...");
this.paymentProcessor.process(order.total);
this.emailService.send(order.customerEmail, "Order confirmed");
}
}
```

### 2. Setter Injection

```typescript
class ReportGenerator {
private dataSource: DataSource;

setDataSource(dataSource: DataSource): void {
this.dataSource = dataSource;
}

generate(): string {
const data = this.dataSource.fetch();
return this.formatReport(data);
}

private formatReport(data: any): string {
return "Report";
}
}
```

### 3. Interface Injection

```typescript
interface DataSourceInjector {
injectDataSource(dataSource: DataSource): void;
}

class AnalyticsService implements DataSourceInjector {
private dataSource: DataSource;

injectDataSource(dataSource: DataSource): void {
this.dataSource = dataSource;
}

analyze(): void {
const data = this.dataSource.fetch();
// Analyze data
}
}
```

## Layered Architecture with DIP

```typescript
// Domain Layer (High-level)
interface OrderRepository {
save(order: Order): void;
findById(id: string): Order | null;
}

interface NotificationService {
notify(message: string): void;
}

class OrderProcessor {
constructor(
private orderRepository: OrderRepository,
private notificationService: NotificationService
) {}

placeOrder(order: Order): void {
this.orderRepository.save(order);
this.notificationService.notify(`Order ${order.id} placed`);
}
}

// Infrastructure Layer (Low-level)
class MongoOrderRepository implements OrderRepository {
save(order: Order): void {
// MongoDB specific implementation
}

findById(id: string): Order | null {
// MongoDB specific implementation
return null;
}
}

class EmailNotificationService implements NotificationService {
notify(message: string): void {
// Email specific implementation
console.log(`Email: ${message}`);
}
}

// Composition Root
const orderRepo = new MongoOrderRepository();
const emailService = new EmailNotificationService();
const orderProcessor = new OrderProcessor(orderRepo, emailService);
```

## Inversion of Control (IoC) Container Example

```typescript
class Container {
private services = new Map<string, any>();

register<T>(name: string, implementation: new (...args: any[]) => T): void {
this.services.set(name, implementation);
}

resolve<T>(name: string): T {
const Service = this.services.get(name);
if (!Service) {
throw new Error(`Service ${name} not found`);
}
return new Service();
}
}

// Usage
const container = new Container();
container.register<Database>("Database", MySQLDatabase);
container.register<Logger>("Logger", ConsoleLogger);

const database = container.resolve<Database>("Database");
const logger = container.resolve<Logger>("Logger");
```

## Practical Checkpoints

1. **Import Statements Check**
   - Do high-level modules import concrete low-level classes?
   - Are there imports from infrastructure in domain logic?

2. **New Keyword Usage**
   - Are dependencies instantiated with `new` inside classes?
   - Should dependencies be injected instead?

3. **Testing Difficulty**
   - Is it hard to test a class in isolation?
   - Are you creating real database connections in unit tests?

4. **Change Impact**
   - When you change a low-level detail, do high-level modules need to change?
   - Can you swap implementations without modifying clients?

## Common Mistakes

### Mistake 1: Leaky Abstractions

```typescript
// Bad: Abstraction exposes implementation details
interface Database {
getMySQLConnection(): MySQLConnection;
executeQuery(sql: string): any[];
}

// Good: Pure abstraction
interface Database {
query(sql: string): any[];
}
```

### Mistake 2: Too Many Dependencies

```typescript
// Bad: God class with too many dependencies
class OrderService {
constructor(
private db: Database,
private email: EmailService,
private sms: SMSService,
private payment: PaymentService,
private inventory: InventoryService,
private shipping: ShippingService,
private analytics: AnalyticsService
) {}
}

// Good: Break into smaller services
class OrderProcessor {
constructor(
private orderRepository: OrderRepository,
private orderNotifier: OrderNotifier
) {}
}
```

### Mistake 3: Service Locator Anti-Pattern

```typescript
// Anti-pattern: Service Locator
class UserService {
getUsers(): any[] {
const db = ServiceLocator.get("Database");
return db.query("SELECT * FROM users");
}
}

// Better: Dependency Injection
class UserService {
constructor(private database: Database) {}

getUsers(): any[] {
return this.database.query("SELECT * FROM users");
}
}
```

## Frequently Asked Questions

**Q: Should every class depend on abstractions?**
A: Focus on abstractions for dependencies that are likely to change or need testing isolation. Simple value objects don't need this.

**Q: Isn't DIP the same as Dependency Injection?**
A: DIP is a principle about depending on abstractions. Dependency Injection is a technique to achieve DIP by injecting dependencies.

**Q: How do I handle dependencies with complex initialization?**
A: Use factories or IoC containers to handle complex object creation.

**Q: Does DIP increase complexity?**
A: It adds indirection, but reduces coupling. The benefits usually outweigh the cost for non-trivial applications.

**Q: What about performance?**
A: The overhead of abstraction is negligible in most cases. Modern JIT compilers optimize interface calls effectively.

**Q: When should I start using DIP?**
A: When you identify dependencies that are likely to change, need different implementations, or require testing isolation.
